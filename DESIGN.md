# Glacier — Glassmorphism

## North Star: "Frozen Light"
Ethereal depth through layered translucent surfaces. Dark, atmospheric, and premium.

## Colors
- **Primary (`text-[#7dd3fc]`, `border-sky-300/10`, `bg-sky-300/10`):** Ice-blue for interactive elements and accents.
- **Background (`bg-[#0a0e1a]`):** Deep navy-black base.
- **Tertiary (`text-[#c8a0f0]`):** Soft lavender for secondary accents.
- All surface containers should feel like tinted glass layers.

## Glass Effect (Core Pattern)
- **Cards/Panels:** `bg-[rgba(15,21,36,0.6)] backdrop-blur-lg border border-sky-300/10`.
- **Elevated glass:** Increase opacity to 0.75 and blur to 24px with `bg-[rgba(15,21,36,0.75)] backdrop-blur-xl`.
- **Borders:** Always use semi-transparent primary or white at 8-15% opacity, such as `border-sky-300/10` or `border-white/10` through `border-white/15`.

## Typography
- **All fonts:** Inter for clean, modern readability; use `font-[Inter]` (ensure Inter is loaded by the application).
- Headlines: `font-semibold tracking-wide`. Body: `font-normal`.
- Text colors: `text-[var(--on-surface)]` for primary, `text-[var(--on-surface-variant)]` for secondary.

## Elevation
- Depth through blur intensity and opacity, not shadows.
- Layer 0: `bg-[#0a0e1a]` solid background. Layer 1: `bg-[rgba(15,21,36,0.6)] backdrop-blur-lg` (60% opacity + 16px blur). Layer 2: `bg-[rgba(15,21,36,0.75)] backdrop-blur-xl` (75% + 24px blur).
- Subtle glow effects: `shadow-[0_0_30px_rgba(125,211,252,0.05)]`.

## Components
- **Buttons:** Primary = `bg-sky-300/10 border border-sky-300/15 text-[#7dd3fc]`. Hover = increase opacity with `hover:bg-sky-300/20 transition-colors`.
- **Cards:** `bg-[rgba(15,21,36,0.6)] backdrop-blur-lg border border-sky-300/10` for frosted glass with thin luminous border.
- **Inputs:** Glass background and thin border with a glow on focus, e.g. `bg-[rgba(15,21,36,0.6)] border border-white/10 focus:border-sky-300/30 focus:shadow-[0_0_30px_rgba(125,211,252,0.05)] focus:outline-none`.

## Rules
- Never use opaque solid backgrounds on floating elements; use translucent arbitrary-value backgrounds such as `bg-[rgba(15,21,36,0.6)]`.
- Keep borders subtle — luminous, not structural; use `border-sky-300/10` to `border-sky-300/15` or equivalent white opacity utilities.
- Limit glow effects to interactive states, such as `focus:shadow-[0_0_30px_rgba(125,211,252,0.05)]`.
