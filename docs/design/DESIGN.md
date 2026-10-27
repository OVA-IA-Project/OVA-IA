---
name: Academic Science PWA
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#444653'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#757684'
  outline-variant: '#c4c5d5'
  surface-tint: '#3755c3'
  primary: '#00288e'
  on-primary: '#ffffff'
  primary-container: '#1e40af'
  on-primary-container: '#a8b8ff'
  inverse-primary: '#b8c4ff'
  secondary: '#006c4a'
  on-secondary: '#ffffff'
  secondary-container: '#82f5c1'
  on-secondary-container: '#00714e'
  tertiary: '#611e00'
  on-tertiary: '#ffffff'
  tertiary-container: '#872d00'
  on-tertiary-container: '#ffa582'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dde1ff'
  primary-fixed-dim: '#b8c4ff'
  on-primary-fixed: '#001453'
  on-primary-fixed-variant: '#173bab'
  secondary-fixed: '#85f8c4'
  secondary-fixed-dim: '#68dba9'
  on-secondary-fixed: '#002114'
  on-secondary-fixed-variant: '#005137'
  tertiary-fixed: '#ffdbce'
  tertiary-fixed-dim: '#ffb599'
  on-tertiary-fixed: '#370e00'
  on-tertiary-fixed-variant: '#7f2b00'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '600'
    lineHeight: 38px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.03em
  code-sm:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system is engineered for 10th-grade Colombian high school students (ages 15–16) engaging with artificial intelligence in science education. Rooted in doctoral empirical research, the system balances rigorous pedagogical authority with an inviting, modern digital experience. 

The aesthetic is clean, academic, and dynamic—deliberately steering clear of playful primary-school gamification while avoiding cold, sterile enterprise SaaS conventions. It fosters intellectual curiosity, psychological safety in human-AI dialogue, and focused scientific inquiry. 

Key principles:
- **Academic Rigor Meets Contemporary Youth Utility:** Crisp typography, deliberate whitespace, and disciplined data presentation convey credibility and seriousness without intimidating students.
- **Cognitive Clarity:** Visual noise is minimized to preserve working memory during complex conceptual problem-solving across physics, chemistry, and biology.
- **Safe & Transparent Interaction:** Distinct UI treatments demarcate student inputs, validated scientific curricula, and AI-mediated dialectic responses.

## Colors

The palette establishes an authoritative institutional foundation complemented by subject-specific accents that serve cognitive mapping across different scientific domains:

- **Primary (`#1E40AF`):** Deep academic blue anchoring global application chrome, primary actions, and institutional navigation.
- **Biology Domain (`#059669`):** Vibrant emerald green applied exclusively to biological modules, cellular mechanics, and ecological inquiry.
- **Physics Domain (`#2563EB`):** Dynamic royal blue applied to physical sciences, kinematics, and quantitative calculations.
- **Chemistry Domain (`#EA580C`):** Energetic orange applied to reaction kinetics, molecular chemistry, and stoichiometry.
- **Streak & Alert (`#F59E0B`):** Warm amber dedicated to learning streaks, motivational milestones, and soft heuristic warnings.
- **Surfaces & Canvases:**
  - Light Mode: Canvas default `#F8FAFC` (Slate-50) paired with pristine `#FFFFFF` card layers to sustain optical depth and separation.
  - Dark Mode: Canvas default `#0F172A` (Slate-900) paired with elevated container `#1E293B` (Slate-800).
- **Text & Contrast:** Primary text `#0F172A` in light mode achieves strict WCAG 2.1 AA compliance across all operational contexts.

## Typography

Typography relies on `Inter` across all text hierarchies for optimal rendering on low-to-mid-tier Android mobile displays commonly used by public and private school students in Colombia. Mathematical notation, pseudonyms, and scientific formula data leverage `JetBrains Mono` for structural clarity.

Line heights are set deliberately open to ensure continuous reading comfort on mobile screens during lengthy scientific explanations and multi-turn AI interactions. High-contrast type weights (regular `400` vs. semi-bold `600`) establish immediate visual hierarchy without relying on heavy font scales that crowd smaller viewports.

## Layout & Spacing

This design system uses a mobile-first fluid layout architecture centered around standard handheld ergonomics:

- **Mobile Canvas (< 640px):** Single column fluid container bounded by a minimum horizontal margin of `1rem` (16px) and vertical gutter spacing of `1rem`. All touch-accessible action areas conform to a strict minimum physical size of 44×44px. Bottom content retains a padding offset of at least `5.5rem` to account for the fixed bottom navigation bar and mobile browser chrome.
- **Tablet / Large Mobile (640px – 1024px):** Shifts to an 8-column layout with `1.25rem` gutters. Content containers are capped at `768px` for focused instructional modules.
- **Desktop / Research Workstation (> 1024px):** Max container width of `1120px` with a 12-column grid and `1.5rem` gutters. The bottom navigation bar transitions into a left-hand vertical rail, freeing central real estate for side-by-side dialectic AI dialogues and scientific modeling worksheets.

