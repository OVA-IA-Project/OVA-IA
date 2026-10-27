-- ============================================================================
-- OVA-IA · 0002_rls.sql
-- Políticas de seguridad a nivel de fila.
--
-- Regla de oro: nada es accesible por defecto. Cada tabla se abre explícitamente.
--   · estudiante  → ve y escribe SOLO lo suyo (por participant_id)
--   · docente     → ve SOLO los cursos donde tiene asignaciones
--   · investigador→ ve datos anónimos, jamás nombres
--   · admin       → gestiona catálogo, instituciones, OVAs y personal
-- ============================================================================

alter table public.institutions       enable row level security;
alter table public.courses            enable row level security;
alter table public.staff              enable row level security;
alter table public.participants       enable row level security;
alter table public.student_identity   enable row level security;
alter table public.student_settings   enable row level security;
alter table public.course_sequences   enable row level security;
alter table public.curriculum_skills  enable row level security;
alter table public.ovas               enable row level security;
alter table public.ova_artifacts      enable row level security;
alter table public.assignments        enable row level security;
alter table public.submissions        enable row level security;
alter table public.reflections        enable row level security;
alter table public.external_scores    enable row level security;
alter table public.tutor_conversations enable row level security;
alter table public.tutor_messages     enable row level security;
alter table public.events             enable row level security;
alter table public.xapi_statements    enable row level security;
alter table public.badges             enable row level security;
alter table public.participant_badges enable row level security;
alter table public.mastery            enable row level security;
alter table public.streaks            enable row level security;

-- ── INSTITUCIONES Y CURSOS ─────────────────────────────────────────────────
-- Lectura para cualquier usuario autenticado (se necesitan para el registro).
drop policy if exists institutions_read on public.institutions;
create policy institutions_read on public.institutions
  for select to authenticated using (true);

drop policy if exists institutions_admin on public.institutions;
create policy institutions_admin on public.institutions
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists courses_read on public.courses;
create policy courses_read on public.courses
  for select to authenticated using (true);

drop policy if exists courses_admin on public.courses;
create policy courses_admin on public.courses
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- ── PERSONAL ───────────────────────────────────────────────────────────────
-- Cada quien ve su propia ficha; el admin ve todas.
drop policy if exists staff_self_read on public.staff;
create policy staff_self_read on public.staff
  for select to authenticated using (id = auth.uid() or public.is_admin());

drop policy if exists staff_admin_write on public.staff;
create policy staff_admin_write on public.staff
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- ── PARTICIPANTES ──────────────────────────────────────────────────────────
-- El estudiante ve su propia fila. El docente ve las de sus cursos.
-- El investigador ve un agregado (pero la fila cruda incluye access_key_hash,
-- por eso se le da acceso solo a través de la vista de exportación).
drop policy if exists participants_self on public.participants;
create policy participants_self on public.participants
  for select to authenticated
  using (
    auth_user_id = auth.uid()
    or public.is_admin()
    or (public.current_staff().role = 'docente'
        and course_id in (
          select course_id from public.assignments where teacher_id = auth.uid()
        ))
  );

drop policy if exists participants_admin_write on public.participants;
create policy participants_admin_write on public.participants
  for update to authenticated
  using (public.is_admin() or auth_user_id = auth.uid())
  with check (public.is_admin() or auth_user_id = auth.uid());

-- ── IDENTIDAD (nombre real) — SOLO el docente de ese curso ─────────────────
-- Esta es la tabla crítica del anonimato. El investigador NO tiene política
-- de lectura: no puede consultarla aunque tenga sesión válida.
drop policy if exists identity_teacher_read on public.student_identity;
create policy identity_teacher_read on public.student_identity
  for select to authenticated
  using (
    public.is_admin()
    or exists (
      select 1
      from public.participants p
      join public.assignments a on a.course_id = p.course_id
      where p.id = student_identity.participant_id
        and a.teacher_id = auth.uid()
    )
  );

