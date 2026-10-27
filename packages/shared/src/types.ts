/**
 * Tipos de dominio compartidos entre la app del estudiante
 * y la plataforma docente.
 *
 * Fuente: el export de AI Studio, revisado y alineado con el modelo de datos
 * de Supabase (supabase/migrations/0001_init.sql).
 */

/* ── Navegación y pantallas ─────────────────────────────────────────── */

export type TabId = 'inicio' | 'aprender' | 'tutor' | 'progreso' | 'mas';

/** Vista de nivel aplicación (controla el shell: con o sin barra inferior) */
export type AppView =
  | 'boot'        // cargando sesión / configuración
  | 'access'      // clave de acceso (primer ingreso o desbloqueo)
  | 'enroll'      // registro inicial: nombre, institución, curso, acudiente
  | 'tabs'        // navegación principal
  | 'reader'      // lector de una OVA
  | 'evidence'    // entrega de evidencia calificable
  | 'result';     // cierre de actividad

/* ── Dominio científico ─────────────────────────────────────────────── */

export type Subject = 'bio' | 'fis' | 'qui';

export const SUBJECT_LABEL: Record<Subject, string> = {
  bio: 'Biología',
  fis: 'Física',
  qui: 'Química',
};

/* ── Institución / curso ────────────────────────────────────────────── */

export interface Institution {
  id: string;
  name: string;
  city?: string | null;
  daneCode?: string | null;
}

/** Curso de décimo: `10A`, `10B`, … */
export interface Course {
  id: string;
  institutionId: string;
  grade: 10;
  label: string;        // '10A'
  schoolYear: number;   // 2026
  maxStudents: number;  // 45
}

/* ── Estudiante / participante ──────────────────────────────────────── */

/** Datos visibles para el investigador: SIN nombre. */
export interface Participant {
  id: string;
  participantCode: string;  // 'INS2-10B-0147'
  institutionId: string;
  courseId: string;
  createdAt: string;
}

/** Datos visibles solo para el docente del curso. */
export interface StudentIdentity {
  studentId: string;
  fullName: string;
  guardianName?: string | null;
  guardianConsent: boolean;
  consentVersion?: string | null;
  consentDate?: string | null;
}

export interface StudentSettings {
  textSize: 'normal' | 'large' | 'xlarge';
  openDyslexic: boolean;
  highContrast: boolean;
  darkMode: boolean;
  hideStreak: boolean;
  notifications: boolean;
}

export const DEFAULT_SETTINGS: StudentSettings = {
  textSize: 'normal',
  openDyslexic: false,
  highContrast: false,
  darkMode: false,
  hideStreak: false,
  notifications: false,
};

/* ── OVA (catálogo que crea el administrador) ───────────────────────── */

/** Cómo se abre un artefacto dentro de la app (nunca fuera de ella). */
export type ArtifactKind =
  | 'document'    // PDF, DOCX/PPTX convertido a PDF
  | 'image'       // PNG, JPG
  | 'audio'       // MP3, M4A
  | 'interactive' // H5P, SCORM, simulación HTML (iframe aislado)
  | 'video'       // solo por enlace externo
  | 'link';       // enlace externo embebido (YouTube, Genially)

export interface OvaArtifact {
  id: string;
  ovaId: string;
  kind: ArtifactKind;
  /** Ruta en Supabase Storage (null cuando es un enlace externo) */
  storagePath?: string | null;
  externalUrl?: string | null;
  mimeType?: string | null;
  sizeBytes?: number | null;
  /** sha256 del archivo: detecta cambios y da integridad de evidencia */
  checksum?: string | null;
  version: number;
  title: string;
  orderIndex: number;
  /** ¿Puede descargarse para uso sin internet? */
  offlineEligible: boolean;
  /** ¿Emite xAPI? (H5P y SCORM instrumentados sí) */
  emitsXapi: boolean;
}

export interface Ova {
  id: string;
  code?: string | null;       // 'OVA-02'
  title: string;
  description?: string | null;
  subject: Subject | 'multi';
  curriculumSkillIds: string[]; // ['OA-01', 'OA-03']
  coverImagePath?: string | null;
  estimatedMinutes: number;
  isPublished: boolean;
  createdAt: string;
  artifacts?: OvaArtifact[];
}

/* ── Asignación (lo que el docente manda) ───────────────────────────── */

export interface Assignment {
  id: string;
  ovaId: string;
  courseId: string;
  teacherId: string;
  title?: string | null;
  instructions?: string | null;
  opensAt?: string | null;
  dueAt?: string | null;
  evidenceRequired: boolean;
  maxEvidenceFiles: number;
  isGradable: boolean;
}

/** Estado de un estudiante frente a una asignación */
export type AssignmentState = 'pendiente' | 'en_progreso' | 'entregado' | 'calificado';

export interface AssignmentForStudent extends Assignment {
  ova: Ova;
  state: AssignmentState;
  grade?: number | null;
  lastOpenedAt?: string | null;
  progressPercent: number;
}

/* ── Evidencia calificable ──────────────────────────────────────────── */

export type EvidenceKind = 'text' | 'photo' | 'file';

export interface EvidenceFile {
  storagePath: string;
  mimeType: string;
  sizeBytes: number;
  originalName: string;
}

export interface Submission {
  id: string;
  assignmentId: string;
  studentId: string;
  textAnswer?: string | null;
  files: EvidenceFile[];
  submittedAt: string;
  /** true si se envió desde la cola offline al reconectar */
  wasOffline: boolean;
  teacherComment?: string | null;
  grade?: number | null;
  gradedAt?: string | null;
}

/* ── Bitácora reflexiva ─────────────────────────────────────────────── */

export interface Reflection {
  id: string;
  studentId: string;
  assignmentId?: string | null;
  ovaId?: string | null;
  prompt: string;
  text: string;
  createdAt: string;
}

/* ── Notas de pruebas externas (opcional, autoreportadas) ───────────── */

export interface ExternalScore {
  id: string;
  studentId: string;
  testName: string;     // 'Saber 11', 'Simulacro institucional', …
  testDate: string;
  score: number;
  scaleMax?: number | null;
  notes?: string | null;
  /** Siempre true: las reporta el estudiante, no una fuente oficial */
  selfReported: true;
}

/* ── Tutor IA ───────────────────────────────────────────────────────── */

export interface ChatMessage {
  id: string;
  conversationId: string;
  role: 'student' | 'tutor';
  content: string;
  createdAt: string;
  /** Nivel de andamiaje entregado (1 = pista leve, 4 = casi la respuesta) */
  hintLevel?: number | null;
  model?: string | null;
  tokensIn?: number | null;
  tokensOut?: number | null;
  latencyMs?: number | null;
  feedback?: 'util' | 'mas_pista' | null;
}

/* ── Insignias ──────────────────────────────────────────────────────── */

export interface Badge {
  code: string;
  title: string;
  description: string;
  icon: string;
  unlocked: boolean;
  unlockedAt?: string | null;
}

/* ── Racha ──────────────────────────────────────────────────────────── */

export interface StreakState {
  currentDays: number;
  bestDays: number;
  /** Últimos 7 días: true si hubo actividad */
  week: boolean[];
  todayIndex: number; // 0 = lunes … 6 = domingo
}
