# HY-MATCH

### 🩸 Noninvasive Blood Glucose Monitoring — Dual-Band Microwave Sensing + On-Device AI

> A self-management prototype for noninvasive blood glucose monitoring, combining a dual-band microwave + NIR ear-clip sensor with an on-device deep learning model (ResNet1D + TCN) inside a cross-platform Flutter app.

Developed at **Hanyang University — CARROT Lab**.

---

## 📌 Project Overview

HY-MATCH explores noninvasive blood glucose estimation by processing a 7-channel multi-sensor signal — 4 channels of dual-band microwave dielectric response plus 3 channels of NIR — captured through a wearable ear-clip sensor over a 10-second window.

Instead of sending raw sensor data to a cloud server, the signal is preprocessed on-device with a physics-informed Cole-Cole relaxation model, then passed through a quantized **ResNet1D + TCN** network converted to **TensorFlow Lite**, so inference runs entirely on the phone. This keeps latency low, avoids GPU hosting costs, and keeps raw biosignal data off any server.

The repository currently has two parts at different levels of maturity:

- **`app/`** — a working Flutter prototype: BLE ear-clip communication, on-device TFLite inference, a patient-facing dashboard/trend/alarm/food-guide UI, and a doctor-portal view, all running on simulated/demo data end-to-end.
- **`ai_model/`** — an early-stage Colab notebook covering the model architecture, a synthetic-data training loop, and the PyTorch → ONNX → TFLite export pipeline. Real clinical training data collection hasn't started yet, so the shipped `glucose_model.tflite` is trained on synthetic signals for pipeline validation, not clinical accuracy.

> ⚠️ **Status:** early-stage research prototype. Measurements, thresholds, and guidance text in the app are simulated and are **not** medical advice.

---

## 🏗️ System Architecture & Data Flow

```
 [ Wearable Ear-Clip Sensor ]
            │
            │  BLE 5.0 — 10s raw buffer, 7 channels
            ▼
 ┌───────────────────────────────────────────────────────────┐
 │  📱 Mobile App (Flutter — app/)                            │
 │                                                             │
 │   1. BLE packet parsing & buffer management                │
 │      (lib/services/tflite_ble_service.dart)                │
 │   2. Cole-Cole relaxation model fitting                     │
 │      → complex permittivity params (εs, ε∞, τ, α)          │
 │   3. On-device TFLite inference (assets/glucose_model.tflite)│
 │   4. Dashboard / trend graph / alarm UI                     │
 │      (lib/screens/*, state via lib/services/app_state.dart) │
 └───────────────────────────────────────────────────────────┘
```

