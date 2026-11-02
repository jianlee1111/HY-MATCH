# HY-MATCH

### Noninvasive Blood Glucose Monitoring — Designed for Older Adults

> A self-management app that estimates blood glucose noninvasively using a dual-band microwave + NIR ear-clip sensor and an on-device deep learning model (ResNet1D + TCN), built to be usable day-to-day by middle-aged and older adults with diabetes.

Developed at Hanyang University — CARROT Lab.

---

## The Problem This Project Addresses

This project started from two recurring problems observed in clinical practice:

- Older patients keeping handwritten glucose logs, leading to frequent omissions and transcription errors, and difficulty recognizing trends on their own.
- Confusion between insulin pen types (long-acting vs. rapid-acting) and forgotten injection technique, both of which create real risk of dosing mistakes.

So the app's two core features are: automatically recording and visualizing glucose readings, and letting the user point a camera at an insulin pen to identify its type and get usage guidance, step by step. Retention mechanics such as points/rewards are intentionally out of scope for this version, since the project is not yet commercializing.

---

## Design Principles for Older Users

These reflect findings from Toss's senior usability research (["UX Research for Seniors"](https://toss.tech/article/senior-usability-research)), based on direct observation of older users.

- **Every tappable element looks like a button.** Older users frequently failed to recognize plain text or a ">" arrow as tappable, so every interactive element in this app has a visible border or fill — including the side navigation, which uses large (152×67dp+), individually bordered buttons rather than a thin tab bar.
- **Demo data is labeled clearly and repeatedly.** Older users were observed mistaking example data for their own real data, so this app repeatedly marks demo content as such — glucose history, alarms, and the patient roster in the doctor portal are all clearly sample data, and a pen-camera result only gets the "(demo result)" label in the rare case the real model fails to load and the app falls back to a placeholder.
- **Instructions are never conveyed through motion alone.** Users tended to memorize and replay animations as a fixed pattern rather than following the actual instruction, so device-pairing and pen-recognition flows always pair any animation or video with text, and the pen usage tutorial additionally supports voice (TTS) narration for users who have trouble reading on-screen text while handling a pen.
- **A recognized result is always confirmed, never acted on silently.** Camera-based pen recognition can be wrong, so the app always asks "Is this correct?" before moving on to usage guidance; manually picking a pen from the list skips this, since that choice is already explicit.
- **Category distinctions use more than a label.** "장기작용 / 초단기작용" terms alone were hard for users to tell apart at a glance, so the pen-type selection grid color-codes each action-type category (long-acting / rapid-acting / intermediate-acting / premixed) and shows a legend above the buttons explaining each color.
- **Imperative copy instead of questions.** Button and guidance text uses direct phrasing ("Start measurement", "Take a photo to check") instead of question form ("Would you like to...?").
- **Scrollability is visually implied.** Cards and lists are deliberately cut off at the edge of the viewport where content continues, rather than ending cleanly, so users don't assume what's visible is everything there is.

General accessibility practices are layered on top of these, targeting **WCAG 2.2 AA**:

