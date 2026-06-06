---
name: Mindow
status: final
created: 2026-06-05
updated: 2026-06-05
description: Mental-load relief companion. Warm, calm, anti-productivity. Dawn-gradient "Aurore" identity — lightness returning, never another to-do list.
colors:
  bg-dawn-1: '#FDF4F0'
  bg-dawn-2: '#F6ECF2'
  bg-dawn-3: '#EDE9F4'
  accent-warm: '#E8A87C'
  accent-warm-light: '#F6C9A8'
  accent-warm-lighter: '#FBD8BD'
  accent-cool: '#B98BB0'
  ink-primary: '#5B5470'
  ink-muted: '#9B91AC'
  surface-glass: 'rgba(255,255,255,0.55)'
  surface-glass-strong: 'rgba(255,255,255,0.65)'
  hairline-glass: 'rgba(255,255,255,0.70)'
  on-accent: '#FFFFFF'
typography:
  display:
    note: 'kg figure — Inter Bold 88, gradient fill (accent-warm → accent-cool). The single hero numeral.'
  title:
    note: 'Screen titles — iOS Title 2 / Android Headline Small. Inter Semi Bold ~24–28.'
  body:
    note: 'Primary copy — iOS Body / Android Body Large. Inter Medium ~15.'
  meta:
    note: 'Captions, pills, tags — iOS Footnote / Android Body Small. Inter Medium ~11–14.'
rounded:
  sm: 14px
  md: 20px
  lg: 24px
  pill: 999px
spacing:
  '1': 4px
  '2': 8px
  '3': 12px
  '4': 16px
  '5': 24px
  '6': 32px
gradients:
  dawn: 'linear 150° — bg-dawn-1 0% → bg-dawn-2 50% → bg-dawn-3 100% (the app canvas)'
  aurore: 'linear 120° — accent-warm → accent-cool (kg figure, primary CTA, premium badge, illustration orb)'
  glow: 'radial — accent-warm-light @55% → transparent (backpack halo, onboarding orb halo)'
components:
  backpack: 'Hero metaphor — peach gradient body with inner-white + warm drop shadow, radial glow, handle/lid/side-pockets/front-pocket+buckle.'
  glass-card: 'Frosted white surface, hairline border, soft low shadow. Holds missions, steps, pills.'
  pill: 'Stat capsule — glass, value (Inter Bold) over label (ink-muted).'
  cta: 'Aurore-gradient button, white label, warm drop shadow.'
---

> Visual identity for Mindow. Direction **C · Aurore**. Single-surface mobile-first (iOS / Android / Web). Paired with `EXPERIENCE.md`. Both spines win on conflict with any mock or import. Key-screen mocks: `.working/screens-aurore.html` (Figma hero built at file `KUDjcBBwJvCZK8dw6hxvOh`, node 7:2).

## Brand & Style

Mindow is the anti-productivity app. It exists to make a weight *lighter*, never to add another line to a list. Where task managers shout urgency in red and reward streaks, Mindow speaks in the register of a calm exhale at dawn — the moment before the day's load is picked up, when relief still feels possible.

The visual identity is **Aurore**: a soft sunrise gradient washing peach into mauve, a single glowing backpack that holds the user's mental weight, and numerals that bloom in warm-to-cool gradient. Nothing is sharp, clinical, or loud. The system uses warm French *tutoiement* in copy (see `EXPERIENCE.md.Voice and Tone`) and an emotional, reassuring tone throughout. Every visual decision answers one question: *does this make the user feel lighter, or heavier?*

The metaphor is physical and felt — a **mental backpack** you put things into and take things out of, measured in kilos, not tasks. Progress is shown as weight lifting, not boxes checked.

## Colors

The palette is a dawn sky — warm where the sun rises, cool where night still lingers. It is intentionally low-contrast and luminous so the surface feels like light, not like a form.

- **Dawn canvas (`#FDF4F0` → `#F6ECF2` → `#EDE9F4`)** is the app background, always rendered as a diagonal gradient. It is the sky at first light. Never use a flat fill for primary surfaces.
- **Warm accent (`#E8A87C`)** and its lighter steps (`#F6C9A8`, `#FBD8BD`) carry the backpack, warmth, and the start of every gradient. This is the rising sun.
- **Cool accent (`#B98BB0`)** is the mauve that closes every gradient and tints secondary tags and step markers. This is the fading night.
- **Aurore gradient (warm → cool)** is the signature: it fills the hero kg figure, the primary CTA, the premium badge, and the onboarding orb. Reserve it for moments of weight, action, and meaning.
- **Ink (`#5B5470`)** is the primary text — a soft desaturated plum, never pure black. **Muted (`#9B91AC`)** carries captions, placeholders, and secondary labels.
- **Glass (`rgba(255,255,255,0.55–0.70)`)** with a brighter hairline border is the frosted surface for cards, pills, and inputs — light resting on light.

