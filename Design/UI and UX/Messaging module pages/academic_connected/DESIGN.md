---
name: Academic Connected
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
  on-surface-variant: '#434655'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#516070'
  on-secondary: '#ffffff'
  secondary-container: '#d5e4f8'
  on-secondary-container: '#576676'
  tertiary: '#006242'
  on-tertiary: '#ffffff'
  tertiary-container: '#007d55'
  on-tertiary-container: '#bdffdb'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#d5e4f8'
  secondary-fixed-dim: '#b9c8db'
  on-secondary-fixed: '#0e1d2b'
  on-secondary-fixed-variant: '#3a4858'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style
The design system targets campus communities, academic peers, and institutional collaborators navigating onboarding, login, verification, and profile claim flows. It blends Modern Corporate reliability with the approachable, energetic utility of higher-education networking.

Key principles:
- **Clarity over decorative noise**: Zero distraction during high-friction authentication touchpoints (SSO, OTP, password verification).
- **Institutional credibility**: Crisp white surfaces framed with architectural, clean slate boundaries evoke trust and peer-level professionalism.
- **Intentional micro-feedback**: Interactive states emit subtle optical shifts, ensuring students and faculty feel confirmed at every stage of account setup.

## Colors
The palette leverages a high-contrast core balanced by soft contextual washes:

- **Primary (`#2563EB`)**: Royal Blue anchors high-intent interactions—primary CTA buttons, active tab indicators, and focused input borders.
- **Secondary (`#DBEAFE`)**: Soft Ice Blue provides tint layers for active state fills, icon badges, and contextual highlights.
- **Tertiary / Accent (`#10B981`)**: Emerald green signals successful authentication checks, password validation strength, and active campus status.
- **Neutral Core**:
  - Background Canvas: `#F8FAFC` (Clean slate off-white) prevents screen glare on mobile displays.
  - Surface/Card Layer: `#FFFFFF` (Pure white).
  - Primary Text / Headings: `#0F172A` (Deep navy) ensures maximum legibility.
  - Muted Text / Captions: `#64748B` (Slate medium).
  - Outlines & Dividers: `#E2E8F0` (Subtle boundary line).
  - Error: `#EF4444` (Precise validation feedback).

## Typography
Plus Jakarta Sans is utilized across all tiers to deliver contemporary geometry with balanced terminal curves. 

Mobile execution guidelines:
- Auth screens rely primarily on `headline-lg` for top-level view context ("Welcome back", "Verify campus email").
- Input fields use `body-md` for user entry and `label-md` for floating or static field headers.
- Legal copy, disclaimers, and password rule lists leverage `body-sm` set in `#64748B`.
- Keep titles to tight letter spacing (`-0.015em` to `-0.02em`) to maintain editorial punch within constrained mobile widths.

## Layout & Spacing
Built primarily around a mobile-first fluid layout that locks cleanly into centered sheets on tablet viewports:

- **Horizontal Bleed & Safe Areas**: Standard mobile screens enforce an outer horizontal margin of `1.25rem` (20px). On large screens/tablets, auth cards center with a maximum width of `440px`.
- **Vertical Hierarchy**: Auth flow sections leverage `space-lg` (24px) between distinct conceptual blocks (e.g., logo mark to header group, form fields to CTA container).
- **Form Group Spacing**: Sequential text inputs maintain `space-md` (16px) separation. Related micro-elements (input helper text, inline error prompts) use `space-xs` (4px) offset from their parent field.

## Elevation & Depth
Depth is built on clean white planes resting upon `#F8FAFC`, relying on featherweight shadows and border boundaries rather than heavy dark drop shadows.

- **Level 0 (Flat Canvas)**: Background canvas (`#F8FAFC`) with no shadow.
- **Level 1 (Card / Container)**: Pure white `#FFFFFF` surface bordered by a 1px `#E2E8F0` stroke with `shadow-sm` (`0 1px 3px rgba(15, 23, 42, 0.05), 0 1px 2px rgba(15, 23, 42, 0.03)`). Used for form card wrappers and social SSO cards.
- **Level 2 (Floating Action / Active Popover)**: Focused interactive containers, bottom sheet dialogs, and primary buttons use `shadow-md` (`0 4px 6px -1px rgba(37, 99, 235, 0.12), 0 2px 4px -2px rgba(15, 23, 42, 0.06)`), infusing a faint blue ambient reflection into elevated primary targets.
- **Level 3 (Modal Dialogs)**: `0 20px 25px -5px rgba(15, 23, 42, 0.08), 0 8px 10px -6px rgba(15, 23, 42, 0.04)`.

## Shapes
The system relies on roundedness level `2` with specialized tokens tuned for mobile ergonomics:

- **Text Inputs & Standard Buttons**: Fixed 12px to 14px (`rounded-lg` feel) to fit standard tap boundaries.
- **Primary CTAs & Authentication Cards**: 16px radius (`rounded-xl`), creating inviting, touchable elements.
- **Campus Pills, Badges & Avatars**: Full-round pill styles (`9999px`) for institutional role chips (e.g., "Student", "Faculty", "Verified .edu").
- **Checkboxes & Verification Code Cells**: 8px (`rounded-md`) to ensure interior digit clarity.

## Components

### Buttons
- **Primary CTA**: Background `#2563EB`, text `#FFFFFF`, height 52px, corner radius 14px. Font `label-lg`. Pressed state drops to `#1D4ED8`. Elevation: `shadow-md` with royal blue ambient glow.
- **Secondary / Campus SSO**: White background, 1px `#E2E8F0` border, `#0F172A` text, 14px radius. Left-aligned institutional or OAuth SVG icon at 20x20px. Active press state triggers `#F1F5F9` background.
- **Tertiary / Ghost Text**: Minimalist text button in `#2563EB`, no border or shadow, 44px min touch target for secondary actions ("Forgot Password?", "Change Email").

### Input Fields
- **Container**: Height 52px, background `#FFFFFF`, border 1.5px `#E2E8F0`, corner radius 12px.
- **Typography**: Text inside is `body-md` (`#0F172A`). Placeholder is `#64748B`.
- **Adornments**: Leading icons (email envelope, key lock, id card) fixed at 20px `#64748B`. Trailing icon actions (password show/hide eye toggle) feature 40x40px touch bounds.
- **Focused State**: Border shifts smoothly to `#2563EB` paired with an outer focus halo of `0 0 0 3px #DBEAFE`.
- **Error State**: Border shifts to `#EF4444`, supported by a bottom message in `#EF4444` (`body-sm`).

### OTP / Pin Verification Input
- Set of 4 to 6 individual square cells (48px wide x 54px tall).
- Default border `#E2E8F0`, active cell `#2563EB` with `#DBEAFE` background tint. Text centered, `headline-md` weight.

### Chips & Role Selectors
- Background `#F1F5F9`, border none, 8px vertical padding, 16px horizontal, 9999px pill radius.
- Selected state switches background to `#DBEAFE`, text to `#2563EB`, border 1px `#2563EB`.

### Checkboxes & Segment Toggles
- **Checkbox**: 20x20px box, 6px radius, 1.5px border `#CBD5E1`. Checked state changes fill to `#2563EB` with white checkmark.
- Label positioned at `space-sm` offset, using `body-md` typography.

### Academic Identity Card / Success Module
- Pure white container with 16px radius, bounded by `#E2E8F0`.
- Includes verified green badge (`#10B981` background, `#FFFFFF` icon) along with campus association metadata.