-- ============================================================================
-- OVA-IA · seed.sql
-- Datos mínimos de arranque: las 4 instituciones, el currículo OA y las
-- insignias. Los nombres de instituciones son provisionales: cámbialos por
-- los reales antes de la primera sesión con estudiantes.
-- ============================================================================

-- ── Instituciones (4 del estudio) ──────────────────────────────────────────
insert into public.institutions (name, short_code, city, research_group)
values
  ('Institución 1', 'INS1', null, null),
  ('Institución 2', 'INS2', null, null),
  ('Institución 3', 'INS3', null, null),
  ('Institución 4', 'INS4', null, null)
on conflict (short_code) do nothing;

-- ── Currículo: objetivos de aprendizaje de grado 10° ───────────────────────
insert into public.curriculum_skills (id, subject, title, description)
values
  ('OA-01', 'bio', 'Genética y Herencia',
   'Explica la transmisión de caracteres hereditarios mediante modelos mendelianos.'),
  ('OA-02', 'fis', 'Leyes de Newton y Fuerzas',
   'Predice el comportamiento de cuerpos aplicando las leyes de Newton y la suma vectorial.'),
  ('OA-03', 'qui', 'Estructura Atómica y Enlaces',
   'Relaciona la configuración electrónica con las propiedades y el tipo de enlace.')
on conflict (id) do nothing;

-- ── Insignias formativas ───────────────────────────────────────────────────
insert into public.badges (code, title, description, icon, criteria)
values
  ('explorador', 'Explorador',
   'Abriste 5 simulaciones interactivas distintas', 'biotech',
   '{"type":"ova_open","count":5}'),
  ('detective', 'Detective',
   'Formulaste 3 hipótesis verificables en tus entregas', 'saved_search',
   '{"type":"evidence_submit","count":3}'),
  ('pregunton', 'Preguntón',
   'Consultaste el Tutor IA al menos 5 veces', 'psychology_alt',
   '{"type":"tutor_message","count":5}'),
  ('sintesis_holistica', 'Síntesis Holística',
   'Conectaste conceptos de biología y química en una reflexión', 'hub',
   '{"type":"reflection_cross_subject","count":1}'),
  ('rigor_experimental', 'Rigor Experimental',
   'Registraste 10 mediciones con margen de error', 'straighten',
   '{"type":"measurement","count":10}'),
  ('pensador_critico', 'Pensador Crítico',
   'Cuestionaste una respuesta del tutor y la corrigió', 'psychology',
   '{"type":"tutor_challenge","count":1}')
on conflict (code) do nothing;