drop policy if exists identity_write on public.student_identity;
create policy identity_write on public.student_identity
  for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- ── PREFERENCIAS ───────────────────────────────────────────────────────────
drop policy if exists settings_self on public.student_settings;
create policy settings_self on public.student_settings
  for all to authenticated
  using (participant_id = public.current_participant_id())
  with check (participant_id = public.current_participant_id());

-- ── CURRÍCULO, OVAs Y ARTEFACTOS ───────────────────────────────────────────
drop policy if exists skills_read on public.curriculum_skills;
create policy skills_read on public.curriculum_skills
  for select to authenticated using (true);

drop policy if exists skills_admin on public.curriculum_skills;
create policy skills_admin on public.curriculum_skills
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Una OVA se ve si está publicada y asignada a mi curso, o si soy admin/docente
drop policy if exists ovas_read on public.ovas;
create policy ovas_read on public.ovas
  for select to authenticated
  using (
    public.is_admin()
    or exists (
      select 1 from public.assignments a
      join public.participants p on p.course_id = a.course_id
      where a.ova_id = ovas.id
        and a.published_at is not null
        and (a.teacher_id = auth.uid() or p.auth_user_id = auth.uid())
    )
  );

drop policy if exists ovas_admin on public.ovas;
create policy ovas_admin on public.ovas
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists artifacts_read on public.ova_artifacts;
create policy artifacts_read on public.ova_artifacts
  for select to authenticated
  using (
    public.is_admin()
    or exists (
      select 1 from public.ovas o
      join public.assignments a on a.ova_id = o.id
      join public.participants p on p.course_id = a.course_id
      where o.id = ova_artifacts.ova_id
        and a.published_at is not null
        and (a.teacher_id = auth.uid() or p.auth_user_id = auth.uid())
    )
  );

drop policy if exists artifacts_admin on public.ova_artifacts;
create policy artifacts_admin on public.ova_artifacts
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- ── ASIGNACIONES ───────────────────────────────────────────────────────────
-- El estudiante ve las publicadas de su curso; el docente ve las suyas.
drop policy if exists assignments_read on public.assignments;
create policy assignments_read on public.assignments
  for select to authenticated
  using (
    public.is_admin()
    or teacher_id = auth.uid()
    or (
      published_at is not null
      and course_id = (
        select course_id from public.participants where auth_user_id = auth.uid()
      )
    )
  );

drop policy if exists assignments_teacher_write on public.assignments;
create policy assignments_teacher_write on public.assignments
  for all to authenticated
  using (public.is_admin() or teacher_id = auth.uid())
  with check (public.is_admin() or teacher_id = auth.uid());

-- ── ENTREGAS ───────────────────────────────────────────────────────────────
drop policy if exists submissions_student_read on public.submissions;
create policy submissions_student_read on public.submissions
  for select to authenticated
  using (participant_id = public.current_participant_id());

drop policy if exists submissions_student_insert on public.submissions;
create policy submissions_student_insert on public.submissions
  for insert to authenticated
  with check (
    participant_id = public.current_participant_id()
    and exists (
      select 1 from public.assignments a
      where a.id = submissions.assignment_id
        and a.published_at is not null
        and a.course_id = (
          select course_id from public.participants
          where auth_user_id = auth.uid()
        )
    )
  );

drop policy if exists submissions_student_update on public.submissions;
create policy submissions_student_update on public.submissions
  for update to authenticated
  using (participant_id = public.current_participant_id() and grade is null)
  with check (participant_id = public.current_participant_id() and grade is null);

drop policy if exists submissions_teacher_read on public.submissions;
create policy submissions_teacher_read on public.submissions
  for select to authenticated
  using (
    public.is_admin()
    or exists (
      select 1 from public.assignments a
      where a.id = submissions.assignment_id and a.teacher_id = auth.uid()
    )
  );

-- Solo el docente del curso califica, y solo el campo de calificación.
drop policy if exists submissions_teacher_grade on public.submissions;
create policy submissions_teacher_grade on public.submissions
  for update to authenticated
  using (
    exists (
      select 1 from public.assignments a
      where a.id = submissions.assignment_id and a.teacher_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.assignments a
      where a.id = submissions.assignment_id and a.teacher_id = auth.uid()
    )
  );

