# OVA-IA · Objeto Virtual de Aprendizaje Grado 10°

Plataforma para la investigación doctoral sobre **tutoría socrática con IA en Ciencias Naturales de grado 10°** en cuatro instituciones educativas.

El proyecto tiene dos aplicaciones y un solo backend:

| Pieza | Rol | Estado |
|---|---|---|
| `apps/student` | **PWA del estudiante**: recibe las OVAs que el docente asigna, las estudia (incluso sin internet), entrega evidencias y escribe su bitácora | En construcción · fase 0 lista |
| `apps/teacher` | **Plataforma docente** (web): escoge OVAs, crea asignaciones y califica | Planeada · fase 5 |
| `supabase/` | Postgres + Auth + Storage + Edge Functions (OpenRouter) | Esquema inicial listo |

---

## Principio de diseño: nombre real ↔ código anónimo

Esta es la decisión estructural del proyecto y no se negocia:

- **El docente ve el nombre** del estudiante, porque necesita calificarlo.
- **El investigador ve solo el código** (`INS2-10B-0147`), y obtiene los datos a través de vistas que **físicamente no pueden** devolver un nombre.

Los datos identificables viven en `student_identity`; todo lo demás referencia `participants`. La política está en [`supabase/migrations/0002_rls.sql`](supabase/migrations/0002_rls.sql) y las vistas de análisis en [`0003_research_views.sql`](supabase/migrations/0003_research_views.sql).

---

## Requisitos

- **Node 22 LTS** (o superior) y npm
- Git
- Una cuenta de [Supabase](https://supabase.com) (no hace falta Docker)

## Puesta en marcha

```bash
npm install
cp .env.example .env.local      # en Windows: Copy-Item .env.example .env.local
npm run dev                     # http://localhost:3000
```

Completa `.env.local` con la URL y la clave anónima de tu proyecto de Supabase (panel → *Project Settings → API*). Sin esos valores la app arranca en modo UI, pero no conecta.

### Comandos

| Comando | Qué hace |
|---|---|
| `npm run dev` | Servidor de desarrollo en el puerto 3000 |
| `npm run build` | Verifica tipos y compila la PWA en `apps/student/dist` |
| `npm run preview` | Sirve la build localmente |
| `npm run typecheck` | Solo verificación de tipos |

---

## Base de datos

El esquema vive en migraciones versionadas:

| Archivo | Contenido |
|---|---|
| `0001_init.sql` | Instituciones, cursos, participantes, identidad, OVAs, artefactos, asignaciones, entregas, bitácora, notas externas, telemetría, xAPI |
| `0002_rls.sql` | Políticas de seguridad por rol (estudiante / docente / investigador / admin) |
| `0003_research_views.sql` | Vistas anonimizadas para el análisis de la tesis |
| `seed.sql` | 4 instituciones, objetivos de aprendizaje OA-01…03, insignias |

Aplicar a tu proyecto:

```bash
npx supabase link --project-ref TU_REF
npx supabase db push
```

O pegar el contenido de cada archivo en el *SQL Editor* del panel, en orden.

> **Regla del estudio:** la telemetría (`events`) y los statements xAPI son **append-only**. La base rechaza cualquier `UPDATE` o `DELETE` sobre esas tablas.

---

## Acceso del estudiante y privacidad

- **Clave acordada en clase**, no contraseña: sin correo, sin SMS, sin recuperación. El hash se guarda con bcrypt.
- **PIN en dispositivos compartidos** (tablets del colegio): modo "ingreso rápido" por código + clave.
- **Consentimiento en papel** custodiado por el colegio; la base registra la constancia (versión, fecha, quién la registró).
- Las lecturas de Storage son **URLs firmadas**: un enlace reenviado no funciona fuera de la sesión del estudiante.

---

## Estructura

```
.
├─ apps/
│  └─ student/              PWA del estudiante (React 19 + Vite + Tailwind v4)
├─ packages/
│  └─ shared/               Tokens de diseño y tipos de dominio
├─ supabase/
│  ├─ migrations/           Esquema y políticas
│  ├─ functions/            Edge Functions (tutor con OpenRouter)
│  └─ seed.sql              Datos de arranque
├─ docs/
│  └─ design/               DESIGN.md, mockup de referencia y captura
└─ .github/workflows/ci.yml Tipos + build en cada PR
```

---

## Decisiones tomadas

| Tema | Decisión |
|---|---|
| Backend | **Supabase** (Postgres + RLS), no Firebase: la tesis necesita SQL y separación por columnas |
| Alojamiento | Vercel (HTTPS gratuito). **Sin dominio propio** por ahora |
| Artefactos | Supabase Storage, límite 25 MB por archivo. **Video solo por enlace externo** |
| Visor | Todo dentro de la app (PDF, imagen, audio, H5P en iframe aislado). Los enlaces no sacan al estudiante del flujo |
| IA | OpenRouter desde una Edge Function. La clave nunca llega al cliente |
| Telemetría | Tabla `events` propia + statements xAPI de H5P/SCORM |
| Pruebas externas | Autorreportadas por el estudiante, marcadas como tales |

---

## Licencia

Privado. Proyecto de investigación — Universidad, 2026.
