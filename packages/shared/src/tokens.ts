/**
 * OVA-IA · tokens de diseño
 *
 * Fuente única de verdad para colores, tipografía y espaciado.
 * Se consume de dos maneras:
 *   1. tokens.css  → variables CSS + `@theme` de Tailwind v4
 *   2. este archivo → valores en TypeScript para lógica (grafos, canvas, PDF)
 *
 * Correcciones aplicadas sobre el export de Stitch:
 *   - La racha deja de usar el color de Química (#872d00) y usa ámbar de marca.
 *   - Los dominios quedan exclusivos: Biología, Física, Química y Racha no comparten color.
 *   - Se separa "borde de tarjeta" que faltaba en el sistema original.
 */

/** Colores base del sistema (Material 3 · paleta institucional) */
export const colors = {
  surface: '#f8f9ff',
  surfaceDim: '#cbdbf5',
  surfaceContainerLowest: '#ffffff',
  surfaceContainerLow: '#eff4ff',
  surfaceContainer: '#e5eeff',
  surfaceContainerHigh: '#dce9ff',
  surfaceContainerHighest: '#d3e4fe',

  onSurface: '#0b1c30',
  onSurfaceVariant: '#444653',
  outline: '#5f6070', // oscurecido desde #757684 → contraste AA en texto de 11–13 px
  outlineVariant: '#c4c5d5',

  primary: '#00288e',
  onPrimary: '#ffffff',
  primaryContainer: '#1e40af',
  onPrimaryContainer: '#a8b8ff',
  primaryFixed: '#dde1ff',
  onPrimaryFixedVariant: '#173bab',

  secondary: '#006c4a',
  onSecondary: '#ffffff',
  secondaryContainer: '#82f5c1',
  onSecondaryContainer: '#00714e',
  secondaryFixed: '#85f8c4',
  onSecondaryFixedVariant: '#005137',

  tertiary: '#611e00',
  onTertiary: '#ffffff',
  tertiaryContainer: '#872d00',
  onTertiaryContainer: '#ffa582',
  tertiaryFixed: '#ffdbce',
  onTertiaryFixedVariant: '#7f2b00',

  error: '#ba1a1a',
  onError: '#ffffff',
  errorContainer: '#ffdad6',
  onErrorContainer: '#93000a',

  // Modo oscuro
  darkBackground: '#0d1522',
  darkSurface: '#131f31',
  darkSurfaceContainer: '#1a2840',
  darkOnSurface: '#eaf1ff',
  darkOnSurfaceVariant: '#b3c3de',
  darkOutline: '#8a95a8',
} as const;

/** Color exclusivo por dominio científico */
export const domain = {
  bio: {
    label: 'Biología',
    accent: '#006c4a',
    soft: '#82f5c1',
    onSoft: '#005137',
    chip: { bg: '#d1fae5', fg: '#065f46' },
  },
  fis: {
    label: 'Física',
    accent: '#1e40af',
    soft: '#dde1ff',
    onSoft: '#173bab',
    chip: { bg: '#dbeafe', fg: '#1e3a8a' },
  },
  qui: {
    label: 'Química',
    accent: '#c2410c', // naranja de marca (antes era marrón #872d00)
    soft: '#ffdbce',
    onSoft: '#7f2b00',
    chip: { bg: '#ffedd5', fg: '#9a3412' },
  },
} as const;

/**
 * Racha: token propio, exclusivo.
 * Antes compartía #872d00 con Química, lo que rompía el mapeo cognitivo por color.
 */
export const streak = {
  accent: '#b45309', // ámbar oscurecido: pasa AA sobre superficies claras
  soft: '#fef3c7',
  onSoft: '#78350f',
} as const;

/** Tipografía (Inter + JetBrains Mono) */
export const typography = {
  bodyMd: { fontSize: '14px', lineHeight: '22px', fontWeight: 400 },
  bodySm: { fontSize: '13px', lineHeight: '18px', fontWeight: 400 },
  bodyLg: { fontSize: '16px', lineHeight: '26px', fontWeight: 400 },
  titleMd: { fontSize: '16px', lineHeight: '24px', fontWeight: 600 },
  titleLg: { fontSize: '18px', lineHeight: '26px', fontWeight: 600 },
  headlineMd: { fontSize: '20px', lineHeight: '28px', fontWeight: 600 },
  labelSm: { fontSize: '11px', lineHeight: '14px', fontWeight: 500, letterSpacing: '0.03em' },
  labelMd: { fontSize: '12px', lineHeight: '16px', fontWeight: 600, letterSpacing: '0.02em' },
  codeSm: { fontSize: '13px', lineHeight: '18px', fontWeight: 400 },
} as const;

/** Radios (regla única: tarjeta 16 px, botón/campo 8 px, chip pill) */
export const radius = {
  button: '0.5rem',
  card: '1rem',
  chip: '9999px',
} as const;

/** Sombras (elevación definida, no utilidades genéricas) */
export const elevation = {
  resting: '0 1px 3px 0 rgba(15, 23, 42, 0.05), 0 1px 2px -1px rgba(15, 23, 42, 0.05)',
  interactive: '0 4px 6px -1px rgba(30, 64, 175, 0.07), 0 2px 4px -2px rgba(30, 64, 175, 0.05)',
  floating: '0 10px 15px -3px rgba(15, 23, 42, 0.08), 0 4px 6px -4px rgba(15, 23, 42, 0.04)',
} as const;

/** Límites de dominio del estudio */
export const researchLimits = {
  maxStudentsPerCourse: 45,
  warnStudentsPerCourse: 40,
  maxCoursesPerInstitution: 6,
  maxUploadBytes: 25 * 1024 * 1024, // 25 MB por artefacto
  allowedUploadExtensions: [
    'pdf', 'png', 'jpg', 'jpeg', 'webp', 'gif', 'svg',
    'mp3', 'm4a', 'ogg', 'wav',
    'h5p', 'zip',
    'docx', 'pptx', 'xlsx',
    'txt', 'md',
  ],
} as const;
