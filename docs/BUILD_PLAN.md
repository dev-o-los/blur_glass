# Blur Glass — Build Plan

Privacy-first macOS app: the screen is readable **only by the owner sitting in front of it**.
The moment you look away, walk away, or someone else enters the room, the **entire screen** —
over every app, every Space, every fullscreen window — turns into a live blurred surface.

Confirmed scope decisions:

| Decision | Choice |
|---|---|
| Blur style | **Live blurred backdrop** — real screen capture, blurred on GPU, shown fullscreen |
| Intruder trigger | **Any second face** (no identity comparison needed for the trigger) |
| Face-lost trigger | **Blur when owner face is lost** (walked away, camera covered, bad angle) |

Privacy rules baked into the architecture:

- **All face/gaze inference runs on-device.** No frames, embeddings, or telemetry ever leave the Mac.
- The screen capture buffer exists only in GPU memory of the blur pipeline; never written to disk.
- Camera permission and Screen Recording permission are requested separately, with clear copy.
- A panic kill-switch (configurable hotkey) instantly clears the blur and pauses the agent.

---

## 1. Architecture

The app is split into a **macOS agent** (native Swift, all privileged work) and a **Flutter UI
shell** (settings, enrollment, status). The agent is the source of truth; Flutter talks to it
over a local method channel. This keeps the heavy lifting in AppKit/AVFoundation/ScreenCaptureKit
where it is reliable, and lets the Flutter codebase stay portable for the later Android/iOS ports.

```
┌────────────────────────────────────────────────────────────┐
│                    Blur Glass.app                          │
│                                                            │
│  Flutter UI shell (settings, enrollment, status, onboarding)│
│        │  MethodChannel: "blur_glass/agent"                │
│        ▼                                                   │
│  Swift Agent (NSApplication, menu bar extra, no dock)      │
│   ├─ CameraSensor        AVFoundation, 30fps, downsampled  │
│   │    └─ VisionPipeline VNDetectFaceRectangles /           │
│   │                VNDetectFaceLandmarks (gaze heuristic)   │
│   ├─ PolicyEngine        hysteresis + state machine         │
│   │    └─ states: CLEAR → SOFTENING → BLURRED → PANIC      │
│   ├─ ScreenBlurLayer     ScreenCaptureKit → CIImage blur    │
│   │        fullscreen NSPanel (level: .screenSaver,        │
│   │        ignoresMouseEvents where safe)                  │
│   └─ EnrollmentStore     Keychain-stored owner template     │
└────────────────────────────────────────────────────────────┘
```

### 1.1 CameraSensor
- `AVCaptureSession` at 640×480 @ 30fps — plenty for face detection, low CPU/battery.
- Delivers `CVPixelBuffer`s to `VisionPipeline` on a dedicated serial queue.
- Lifecycle: started only while the agent is enabled; released on disable/sleep.

### 1.2 VisionPipeline
- Face presence & count: `VNDetectFaceRectanglesRequest` per frame (very cheap).
- Gaze heuristic v1: face bounding box position + landmark-based head yaw/pitch.
  Blur when the box drifts past an edge threshold or yaw/pitch exceed limits for
  longer than the grace window. (Upgrade path: `VNDetectFaceLandmarksRequest`
  eye-region analysis, or Apple's newer head-pose API if available.)
- On-device only. Vision runs on the Neural Engine via Core ML defaults.

### 1.3 PolicyEngine (the brain)
State machine with hysteresis so it never flickers:

| Transition | Trigger | Debounce |
|---|---|---|
| CLEAR → BLURRED | second face present | 0.3 s |
| CLEAR → BLURRED | owner face lost | 1.5 s grace (blink/lane-change tolerance) |
| CLEAR → BLURRED | gaze off-screen beyond threshold | 0.8 s grace |
| BLURRED → CLEAR | exactly one face, matching owner presence, gaze on | 0.5 s stable |
| any → PANIC | user hotkey | instant |

Debounce values live in a `Settings` struct with sane defaults; tunable in UI later.

### 1.4 ScreenBlurLayer
- `SCGetShareableContent` → `SCScreenshotManager` / `SCStream` captures the display.
- `CIFilter.gaussianBlur` (radius ~40, tunable) + slight saturation boost for the
  frosted look, rendered via `CIContext` to the panel layer.
- Fullscreen `NSPanel` on `.screenSaver` window level across the display,
  `collectionBehavior: [.canJoinAllSpaces, .fullScreenAuxiliary]` so it covers
  every Space and fullscreen app.
- Shows instantly on trigger (opaque freeze-frame) and cross-fades to the live
  blurred stream, so there is never a readable flash frame.
- Unlock path: fade out only after PolicyEngine says CLEAR for the stable window.

### 1.5 EnrollmentStore
- v1: single owner face template (landmark-derived vector) in Keychain.
- Used only for the *presence* decision (is the lone face the owner?) — the
  second-face trigger itself is identity-agnostic per the confirmed scope.

---

## 2. Permissions (the part that kills most apps — do it right)

| Permission | When prompted | Info.plist keys |
|---|---|---|
| Camera | onboarding step 1 | `NSCameraUsageDescription` |
| Screen Recording | onboarding step 2 | `NSScreenCaptureUsageDescription` |
| Accessibility (optional, v2) | for hotkey/inject | `NSAccessibilityUsageDescription` |

The app must detect "permission granted but TCC toggle flipped off later" and show a
recovery screen. Onboarding is a 3-step Flutter flow with a live camera preview test
and a fake blur preview so users grant both permissions knowingly.

---

## 3. Build phases

**Phase 0 — Skeleton (day 1)**
- Swift agent app + Flutter shell wired by method channel, menu bar extra, no dock icon.
- Ping/pong channel, status surface (CLEAR/BLURRED), settings stub.

**Phase 1 — Blurring works (the core milestone)**
- ScreenBlurLayer end-to-end: capture → blur → fullscreen panel over all Spaces.
- Manual trigger hotkey. Demo-able: "press ⌥B, whole screen blurs."

**Phase 2 — Eyes on the user**
- CameraSensor + face presence/count + owner-face-lost detection wired to PolicyEngine.
- All three confirmed triggers live: face lost, second face, (gaze stub optional).

**Phase 3 — Gaze & polish**
- Landmark-based gaze heuristic, debounce tuning, fade animations, panic hotkey,
  launch-at-login (`SMAppService`), battery-aware throttling.

**Phase 4 — Hardening**
- TCC revocation recovery, screen-lock/sleep handling (blur on lock wake),
  multiple-display support (panel per screen), performance profiling (<3% CPU idle).

**Later ports**
- Android: foreground service + `FLAG_BLUR_BEHIND`/overlay window + ML Kit face detection.
- iOS: impossible to blur the system UI; scope becomes in-app blur + Face ID tie-in.

---

## 4. Repo layout after Phase 0

```
lib/                  Flutter UI (settings, onboarding, status)
macos/Runner/         Swift agent: Sensor/, Vision/, Policy/, Blur/, Bridge/
test/                 unit tests: PolicyEngine state machine, debounce logic
docs/BUILD_PLAN.md    this file
```

The PolicyEngine is pure Dart-portable logic (mirrored in Swift) so the state machine
has fast unit tests without a camera or a display.

---

## 5. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Screen Recording TCC friction | Hybrid fallback (frosted panel) if capture denied — still useful |
| Gaze heuristic false positives | Long debounce + settings sensitivity slider in Phase 3 |
| Capture perf while blurred | Capture at 30fps only while BLURRED; freeze-frame after 5s idle blur |
| One face that isn't owner | Phase 4: tighten with the enrolled template match before unblur |