## Elevation & Depth

Visual hierarchy uses crisp surface tonal contrast paired with soft ambient shadows, avoiding heavy, skeuomorphic, or distracting effects:

- **Canvas Level (Elevation 0):** Neutral base (`#F8FAFC` light / `#0F172A` dark) creates zero-reflection background space.
- **Resting Card / Container (Elevation 1):** Solid white surface (`#FFFFFF` light / `#1E293B` dark) outlined with an ultra-subtle border (`1px solid #E2E8F0` light / `1px solid #334155` dark) alongside `box-shadow: 0 1px 3px 0 rgba(15, 23, 42, 0.05), 0 1px 2px -1px rgba(15, 23, 42, 0.05)`.
- **Interactive / Hover / Active Cards (Elevation 2):** Elevated interactive elements cast an ambient blue-tinted drop shadow: `box-shadow: 0 4px 6px -1px rgba(30, 64, 175, 0.07), 0 2px 4px -2px rgba(30, 64, 175, 0.05)`.
- **Modals, Drawers & Bottom Sheets (Elevation 3):** Floated learning assists and bottom navigation panels use `box-shadow: 0 10px 15px -3px rgba(15, 23, 42, 0.08), 0 4px 6px -4px rgba(15, 23, 42, 0.04)`.
- **Bottom Navigation Surface:** Features an elevated frosted backing layer (`backdrop-filter: blur(12px)`) with a top border rule (`1px solid #E2E8F0` light / `1px solid #334155` dark) and a subtle negative vertical shadow for distinct touch separation.

## Shapes

The shape system employs roundedness index 2 (base radius `0.5rem` / 8px) with key layout cards scaled to a consistent, prominent 16px (`rounded-lg` / `1rem`) corner radius. This creates a tactile, approachable feel appropriate for adolescents without appearing juvenile.

- **Cards & Modals:** Standardized 16px (`1rem`) border radius.
- **Buttons & Input Fields:** 8px (`0.5rem`) border radius for structural stability and clear visual affordance.
- **Chips, Badges & Interactive Tags:** Full pill radius (`9999px`) to distinguish categorical metadata and subject tracks from actionable functional blocks.

## Components

### Buttons
- **Primary Action:** Solid deep blue (`#1E40AF`) background, white text, 8px radius, height 44px minimum for mobile ergonomics. Active state deepens to `#1D3994` with a subtle transform scale of `0.98`.
- **Subject Primary Buttons:** Dynamically adopt domain tokens (Biology: `#059669`, Chemistry: `#EA580C`, Physics: `#2563EB`).
- **Secondary / Outlined:** Transparent surface with a 1.5px border (`#E2E8F0`), slate text (`#1E293B`), active feedback with neutral slate tint.

### Bottom Navigation Bar (PWA Mobile)
- Fixed at viewport bottom, height 64px, z-index 50.
- Layout: 5 equal tap zones (Home, Learn, AI Tutor, Progress, More) spanning minimum 44×44px touch targets.
- Iconography: Lucide-style outline icons (24px, 2px stroke width). Active item receives `#1E40AF` color and a subtle 3px dot indicator beneath the icon; inactive items remain muted `#64748B`.
- The central AI Tutor item features an elevated badge ring to highlight real-time interactive pedagogy.

### Input Fields & Prompt Composer
- **Standard Input:** Crisp white card surface, 1px border (`#CBD5E1`), 8px border radius, 12px horizontal padding, placeholder text in `#94A3B8`. Focused state provides a crisp 2px primary blue ring with `0 0 0 3px rgba(30, 64, 175, 0.15)`.
- **AI Dialectic Chat Box:** Floating pinned field with inline submit control and voice-input affordance.

### Cards & Subject Tiles
- Encapsulated within 16px rounded borders.
- Top border or side indicator ribbon matches the subject domain color (Biology: emerald, Chemistry: orange, Physics: royal blue).
- High-contrast typography pairing: `title-md` header with `body-sm` description.

### Chips & Badges
- **Status Badges:** Pill shape (`9999px`), 4px vertical by 10px horizontal padding.
- **Domain Indicators:** Soft tonal backgrounds with high-contrast text (e.g., Biology chip: background `#ECFDF5`, text `#065F46`).
- **Pseudonym Identifier Tag:** Monospaced label badge (`JetBrains Mono`, uppercase, muted slate background) to display student research aliases (e.g., `EST-8492-CO`) to reinforce research ethics and privacy.

### Checkboxes & Radio Selectors
- Sized at 20×20px wrapped in a minimum 44px hit-box container.
- Selected state fills with subject or primary color and includes a clear, high-contrast checkmark/dot.