Avoid: pure black or pure white text, saturated red/green status fills, hard flat backgrounds, and any color that reads as alarm. Errors and gentleness share the same warm vocabulary (see Do's and Don'ts).

## Typography

**Inter** across platforms, deferring to platform dynamic-type scaling. Style names follow Inter's spelling: `Semi Bold`, `Extra Bold` (with the space).

- **Display** is reserved for the single kg figure on the home screen — Inter Bold ~88, filled with the Aurore gradient. There is exactly one display element per screen, and usually only on Home.
- **Title** (Inter Semi Bold ~24–28) sets screen headers: *"Respire, Camille ✨"*, *"Ta mission du jour"*.
- **Body** (Inter Medium ~15) carries mission descriptions and value copy at 1.5 line-height for calm reading.
- **Meta** (Inter Medium ~11–14, often with +1% letter-spacing) labels pills, tags, captions, and the home indicator microcopy.

No all-caps, no condensed faces, no display sizes beyond the kg figure. Dynamic type must render legibly at the largest accessibility setting without truncation.

## Layout & Spacing

Scale: 4 / 8 / 12 / 16 / 24 / 32 px. Screen horizontal margin is **24px**. Single column, mobile-first (iOS / Android / Web responsive down to one column).

Each screen is a vertical stack with a flexible spacer that pins the primary CTA to the bottom safe area, so the canvas above breathes and the action is always thumb-reachable. iOS status bar at top, home indicator at bottom on every screen. Generous vertical rhythm — the backpack and kg figure are given room; nothing is compressed to fit more.

## Elevation & Depth

Depth is *luminous*, not heavy. Two devices only:

- **Glow** — radial warm halos behind the backpack and the onboarding orb, suggesting inner light rather than a cast shadow.
- **Soft glass shadow** — low-opacity ink-tinted drop shadows under cards, pills, and the CTA (e.g. `0 8px 18px rgba(91,84,112,0.08)`; CTA uses a warm `rgba(232,168,124,0.4)`).

The backpack additionally carries an inner white highlight (top) to read as gently lit. No hard, dark, or high-offset shadows anywhere.

## Shapes

Everything is soft. `rounded/sm` (14px) for tags and small chips, `rounded/md` (20px) for pills, glass cards, and inputs, `rounded/lg` (24px) for the primary CTA and large cards. The backpack body uses a large 46px radius. `rounded/pill` for stat capsules and progress dots. The active progress dot is a stadium (elongated pill); inactive dots are circles. No square corners, no hard edges.

## Components

- **Backpack** — the hero metaphor on Home. Peach gradient body (`accent-warm-light` → `accent-warm`), radial warm glow behind, with handle, top lid, two side pockets, and a front pocket closed by a buckle strap. Inner white highlight + warm drop shadow make it glow. It visually holds the user's mental weight.
- **kg figure** — the single display numeral, Aurore-gradient filled, with a smaller cool `kg` unit baseline-aligned and a muted caption beneath (*"sur tes épaules"*).
- **Glass card** — frosted white surface, hairline border, soft shadow. Container for missions, decomposition steps, and grouped content.
- **Stat pill** — glass capsule, bold value over muted label (*12 ouvertes · −6 kg cette semaine · série 5 j*). Always positive framing.
- **Primary CTA** — full-width Aurore-gradient button, white Semi Bold label, warm drop shadow. One per screen.
- **Secondary action** — text-only link in `ink-muted` (*"Plus tard"*, *"Passer"*), never a competing filled button.
- **Step row** (decomposition) — glass row with a numbered marker; completed steps fill the marker with the Aurore gradient + checkmark and dim to ~62% opacity. Weight per step shown in cool accent.
- **Weight tag** — small cool-tinted chip showing a kilo estimate (*"≈ 4 kg"*).
- **Premium badge** — Aurore-gradient chip with a ✦ glyph.
- **Input field** — glass surface, muted placeholder, no hard border.
- **Progress dots** — active = Aurore-gradient stadium; inactive = muted circles.

## Do's and Don'ts

| Do | Don't |
|---|---|
| Render the canvas as the dawn gradient | Use a flat background fill on primary surfaces |
| Reserve the Aurore gradient for weight, action, and meaning | Spray the gradient on every element |
| Show progress as weight *lifting* (−6 kg, kilos off) | Show streaks, scores, or boxes-checked as the reward |
| Speak gentleness in warm tones; let "errors" feel soft | Use red/green status fills or alarm colors |
| One display numeral, one primary CTA per screen | Stack multiple loud focal points |
| Soft glows and low glass shadows for depth | Hard, dark, high-offset drop shadows |
| Soft desaturated ink (`#5B5470`) for text | Pure black or pure white text |
| Keep one positive-only framing on every stat | Frame any metric as guilt, debt, or failure |
