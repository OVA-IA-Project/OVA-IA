-- ============================================================================
-- OVA-IA · 0001_init.sql
-- Esquema inicial: instituciones, cursos, estudiantes, OVAs, asignaciones,
-- evidencias, bitácora, telemetría, xAPI y notas externas.
--
-- Principio rector del anonimato:
--   Los datos identificables viven en `student_identity` (solo el docente del
--   curso). TODO lo demás referencia `participants` (código anónimo).
--   El investigador exporta desde `v_research_export`, que físicamente no
--   puede devolver un nombre.
-- ============================================================================

create extension if not exists "pgcrypto" with schema extensions;
create extension if not exists "citext" with schema extensions;

-- ── Tipos ───────────────────────────────────────────────────────────────────
do $$ begin
  create type public.subject as enum ('bio', 'fis', 'qui');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.artifact_kind as enum
    ('document', 'image', 'audio', 'interactive', 'video', 'link');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.assignment_state as enum
    ('pendiente', 'en_progreso', 'entregado', 'calificado');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.staff_role as enum ('docente', 'investigador', 'admin');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.tutor_feedback as enum ('util', 'mas_pista');
exception when duplicate_object then null; end $$;

-- ════════════════════════════════════════════════════════════════════════════
-- 1. TENANCIA
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.institutions (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique,
  short_code  text not null unique,          -- 'INS1' … usado en el código de participante
  city        text,
  dane_code   text,
  research_group text,                       -- 'experimental' | 'control'
  created_at  timestamptz not null default now()
);

create table if not exists public.courses (
  id             uuid primary key default gen_random_uuid(),
  institution_id uuid not null references public.institutions(id) on delete cascade,
  school_year    int  not null default extract(year from now())::int,
  label          text not null,              -- '10A', '10B', …
  grade          smallint not null default 10 check (grade = 10),
  max_students   smallint not null default 45 check (max_students between 1 and 60),
  created_at     timestamptz not null default now(),
  unique (institution_id, school_year, label)
);

-- Máximo 6 cursos de décimo por institución (10A–10F)
create or replace function public.enforce_course_limit()
returns trigger language plpgsql as $$
declare
  curso_count int;
begin
  select count(*) into curso_count
  from public.courses
  where institution_id = new.institution_id and school_year = new.school_year;

  if curso_count >= 6 then
    raise exception 'Una institución no puede tener más de 6 cursos de décimo por año';
  end if;
  return new;
end $$;

drop trigger if exists trg_course_limit on public.courses;
create trigger trg_course_limit
  before insert on public.courses
  for each row execute function public.enforce_course_limit();

-- ════════════════════════════════════════════════════════════════════════════
-- 2. PERSONAL (docente / investigador / admin)  — vincula auth.users
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.staff (
  id             uuid primary key references auth.users(id) on delete cascade,
  full_name      text not null,
  email          citext unique,
  role           public.staff_role not null default 'docente',
  institution_id uuid references public.institutions(id) on delete restrict,
  subjects       public.subject[] not null default '{}',   -- puede dictar varias
  is_active      boolean not null default true,
  created_at     timestamptz not null default now(),
  -- Un docente pertenece a UNA sola institución (regla del estudio)
  constraint staff_institution_required
    check (role = 'admin' or institution_id is not null)
);

create index if not exists idx_staff_institution on public.staff(institution_id);

-- ════════════════════════════════════════════════════════════════════════════
-- 3. PARTICIPANTES (anónimo) + IDENTIDAD (con nombre) — tablas separadas
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.participants (
  id              uuid primary key default gen_random_uuid(),
  auth_user_id    uuid unique references auth.users(id) on delete set null,
  participant_code text not null unique,      -- 'INS2-10B-0147'
  institution_id  uuid not null references public.institutions(id) on delete restrict,
  course_id       uuid not null references public.courses(id) on delete restrict,
  -- Clave de acceso: hash bcrypt (nunca en claro)
  access_key_hash text not null,
  failed_attempts smallint not null default 0,
  locked_until    timestamptz,
  -- Consentimiento (el papel lo custodia el colegio; aquí queda la constancia)
  consent_version text,
  consent_date    timestamptz,
  consent_registered_by uuid references auth.users(id),
  created_at      timestamptz not null default now(),
  last_seen_at    timestamptz
);

create index if not exists idx_participants_course on public.participants(course_id);
create index if not exists idx_participants_institution on public.participants(institution_id);

-- El nombre vive SOLO aquí. RLS restringe la lectura al docente del curso.
create table if not exists public.student_identity (
  participant_id uuid primary key references public.participants(id) on delete cascade,
  full_name      text not null,
  guardian_name  text,
  guardian_phone text,
  created_at     timestamptz not null default now()
);

