# Hyperframes Composition Brief: Blur Glass

## Objective
Create a short launch-style brag video for Blur Glass.

## Output
- Composition directory: `brag-output/composition/`
- Rendered video: `brag-output/brag.mp4`
- Format: landscape — 1920x1080
- Duration: 19.5s

## Source Material
- Project root: `/Users/utkarsh/Documents/blur_glass`
- Primary files read: `README.md`, `lib/widgets/popover/blur_glass_popover.dart`, `lib/widgets/common/brand_mark.dart`, `lib/theme/app_colors.dart`, `docs/BUILD_PLAN.md`
- Product name: Blur Glass
- Tagline / strongest claim: "The moment you look away, leave the frame, or a second face appears, a frosted shield covers the entire desktop — over Safari, over YouTube, over every app and Space — so only you can see what is on screen."
- Key UI or visual moment to recreate:
  - macOS frosted glass Popover card with Aperture Iris brand mark
  - "Screen Privacy" card with toggle switch
  - Dynamic status dot & label ("Screen clear" in green, "Extra face detected — Screen blurred" in red)
  - Full-screen desktop frost shield with intense backdrop blur
- Copy that must appear verbatim:
  - "Blur Glass"
  - "Screen privacy, naturally."
  - "Screen Privacy"
  - "Blur when you look away"
  - "Screen clear"
  - "Extra face detected — Screen blurred"
  - "Looking away — Screen blurred"

## Creative Direction
- Tone preset: polished
- Creative direction: Sleek Apple product film meets cybersecurity magic
- Interpretation: Confident, restrained, fluid motion. Every transition feels like native macOS desktop animation. High contrast and gorgeous dark-mode frosted glass.
- Angle: You can finally work in public without anyone seeing your screen. The moment a second face appears or you look away, Blur Glass instantly frosts the entire desktop.
- Hook: "Your screen is for your eyes only."
- Outro / punchline: "Blur Glass. Screen privacy, naturally."
- Avoid:
  - Generic SaaS marketing language
  - Abstract filler visuals
  - Low-resolution textures or non-macOS UI aesthetics

## Visual Identity
- Background: #141518 (dark canvas), #1E2026 (dark surface)
- Text: #F7F7F8 (primary), #9EACB9 (secondary)
- Accent: #007AFF (macOS system blue), #34C759 (vibrant green), #FF453A (vibrant red), #FF9F0A (amber)
- Display font: -apple-system, BlinkMacSystemFont, "SF Pro Display", "Inter", sans-serif
- Body font: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Inter", sans-serif
- Visual references from the project:
  - Frosted glass popover card with 30px backdrop blur, subtle 1px white border (alpha 0.18)
  - Aperture Iris icon (48x48 squircle with gradient blue #2C92FF to #0066EB and aperture dots)
  - macOS blue pill toggle switch
  - Desktop mock (Safari window, code editor, terminal) covered by the full-screen frosted NSPanel shield

## Storyboard
Use the storyboard in `brag-output/brag-plan.md` as the creative contract.

Scene summary:
1. Scene 1 — The Hook — 0.00s to 4.39s (4.39s) — Hook typography: "Your screen is for your eyes only." -> "No shoulder surfers. No wandering eyes."
2. Scene 2 — Active Protection — 4.39s to 8.74s (4.35s) — Menu bar popover glides down, toggle flips ON, status dot glows green: "Screen clear".
3. Scene 3 — The Intruder Trigger — 8.74s to 13.11s (4.37s) — [Beat-locked 8.74s] Threat detected! Status dot pulses red: "Extra face detected — Screen blurred", entire desktop instantly frosts over.
4. Scene 4 — 100% On-Device Privacy — 13.11s to 16.93s (3.82s) — [Beat-locked 13.11s] Three cards arrive on beat grid (13.64s, 14.20s, 14.73s): Apple Vision Framework, Encrypted in Keychain, 0 Cloud Telemetry.
5. Scene 5 — Outro & Punchline — 16.93s to 19.50s (2.57s) — [Beat-locked 17.47s] Illuminated Aperture Iris logo lock, "Blur Glass", "Screen privacy, naturally."

## Audio
- Audio role: Cinematic polished support
- Audio arc: Ambient intrigue -> tactile UI interaction -> high-impact security trigger -> rhythmic engineering confidence -> resonant brand resolve.
- Music: `assets/music/happy-beats-business-moves-vol-12-by-ende-dot-app.mp3`
- Music treatment: volume 0.28, fade out gently over the last 1.5s
- Music cue guidance: Bundled track preset. Target strong cues at 8.74s, 13.11s, and 17.47s. Beat grid for sequential items: 13.64s, 14.20s, 14.73s.
- Audio-reactive treatment: Subtle; hero iris logo glow breathes gently with music energy.
- Audio-coupled moments:
  - 5.5s: Switch toggle click (`assets/sfx/interface/switch_001.ogg`)
  - 8.74s: Instant blur shield impact (`assets/sfx/impact/impactSoft_medium_000.ogg`)
  - 13.64s, 14.20s, 14.73s: Sequential security badge drops (`assets/sfx/interface/drop_001.ogg`)
  - 17.47s: Final brand chime (`assets/sfx/impact/impactBell_heavy_000.ogg`)
- SFX selection guidance: Crisp, tactile macOS interaction sounds.

## Hyperframes Instructions
Build a self-contained Hyperframes composition inside `brag-output/composition/`.
- Ensure `npx hyperframes check` passes with 0 errors.
- Ensure all fonts, styles, and assets are locally bundled or standard system fonts.
- Ensure audio is placed with proper `data-track-index`, `data-start`, `data-duration`, `data-volume`.