- Glucose readings use a bold 44pt+ numeral; body text is 16pt or larger throughout (noticeably larger than typical UI defaults).
- Every status (normal/low/high) is always shown with color + icon + text label together, never color alone — centralized in `lib/theme/glucose_status.dart`.
- Minimum touch target size of 52dp (well above WCAG 2.2's 24×24 minimum for SC 2.5.8).
- Color contrast is verified, not assumed: the fixed brand color (`#D2691E`) only clears ~3.6:1 on its own, so a darkened variant (`primaryText`, `#A45217`) is used anywhere text needs the 4.5:1 AA ratio, and every status color was checked and, where needed, re-hued to stay distinguishable from the brand color and from each other — see `lib/theme/app_theme.dart`.
- A dedicated **Help** tab sits at the same position in every screen's side navigation (WCAG 2.2 SC 3.2.6, consistent help), with large buttons revealing the detailed explanation that used to live inline on each screen.
- A high-contrast light theme (neutral background, dark charcoal text, single fixed terracotta brand accent) replaces the earlier dark theme, reducing halation/glare for low-vision users. Gradients, neon accents, and glow effects were intentionally avoided.

---

## Current Implementation Status (please read before relying on this)

This repository is a research prototype. The table below is honest about what actually works versus what is a placeholder.

| Feature | Status |
|---|---|
| Glucose dashboard / trend chart / alarm history | Works end-to-end on demo data (no real sensor or backend yet) |
| Measurement flow (BLE → inference) | UI and the TFLite inference pipeline run for real, but currently driven by a simulated dummy signal |
| **Insulin pen camera recognition** | **Fully working end-to-end**, including a real on-device model: `assets/insulin_classifier.tflite` (MobileNetV2-based, two output heads — 13-class product + 4-class action-category) runs via `PenClassifierService`. A camera result always goes through an "Is this correct?" confirmation dialog before proceeding — manual selection from the list skips it. Falls back to a labeled demo result only if the model fails to load |
| Pre-dose safety check | Real and functional: compares current glucose against the recognized pen's action-timing category (초속효성/혼합형 vs. 지속성/중간형) and warns before a mealtime dose while glucose is low |
| **Pen usage tutorial** | **Fully working**: a dedicated info screen (timing + storage) leads into a step-by-step tutorial with a real instructional video per step, an explicit **Next**/**Previous**/**Finish** text button on every step (never arrow-only), optional TTS voice narration with a mute toggle, and an inserted mixing step for intermediate-acting/premixed pens |
| Guardian alerts (SOS) | Guardian registration and an alert preview ("here's what would be sent") both work. Actual push delivery isn't implemented — there's no backend to send it |
| Doctor portal | Functional on demo data only, now with a responsive layout that reflows (no overflow) down to narrow/mobile widths |

---

## System Architecture

```
 [ Wearable Ear-Clip Sensor ]
            │
            │  BLE 5.0 — 10s raw buffer, 7 channels
            ▼
 ┌───────────────────────────────────────────────────────────┐
 │  Mobile App (Flutter — app/)                                │
 │                                                             │
 │   1. BLE packet parsing & buffer management                │
 │      (lib/services/tflite_ble_service.dart)                │
 │   2. Cole-Cole relaxation model fitting → permittivity params│
 │   3. On-device TFLite inference (assets/glucose_model.tflite)│
 │   4. Dashboard / trend chart / alarm UI                     │
 │      (lib/screens/*, state via lib/services/app_state.dart) │
 │   5. Camera → insulin pen classification → confirm →        │
 │      pen info → step-by-step usage tutorial (TTS + video)   │
 │      (lib/screens/pen_guide_screen.dart,                    │
 │       lib/screens/pen_info_screen.dart,                     │
 │       lib/screens/pen_tutorial_screen.dart,                  │
 │       lib/services/pen_classifier_service.dart)             │
 └───────────────────────────────────────────────────────────┘
```

There is no cloud backend yet. All state lives in the app's `AppState` (Provider) and resets to demo data on restart.

---

## Repository Structure

```
HY-MATCH/
├── app/
│   ├── assets/
│   │   ├── glucose_model.tflite       # on-device glucose model (trained on synthetic data so far)
│   │   ├── insulin_classifier.tflite  # on-device pen recognition model (MobileNetV2, 2 output heads)
│   │   └── pen_tutorial/              # 14 instructional videos, 0.mp4–13.mp4 (see below)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart        # color + typography tokens, ThemeData, WCAG 2.2 contrast notes
│   │   │   └── glucose_status.dart   # glucose value -> (label, color, icon) mapping
│   │   ├── data/
│   │   │   ├── pen_info.dart          # per-category label/color/timing/storage text
│   │   │   └── pen_tutorial_steps.dart # tutorial step content + video mapping
│   │   ├── widgets/
│   │   │   └── step_animations.dart   # code-only fallback animations + video playback widget
│   │   ├── screens/
│   │   │   ├── main_shell.dart       # top bar, side nav (incl. Help tab), patient/doctor mode switch
│   │   │   ├── home_screen.dart      # glucose status hero card, time-in-range, quick actions
│   │   │   ├── measure_screen.dart   # BLE connect + measurement flow (simulated)
│   │   │   ├── trend_screen.dart     # glucose trend chart
│   │   │   ├── alarm_screen.dart     # dose-adjustment alarms & history
│   │   │   ├── food_screen.dart      # food-exchange unit tracker
│   │   │   ├── pen_guide_screen.dart # camera capture → pen recognition → confirm → safety check
│   │   │   ├── pen_info_screen.dart  # timing / storage info, entry point into the tutorial
│   │   │   ├── pen_tutorial_screen.dart # step-by-step video + TTS tutorial
│   │   │   ├── help_screen.dart      # per-screen explanations, reachable from every screen
│   │   │   ├── my_info_screen.dart   # patient profile, target range, guardian (SOS) registration/preview
│   │   │   └── doctor_portal_screen.dart # clinician-facing patient view (responsive layout)
│   │   └── services/
│   │       ├── app_state.dart              # app-wide state (Provider)
│   │       ├── tflite_ble_service.dart     # BLE I/O + glucose model inference
│   │       └── pen_classifier_service.dart # insulin pen image classification (real TFLite model, demo fallback on failure)
│   ├── android/
│   ├── windows/
│   ├── test/
│   └── pubspec.yaml
│
├── ai_model/
│   ├── data/
│   │   └── README.md
│   └── notebooks/
│       ├── colab_training_pipeline.ipynb   # glucose model definition, synthetic-data training, TFLite export
│       └── Insulin_Classifier.ipynb        # insulin pen photo classifier training (MobileNetV2 transfer learning), TFLite export
│
└── README.md
```

---

## Pen Recognition Model

`PenClassifierService.classify()` runs a real on-device model: `assets/insulin_classifier.tflite`, a MobileNetV2-based classifier with two output heads, trained in `ai_model/notebooks/Insulin_Classifier.ipynb`.

- Input: a single 300×300 RGB image, normalized to `[0, 1]` (`pixel / 255.0`) — must match exactly, since that's what the training pipeline used.
- `sub_output` (13 classes): the specific product name.
- `parent_output` (4 classes): the action-timing category (장시간형/중간형/초속효형/혼합형), mapped to the app's `InsulinActionProfile` enum (`longActing` / `intermediateActing` / `rapidActing` / `premixed`, plus `unknown` for the manual "기타" fallback).

The pre-dose safety warning triggers for `rapidActing` **and** `premixed` results, since premixed insulins (e.g. 노보믹스, 휴마로그믹스) contain a rapid-acting component and are dosed before meals just like pure rapid-acting pens.

**Important quirk:** the compiled `.tflite` file's output order does *not* match the order `model.predict()` returns in the training notebook (`[parent_preds, sub_preds]`). Inspecting the converted model's actual subgraph output list shows output index `0` is `sub_output` (13-class) and index `1` is `parent_output` (4-class) — `pen_classifier_service.dart` reads them in that order. If the model is retrained and reconverted, re-check this ordering before trusting the mapping (e.g. with Python: inspect `interpreter.get_output_details()` from `tf.lite.Interpreter`).

To retrain with more products or categories: add images under the same `인슐린/<상위유형>/<제품명>/` folder structure the notebook expects, rerun it, replace `assets/insulin_classifier.tflite`, and update the `_subLabels` / `_parentLabels` lists in `pen_classifier_service.dart` to match the notebook's new `sorted(...)` label order exactly.

## Pen Usage Tutorial

Once a pen is recognized by camera (and confirmed via the "Is this correct?" dialog) or picked manually from the color-coded grid, `pen_guide_screen.dart` pushes `PenInfoScreen`, which shows the pen's `InsulinActionProfile`-derived timing and storage text (`lib/data/pen_info.dart`) and a button into `PenTutorialScreen`.

`PenTutorialScreen` steps through `buildTutorialSteps()` (`lib/data/pen_tutorial_steps.dart`) via a `PageView`, one step per screen, each pairing a looping video with its text instructions and offering TTS narration (mute toggle in the app bar). Pens that need mixing (`InsulinActionProfile.intermediateActing` / `premixed`) get an extra rolling step inserted first. Navigation is always by an explicit **Next** / **Previous** / **Finish** text button — never an arrow-only control.

Video mapping (`assets/pen_tutorial/<n>.mp4`):

| # | Step |
|---|------|
| 0 | Mix the insulin (rolling step — intermediate-acting / premixed pens only) |
| 1 | Open the pen cap |
| 2 | Disinfect the rubber membrane |
| 3 | Attach the needle |
| 4 | Screw the needle on |
| 5 | Remove both needle caps |
| 6 | Run a safety check (dial 1–2 units, tap) |
| 7 | Confirm a drop appears |
| 8 | Set your dose |
| 9 | Double-check your dose |
| 10 | Clean the injection site |
| 11 | Inject (hold 10+ seconds) |
| 12 | Remove the needle |
| 13 | Store the pen |

"Choose an injection site" has no video (it's a choice, not a filmable action). To add or swap a video, drop the file into `app/assets/pen_tutorial/` (already declared folder-wide in `pubspec.yaml`) and point the matching step's `videoAssetPath` at it in `pen_tutorial_steps.dart`.

---

## Glucose Model — Known Limitations

`ai_model/notebooks/colab_training_pipeline.ipynb` has been revised to close a data-leakage review: the Kaggle dataset is no longer mixed in, the train/test split is session-based (no row ever appears in both), and the `StandardScaler` plus data augmentation are now both fit on the training split only, with `scaler_params.json` exported alongside the `.tflite` file for deployment-time normalization. The pipeline itself is clean.

**The result is still not usable.** The current held-out session's validation MAE is ~31 mg/dL — far above a clinically meaningful threshold — and the underlying dataset (`예시_frames_v1.csv`, ~90 rows across 3 sessions, lab-side simulated sensor frames rather than real hardware measurements) is too small for the session-based split to produce a reliable model. Treat `glucose_model.tflite`'s output as a placeholder until it's retrained on a real, larger dataset.

---

## Running the App (`app/`)

### Prerequisites

- Flutter SDK ≥ 3.0.0 (Dart ≥ 3.0.0)
- Android Studio with an emulator, or a physical Android device
- A JDK compatible with your installed Android Gradle Plugin (JDK 17 recommended)

### Install & Run

```bash
git clone https://github.com/jianlee1111/HY-MATCH.git
cd HY-MATCH/app
flutter pub get
flutter run
```

### Camera Permission

Pen recognition calls the device camera through `image_picker`. If the camera doesn't open on some devices, add this to the `<application>` tag in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

### Notes

- `glucose_model.tflite` is already bundled under `app/assets/`, so inference runs with no extra setup — but see [Glucose Model — Known Limitations](#glucose-model--known-limitations): its output shouldn't be treated as clinically reliable yet.
- `insulin_classifier.tflite` is also bundled, trained on a real (small, ~270-image) labeled photo dataset of 13 pen products — more useful than the glucose model for demos, but still too small a dataset to be clinically reliable. Misclassification is expected on pens/angles/lighting not represented in training data.
- The pen tutorial's `flutter_tts` and `video_player` dependencies, and the 14 videos under `assets/pen_tutorial/`, are already wired into `pubspec.yaml` — no extra setup needed to see the tutorial run.
- Emulators have no real Bluetooth hardware, so BLE connection and glucose measurement run in simulation mode. Camera capture works normally as long as the emulator has a virtual camera configured.
- There's no backend integration yet (e.g. Firebase), so no config files like `google-services.json` are required to build or run.

---

## Roadmap

- [x] Wire up a real insulin pen image classification model (`insulin_classifier.tflite`, trained on a real labeled photo dataset — see [Pen Recognition Model](#pen-recognition-model))
- [x] Add a confirmation step after camera-based pen recognition, since it can misclassify
- [x] Produce and add injection tutorial videos (see [Pen Usage Tutorial](#pen-usage-tutorial))
- [x] Add voice (TTS) narration to the injection tutorial
- [x] Close data-leakage issues in the glucose model training pipeline (session-based split, scaler/augmentation fit on train only)
- [ ] Train the glucose estimation model on real phantom/clinical data at a usable scale — the pipeline is leak-free now, but the dataset (~90 simulated frames, 3 sessions) is still far too small; current held-out MAE is ~31 mg/dL
- [ ] Expand the pen-photo dataset (more products, more angles/lighting conditions) to improve recognition reliability
- [ ] Implement real guardian SOS delivery (backend integration, e.g. Firebase Cloud Messaging)
- [ ] Implement real BLE device scanning/pairing
- [ ] Add a `LICENSE` file

---

## License & References

No `LICENSE` file is committed to this repository yet, so all rights are reserved by default until one is added.

**Reference models:** Cole-Cole biological tissue dielectric relaxation equations, the Gabriel dielectric property database.
**Reference:** [Toss — UX Research for Seniors](https://toss.tech/article/senior-usability-research)