create table if not exists public.student_settings (
  participant_id uuid primary key references public.participants(id) on delete cascade,
  text_size      text not null default 'normal' check (text_size in ('normal','large','xlarge')),
  open_dyslexic  boolean not null default false,
  high_contrast  boolean not null default false,
  dark_mode      boolean not null default false,
  hide_streak    boolean not null default false,
  notifications  boolean not null default false,
  updated_at     timestamptz not null default now()
);

-- Contador por curso para generar códigos correlativos sin colisiones
create table if not exists public.course_sequences (
  course_id      uuid primary key references public.courses(id) on delete cascade,
  last_number    int not null default 0
);

-- ── Alta de participante (RPC) ─────────────────────────────────────────────
-- Devuelve el código generado. La clave se guarda como bcrypt.
create or replace function public.enroll_participant(
  p_course_id     uuid,
  p_full_name     text,
  p_guardian_name text,
  p_access_key    text,
  p_consent_version text
) returns text
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_course  public.courses;
  v_inst    public.institutions;
  v_number  int;
  v_code    text;
  v_pid     uuid;
  v_count   int;
begin
  if length(trim(p_full_name)) < 3 then
    raise exception 'El nombre completo es obligatorio';
  end if;
  if length(p_access_key) < 4 then
    raise exception 'La clave debe tener al menos 4 caracteres';
  end if;

  select * into v_course from public.courses where id = p_course_id;
  if not found then raise exception 'Curso inexistente'; end if;

  select * into v_inst from public.institutions where id = v_course.institution_id;

  select count(*) into v_count from public.participants where course_id = p_course_id;
  if v_count >= v_course.max_students then
    raise exception 'El curso % alcanzó el máximo de % estudiantes',
      v_course.label, v_course.max_students;
  end if;

  -- Secuencia atómica por curso
  insert into public.course_sequences(course_id, last_number)
    values (p_course_id, 1)
    on conflict (course_id) do update set last_number = public.course_sequences.last_number + 1
    returning last_number into v_number;

  v_code := v_inst.short_code || '-' || v_course.label || '-' ||
            lpad(v_number::text, 4, '0');

  insert into public.participants
    (participant_code, institution_id, course_id, access_key_hash,
     consent_version, consent_date)
  values
    (v_code, v_course.institution_id, p_course_id,
     crypt(p_access_key, gen_salt('bf')),
     p_consent_version, now())
  returning id into v_pid;

  insert into public.student_identity(participant_id, full_name, guardian_name)
  values (v_pid, trim(p_full_name), nullif(trim(p_guardian_name), ''));

  insert into public.student_settings(participant_id) values (v_pid);

  return v_code;
end $$;

-- ── Acceso con código + clave (RPC desde modo tablet o reinstalación) ──────
create or replace function public.verify_access_key(
  p_participant_code text,
  p_access_key       text
) returns table (participant_id uuid, must_reset boolean)
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_p public.participants;
begin
  select * into v_p from public.participants
  where lower(participant_code) = lower(trim(p_participant_code));

  if not found then
    return query select null::uuid, true;   -- no revelamos si el código existe
    return;
  end if;

  if v_p.locked_until is not null and v_p.locked_until > now() then
    raise exception 'Acceso bloqueado temporalmente. Intenta en unos minutos.';
  end if;

  if v_p.access_key_hash = crypt(p_access_key, v_p.access_key_hash) then
    update public.participants
      set failed_attempts = 0, locked_until = null, last_seen_at = now()
      where id = v_p.id;
    return query select v_p.id, false;
  else
    update public.participants
      set failed_attempts = failed_attempts + 1,
          locked_until = case when failed_attempts + 1 >= 5
                              then now() + interval '10 minutes' end
      where id = v_p.id;
    return query select null::uuid, true;
  end if;
end $$;

-- ════════════════════════════════════════════════════════════════════════════
-- 4. CURRÍCULO Y OVAs
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.curriculum_skills (
  id        text primary key,               -- 'OA-01'
  subject   public.subject not null,
  title     text not null,                  -- 'Genética y Herencia'
  description text
);