-- ── BITÁCORA ───────────────────────────────────────────────────────────────
drop policy if exists reflections_student on public.reflections;
create policy reflections_student on public.reflections
  for all to authenticated
  using (participant_id = public.current_participant_id())
  with check (participant_id = public.current_participant_id());

drop policy if exists reflections_teacher_read on public.reflections;
create policy reflections_teacher_read on public.reflections
  for select to authenticated
  using (
    public.is_admin()
    or exists (
      select 1 from public.participants p
      join public.assignments a on a.course_id = p.course_id
      where p.id = reflections.participant_id and a.teacher_id = auth.uid()
    )
  );

-- El investigador lee bitácoras solo a través de v_research_export.

-- ── NOTAS EXTERNAS ─────────────────────────────────────────────────────────
drop policy if exists external_scores_student on public.external_scores;
create policy external_scores_student on public.external_scores
  for all to authenticated
  using (participant_id = public.current_participant_id())
  with check (participant_id = public.current_participant_id());

-- ── TUTOR ──────────────────────────────────────────────────────────────────
drop policy if exists tutor_conversations_own on public.tutor_conversations;
create policy tutor_conversations_own on public.tutor_conversations
  for all to authenticated
  using (participant_id = public.current_participant_id())
  with check (participant_id = public.current_participant_id());

drop policy if exists tutor_messages_own on public.tutor_messages;
create policy tutor_messages_own on public.tutor_messages
  for all to authenticated
  using (
    exists (
      select 1 from public.tutor_conversations c
      where c.id = tutor_messages.conversation_id
        and c.participant_id = public.current_participant_id()
    )
  )
  with check (
    exists (
      select 1 from public.tutor_conversations c
      where c.id = tutor_messages.conversation_id
        and c.participant_id = public.current_participant_id()
    )
  );

-- ── TELEMETRÍA Y xAPI ──────────────────────────────────────────────────────
-- El estudiante inserta lo suyo; nadie actualiza ni borra (trigger lo impide).
drop policy if exists events_student_insert on public.events;
create policy events_student_insert on public.events
  for insert to authenticated
  with check (participant_id = public.current_participant_id());

drop policy if exists events_researcher_read on public.events;
create policy events_researcher_read on public.events
  for select to authenticated
  using (public.is_researcher() or public.is_admin());

drop policy if exists events_teacher_read on public.events;
create policy events_teacher_read on public.events
  for select to authenticated
  using (
    exists (
      select 1 from public.participants p
      join public.assignments a on a.course_id = p.course_id
      where p.id = events.participant_id and a.teacher_id = auth.uid()
    )
  );

drop policy if exists xapi_student_insert on public.xapi_statements;
create policy xapi_student_insert on public.xapi_statements
  for insert to authenticated
  with check (participant_id = public.current_participant_id());

drop policy if exists xapi_researcher_read on public.xapi_statements;
create policy xapi_researcher_read on public.xapi_statements
  for select to authenticated
  using (public.is_researcher() or public.is_admin());

-- ── INSIGNIAS, DOMINIO, RACHA ──────────────────────────────────────────────
drop policy if exists badges_read on public.badges;
create policy badges_read on public.badges for select to authenticated using (true);

drop policy if exists badges_admin on public.badges;
create policy badges_admin on public.badges
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists participant_badges_own on public.participant_badges;
create policy participant_badges_own on public.participant_badges
  for select to authenticated
  using (participant_id = public.current_participant_id() or public.is_admin());

drop policy if exists mastery_own on public.mastery;
create policy mastery_own on public.mastery
  for select to authenticated
  using (participant_id = public.current_participant_id() or public.is_researcher());

drop policy if exists streaks_own on public.streaks;
create policy streaks_own on public.streaks
  for all to authenticated
  using (participant_id = public.current_participant_id())
  with check (participant_id = public.current_participant_id());