The current build does not yet include a cloud backend — history/state lives in-app (`AppState`, in-memory + demo data). A lightweight Firebase backup layer (Auth + Firestore) is planned but not implemented yet; see [Roadmap](#-roadmap).

---

## ✨ Key Features

- **Multi-sensor signal capture** — 7-channel signal matrix (10 s × 7 ch) streamed over BLE from the ear-clip sensor.
- **Physics-informed preprocessing** — Cole-Cole dielectric relaxation fitting computed on-device before inference.
- **On-device AI inference** — a `ResNet1D + TCN` model bundled as a TFLite asset, so predictions don't require network access.
- **Patient app** — home dashboard, glucose trend chart (`fl_chart`), dose/alarm reminders, food-exchange guide, insulin pen guide, and profile screen.
- **Doctor portal view** — a role-switchable view inside the same app for reviewing a patient's readings and adjusting target ranges (demo data).
- **Cross-platform Flutter codebase** — Android and Windows desktop scaffolding included today; iOS/macOS/Linux/web can be added with `flutter create .`.

---

## 📁 Repository Structure

This reflects what's actually in the repo (not an idealized layout):

```
HY-MATCH/
├── app/                              # Flutter application
│   ├── assets/
│   │   └── glucose_model.tflite      # on-device model (currently trained on synthetic data)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/                  # UI screens
│   │   │   ├── main_shell.dart       # top bar, sidebar nav, role switcher (patient/doctor)
│   │   │   ├── home_screen.dart      # glucose status + meal log + quick stats
│   │   │   ├── measure_screen.dart   # BLE connect + simulated measurement flow
│   │   │   ├── trend_screen.dart     # glucose trend chart
│   │   │   ├── alarm_screen.dart     # dose-adjustment alarms & history
│   │   │   ├── food_screen.dart      # food-exchange unit tracker
│   │   │   ├── pen_guide_screen.dart # insulin pen recognition/selection guide
│   │   │   ├── my_info_screen.dart   # patient profile & target range
│   │   │   └── doctor_portal_screen.dart # clinician-facing patient view
│   │   └── services/
│   │       ├── app_state.dart          # app-wide state (Provider)
│   │       └── tflite_ble_service.dart # BLE I/O + TFLite inference
│   ├── android/                      # Flutter Android build scaffolding
│   ├── windows/                      # Flutter Windows build scaffolding
│   ├── test/
│   │   └── widget_test.dart
│   └── pubspec.yaml
│
├── ai_model/
│   ├── data/
│   │   └── README.md                 # dataset spec (channels, sampling rate, label range) — reference doc, no data committed yet
│   └── notebooks/
│       └── colab_training_pipeline.ipynb   # model definition, synthetic-data training loop, PyTorch→ONNX→TFLite export
│
└── README.md
```

> Note: an earlier version of this README described a `viewmodels/`, `views/`, and standalone `train.py` / `convert_to_tflite.py` layout. That structure isn't in the repo yet — the app uses a flatter `screens/` + `services/` layout, and the training/export pipeline currently lives entirely inside `colab_training_pipeline.ipynb`. This README describes what's actually committed.

---

## 🧠 AI Model Pipeline (`ai_model/`)

### Architecture

`MultimodalGlucoseModel` (defined in the notebook) combines:

- **ResNet1D** residual blocks for per-channel feature extraction across the 7 dielectric/NIR channels, and
- a **TCN**-style temporal stage to capture dependencies across the 10 s window,
- fused with the Cole-Cole physical parameters (6-dim) through an MLP head to predict a single glucose value (mg/dL).

### Current pipeline (`colab_training_pipeline.ipynb`)

The notebook is meant to run in Google Colab and currently does the following, in order:

1. Mount Google Drive / set up the project directory.
2. Install dependencies (`onnx`, `onnx2tf`, `tensorflow`, `scikit-learn`, `pandas`, `numpy`, `matplotlib`).
3. Build a **synthetic** `GlucoseDataset` — real clinical/phantom data collection hasn't started, so this stage exists to validate the pipeline end-to-end.
4. Define `ResidualBlock1D` + `MultimodalGlucoseModel` (wave channels = 7, physical-parameter dim = 6).
5. Train with a Huber/SmoothL1 loss, checkpointing the best weights to Drive.
6. Export: PyTorch (`.pt`) → ONNX → TFLite, producing `glucose_model.tflite`.

To regenerate the model:

```bash
# Open ai_model/notebooks/colab_training_pipeline.ipynb in Google Colab
# Run all cells top to bottom (see the notebook's own markdown cells for GPU/runtime settings)
```

Once training moves off synthetic data, copy the resulting file to `app/assets/glucose_model.tflite` and rerun `flutter pub get` so the asset is repackaged.

**Planned, not yet in the repo:** standalone `train.py` / `convert_to_tflite.py` scripts, a `preprocessing/` module for the Cole-Cole fitting logic shared between Python and Dart, and real phantom/clinical datasets under `ai_model/data/`.

---

## 🚀 Mobile App Setup (`app/`)

### Prerequisites

- Flutter SDK ≥ 3.0.0 (Dart ≥ 3.0.0)
- Android Studio (for the Android toolchain/emulator) and/or a physical Android device
- A JDK compatible with your installed Android Gradle Plugin (JDK 17 is recommended)

### Install & Run

```bash
# 1. Clone the repository
git clone https://github.com/jianlee1111/HY-MATCH.git
cd HY-MATCH/app

# 2. Install Flutter dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run
```

To target a specific device:

```bash
flutter devices               # list available devices/emulators
flutter run -d <device-id>
```

### Notes

- `glucose_model.tflite` is already committed under `app/assets/` and wired up via `pubspec.yaml`, so no extra setup is needed to run inference — it currently returns predictions based on the synthetic-data-trained model described above, not validated clinical output.
- BLE ear-clip pairing (`tflite_ble_service.dart`) requires a physical device with Bluetooth; on an emulator, the "측정 시작" (start measurement) flow runs in simulation mode.
- There is no Firebase integration yet — `google-services.json` / `GoogleService-Info.plist` are not required to build or run the app today.

---

## 🗺️ Roadmap

- [ ] Collect real phantom/clinical training data and retrain beyond the synthetic baseline
- [ ] Extract `train.py` / `convert_to_tflite.py` / `preprocessing/` out of the notebook into a reusable Python package
- [ ] Add Firebase Authentication + Cloud Firestore for cross-device history backup
- [ ] Add a `LICENSE` file (see below)
- [ ] iOS build target

---

## 📄 License & References

No `LICENSE` file is committed to this repository yet, so all rights are reserved by default until one is added — treat the code as **not** open for reuse until a license is published here.

**Reference models:** Cole-Cole biological tissue dielectric dispersion equations and the Gabriel dielectric property database.
