# Blur Glass

Privacy-first macOS app: the screen is readable **only by the enrolled owner
sitting in front of it**. The moment you look away, leave the frame, or a second
face appears, a frosted shield covers the **entire desktop** — over Safari, over
YouTube, over every app and Space — so only you can see what is on screen.

All face processing happens **on-device**: camera frames run through Apple's
Vision framework, owner templates are stored encrypted in your Keychain, and
nothing is ever uploaded.

## How it works

```
Camera (10 fps, on-device) ──▶ Vision (faces, head pose, feature print)
        │                              │
        ▼                              ▼
  AttentionEngine ───────────▶ ScreenShieldController
  (debounced policy:               (frosted NSPanel per display,
   stranger / extra face /          covers all Spaces & fullscreen
   look-away / no face)             apps, below the menu bar)
```

- **AttentionEngine** debounces every trigger (extra face 150 ms, look-away
  180 ms, no-face 500 ms) and needs a stable 350 ms of "owner present" to clear.
- **Owner identity**: after Touch ID / password confirmation, ten on-device face
  feature prints are captured and stored in the Keychain
  (`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`).
- **Shield windows** live at the assistive-tech window level, join all Spaces,
  and leave the menu bar uncovered so protection can always be paused.
- The **menu-bar eye icon** starts/pauses protection; the Flutter window is the
  control panel (onboarding, status, sensitivity tuning).

## Run it

```bash
flutter pub get
flutter run -d macos
```

macOS will prompt for **camera access** on first enrollment. If it was denied,
open System Settings → Privacy & Security → Camera and enable Blur Glass.

## Where things live

| Path | What it is |
|---|---|
| `lib/` | Flutter control panel (onboarding, dashboard, channel bridge) |
| `macos/Runner/Privacy/` | Native agent: camera, Vision, policy engine, shield |
| `docs/BUILD_PLAN.md` | Architecture + roadmap (gaze polish, Android/iOS later) |

## Status

Working: owner enrollment (Keychain-stored), protection with stranger /
extra-face / look-away / no-face triggers, system-wide frost shield, menu-bar
controls, sensitivity tuning.

Next: gaze-based finer triggers, launch-at-login, panic hotkey, Android/iOS
ports (see `docs/BUILD_PLAN.md`).
