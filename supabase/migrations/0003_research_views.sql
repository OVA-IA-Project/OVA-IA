-- ============================================================================
-- OVA-IA · 0003_research_views.sql
-- Vistas para la investigación.
--
-- Estas vistas las usa el rol `investigador`. Devuelven datos con código
-- anónimo y NUNCA cruzan `student_identity`. El anonimato no depende de la
-- disciplina al exportar: está impuesto por la base de datos.
-- ============================================================================

-- ── Participantes (sin nombre, sin clave) ──────────────────────────────────
create or replace view public.v_participants_anon
with (security_invoker = true) as
select
  p.id                as participant_id,
  p.participant_code,
  i.short_code        as institution_code,
  i.name              as institution_name,
  i.research_group,
  c.label             as course_label,
  c.school_year,
  p.consent_version,
  (p.consent_date is not null) as consented,
  p.created_at,
  p.last_seen_at
from public.participants p
join public.institutions i on i.id = p.institution_id
join public.courses c      on c.id = p.course_id;

-- ── Entregas con calificación (sin nombre) ─────────────────────────────────
create or replace view public.v_submissions_anon
with (security_invoker = true) as
select
  s.participant_id,
  p.participant_code,
  i.short_code        as institution_code,
  c.label             as course_label,
  s.assignment_id,
  o.code              as ova_code,
  o.title             as ova_title,
  o.subject,
  s.submitted_at,
  s.was_offline,
  s.grade,
  s.graded_at,
  (s.text_answer is not null) as has_text,
  jsonb_array_length(s.files) as file_count
from public.submissions s
join public.participants p   on p.id = s.participant_id
join public.institutions i   on i.id = p.institution_id
join public.courses c        on c.id = p.course_id
join public.assignments a    on a.id = s.assignment_id
join public.ovas o           on o.id = a.ova_id;

-- ── Actividad agregada por estudiante y OVA ────────────────────────────────
create or replace view public.v_activity_summary
with (security_invoker = true) as
select
  e.participant_id,
  p.participant_code,
  e.ova_id,
  count(*) filter (where e.event_type = 'ova_open')      as ova_opens,
  count(*) filter (where e.event_type = 'page_view')     as page_views,
  coalesce(sum((e.payload->>'dwellSeconds')::numeric)
           filter (where e.event_type = 'page_dwell'), 0) as dwell_seconds,
  count(*) filter (where e.event_type = 'evidence_submit') as submissions,
  min(e.occurred_at)                                       as first_event_at,
  max(e.occurred_at)                                       as last_event_at,
  count(distinct date_trunc('day', e.occurred_at))         as active_days
from public.events e
join public.participants p on p.id = e.participant_id
group by e.participant_id, p.participant_code, e.ova_id;

-- ── xAPI por verbo ─────────────────────────────────────────────────────────
create or replace view public.v_xapi_summary
with (security_invoker = true) as
select
  x.participant_id,
  x.actor_code,
  x.verb_id,
  x.object_id,
  count(*)                          as statements,
  count(*) filter (where (x.result->>'success')::boolean is true)  as successes,
  count(*) filter (where (x.result->>'success')::boolean is false) as failures,
  min(x.stored_at)                  as first_at,
  max(x.stored_at)                  as last_at
from public.xapi_statements x
group by x.participant_id, x.actor_code, x.verb_id, x.object_id;

-- ── Bitácora agregada (texto incluido: es dato primario de la tesis) ───────
create or replace view public.v_reflections_anon
with (security_invoker = true) as
select
  r.participant_id,
  p.participant_code,
  r.ova_id,
  r.prompt,
  r.body,
  length(r.body)  as char_count,
  r.created_at,
  r.was_offline
from public.reflections r
join public.participants p on p.id = r.participant_id;