create table if not exists public.ovas (
  id                uuid primary key default gen_random_uuid(),
  code              text unique,            -- 'OVA-02'
  title             text not null,
  description       text,
  subject           public.subject,         -- null = transversal
  skill_ids         text[] not null default '{}',
  cover_image_path  text,
  estimated_minutes int not null default 15,
  is_published      boolean not null default false,
  created_by        uuid references auth.users(id),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create table if not exists public.ova_artifacts (
  id               uuid primary key default gen_random_uuid(),
  ova_id           uuid not null references public.ovas(id) on delete cascade,
  title            text not null,
  kind             public.artifact_kind not null,
  storage_path     text,                    -- bucket privado
  external_url     text,
  mime_type        text,
  size_bytes       bigint,
  checksum         text,                    -- sha256
  version          int not null default 1,
  order_index      int not null default 0,
  offline_eligible boolean not null default true,
  emits_xapi       boolean not null default false,
  created_at       timestamptz not null default now(),
  constraint artifact_source check (
    (kind = 'link' or kind = 'video') and external_url is not null
    or (kind <> 'link' and kind <> 'video') and storage_path is not null
  ),
  constraint artifact_max_size check (size_bytes is null or size_bytes <= 26214400)
);

create index if not exists idx_artifacts_ova on public.ova_artifacts(ova_id);

-- ════════════════════════════════════════════════════════════════════════════
-- 5. ASIGNACIONES (lo que el docente manda al curso)
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.assignments (
  id                uuid primary key default gen_random_uuid(),
  ova_id            uuid not null references public.ovas(id) on delete restrict,
  course_id         uuid not null references public.courses(id) on delete cascade,
  teacher_id        uuid not null references public.staff(id) on delete restrict,
  title             text,
  instructions      text,
  opens_at          timestamptz not null default now(),
  due_at            timestamptz,
  evidence_required boolean not null default true,
  max_evidence_files smallint not null default 3 check (max_evidence_files between 0 and 10),
  is_gradable       boolean not null default true,
  published_at      timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index if not exists idx_assignments_course on public.assignments(course_id);
create index if not exists idx_assignments_teacher on public.assignments(teacher_id);

-- ════════════════════════════════════════════════════════════════════════════
-- 6. ENTREGAS, CALIFICACIONES Y BITÁCORA
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.submissions (
  id             uuid primary key default gen_random_uuid(),
  assignment_id  uuid not null references public.assignments(id) on delete cascade,
  participant_id uuid not null references public.participants(id) on delete cascade,
  text_answer    text,
  files          jsonb not null default '[]'::jsonb,   -- [{storagePath,mimeType,sizeBytes,originalName}]
  submitted_at   timestamptz not null default now(),
  was_offline    boolean not null default false,
  grade          numeric(3,1) check (grade is null or grade between 0 and 5),
  teacher_comment text,
  graded_at      timestamptz,
  graded_by      uuid references public.staff(id),
  unique (assignment_id, participant_id)               -- una entrega vigente
);

create index if not exists idx_submissions_participant on public.submissions(participant_id);

create table if not exists public.reflections (
  id             uuid primary key default gen_random_uuid(),
  participant_id uuid not null references public.participants(id) on delete cascade,
  assignment_id  uuid references public.assignments(id) on delete set null,
  ova_id         uuid references public.ovas(id) on delete set null,
  prompt         text not null,
  body           text not null check (length(trim(body)) > 0),
  created_at     timestamptz not null default now(),
  was_offline    boolean not null default false
);

create index if not exists idx_reflections_participant on public.reflections(participant_id);

-- Notas de pruebas externas (autorreportadas, opcional por institución)
create table if not exists public.external_scores (
  id             uuid primary key default gen_random_uuid(),
  participant_id uuid not null references public.participants(id) on delete cascade,
  test_name      text not null,
  test_date      date not null,
  score          numeric(6,2) not null,
  scale_max      numeric(6,2),
  notes          text,
  self_reported  boolean not null default true,
  created_at     timestamptz not null default now()
);

-- ════════════════════════════════════════════════════════════════════════════
-- 7. TUTOR IA
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.tutor_conversations (
  id             uuid primary key default gen_random_uuid(),
  participant_id uuid not null references public.participants(id) on delete cascade,
  assignment_id  uuid references public.assignments(id) on delete set null,
  created_at     timestamptz not null default now()
);

create table if not exists public.tutor_messages (
  id              uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.tutor_conversations(id) on delete cascade,
  role            text not null check (role in ('student','tutor')),
  content         text not null,
  hint_level      smallint,
  model           text,
  tokens_in       int,
  tokens_out      int,
  latency_ms      int,
  safety_flags    jsonb,
  feedback        public.tutor_feedback,
  created_at      timestamptz not null default now()
);

create index if not exists idx_tutor_messages_conv on public.tutor_messages(conversation_id);

-- ════════════════════════════════════════════════════════════════════════════
-- 8. TELEMETRÍA PROPIA (append-only)
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.events (
  id             bigserial primary key,
  participant_id uuid not null references public.participants(id) on delete cascade,
  assignment_id  uuid references public.assignments(id) on delete set null,
  ova_id         uuid references public.ovas(id) on delete set null,
  artifact_id    uuid references public.ova_artifacts(id) on delete set null,
  event_type     text not null,    -- app_open, ova_open, page_view, page_dwell, …
  payload        jsonb not null default '{}'::jsonb,
  occurred_at    timestamptz not null default now(),
  client_time    timestamptz,      -- reloj del dispositivo (puede no estar en hora)
  was_offline    boolean not null default false,
  device         jsonb
);

create index if not exists idx_events_participant on public.events(participant_id, occurred_at desc);
create index if not exists idx_events_type on public.events(event_type);
create index if not exists idx_events_ova on public.events(ova_id);

-- Bloquea UPDATE/DELETE: la telemetría es evidencia
create or replace function public.deny_mutation()
returns trigger language plpgsql as $$
begin
  raise exception 'La tabla % es append-only (auditoría del estudio)', tg_table_name;
end $$;

drop trigger if exists trg_events_immutable on public.events;
create trigger trg_events_immutable
  before update or delete on public.events
  for each row execute function public.deny_mutation();

-- ════════════════════════════════════════════════════════════════════════════
-- 9. xAPI (LRS mínimo embebido)
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.xapi_statements (
  id             uuid primary key default gen_random_uuid(),
  statement_id   uuid not null unique,        -- id provisto por el cliente
  participant_id uuid not null references public.participants(id) on delete cascade,
  -- El actor SIEMPRE es el código anónimo, nunca nombre ni correo
  actor_code     text not null,
  verb_id        text not null,
  verb_display   text,
  object_id      text not null,
  object_name    text,
  result         jsonb,
  context        jsonb,
  raw            jsonb not null,             -- statement completo tal como llegó
  stored_at      timestamptz not null default now(),
  received_offline boolean not null default false
);

create index if not exists idx_xapi_participant on public.xapi_statements(participant_id, stored_at desc);
create index if not exists idx_xapi_verb on public.xapi_statements(verb_id);
create index if not exists idx_xapi_object on public.xapi_statements(object_id);

drop trigger if exists trg_xapi_immutable on public.xapi_statements;
create trigger trg_xapi_immutable
  before update or delete on public.xapi_statements
  for each row execute function public.deny_mutation();

-- ════════════════════════════════════════════════════════════════════════════
-- 10. INSIGNIAS, RACHA Y DOMINIO
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.badges (
  code        text primary key,
  title       text not null,
  description text not null,
  icon        text not null,
  criteria    jsonb not null default '{}'::jsonb
);

create table if not exists public.participant_badges (
  participant_id uuid not null references public.participants(id) on delete cascade,
  badge_code     text not null references public.badges(code) on delete cascade,
  awarded_at     timestamptz not null default now(),
  evidence       jsonb,
  primary key (participant_id, badge_code)
);

create table if not exists public.mastery (
  participant_id uuid not null references public.participants(id) on delete cascade,
  skill_id       text not null references public.curriculum_skills(id) on delete cascade,
  score          numeric(5,2) not null default 0 check (score between 0 and 100),
  level          text,
  updated_at     timestamptz not null default now(),
  primary key (participant_id, skill_id)
);

create table if not exists public.streaks (
  participant_id  uuid primary key references public.participants(id) on delete cascade,
  current_days    smallint not null default 0,
  best_days       smallint not null default 0,
  last_active_date date
);

-- ════════════════════════════════════════════════════════════════════════════
-- 11. HELPERS DE SEGURIDAD
-- ════════════════════════════════════════════════════════════════════════════

create or replace function public.current_participant_id()
returns uuid language sql stable security definer set search_path = public as $$
  select id from public.participants where auth_user_id = auth.uid();
$$;

create or replace function public.current_staff()
returns public.staff language sql stable security definer set search_path = public as $$
  select * from public.staff where id = auth.uid() and is_active;
$$;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.staff where id = auth.uid() and role = 'admin' and is_active);
$$;

create or replace function public.is_researcher()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.staff
    where id = auth.uid() and role in ('investigador','admin') and is_active
  );
$$;

-- ¿El usuario actual es docente del curso indicado?
create or replace function public.teaches_course(p_course_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.assignments a
    where a.course_id = p_course_id and a.teacher_id = auth.uid()
  ) or exists (
    select 1 from public.staff s
    where s.id = auth.uid() and s.role in ('admin') and s.is_active
  );
$$;
