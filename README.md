# HY-MATCH
# 🩸 Noninvasive Blood Glucose Monitoring System using Dual-Band Microwave & On-Device AI

> **Noninvasive blood glucose monitoring system leveraging a dual-band microwave sensor, NIR signals, and an on-device deep learning architecture (ResNet1D + TCN) integrated with Flutter and Firebase.**

---

## 📌 Project Overview

This repository contains the full software pipeline for a novel noninvasive blood glucose monitoring system. By processing 7-channel multi-sensor signals (4-channel Dual-Band Microwave + 3-channel NIR) captured via a wearable ear-clip sensor, the system accurately predicts blood glucose levels ($mg/dL$) in real-time.

To eliminate expensive cloud computing/GPU costs and ensure data privacy, the system utilizes an **On-Device AI architecture**. High-performance PyTorch models are trained using high-performance Cloud GPUs (Google Colab / Spot VMs) and converted to **TensorFlow Lite (TFLite)** to run inference natively inside a cross-platform mobile application.

---

## 🏗️ System Architecture & Data Flow
[ Wearable Ear-Clip Sensor ]
│
│ 📡 Bluetooth Low Energy (BLE 5.0) — 10s Raw Buffer (7 Channels)
▼
┌─────────────────────────────────────────────────────────────────┐
│ 📱 Mobile Application (Flutter Engine)                          │
│                                                                 │
│  1. BLE Packet Parsing & Buffer Management                       │
│  2. Physics-based Cole-Cole Relaxation Model Fitting            │
│  3. On-Device AI Inference (glucose_model.tflite)             │
│  4. Real-Time Dashboard & Trend Graph Rendering (fl_chart)     │
└────────────────────────┬────────────────────────────────────────┘
│
│ ☁️ Firebase SDK (Lightweight Text Backup)
▼
┌─────────────────────────────────────────────────────────────────┐
│ ☁️ Backend & Database (Google Firebase)                         │
│                                                                 │
│  - Firebase Authentication (Secure User Session Management)     │
│  - Cloud Firestore (User Glucose History Log Backup - NoSQL)   │
└─────────────────────────────────────────────────────────────────┘


---

## ✨ Key Features

- **Multi-Sensor Data Processing:** Captures 7-channel signal matrices ($10 \text{s} \times 7 \text{ch}$) sent via BLE every 5 minutes.
- **Physics-Informed Preprocessing:** Applies Cole-Cole relaxation model algorithms locally to compute complex permittivity parameters ($\epsilon_s, \epsilon_\infty, \tau, \alpha$).
- **On-Device AI Inference:** Runs a quantized `ResNet1D + TCN` model embedded directly in the app assets, delivering inference within 100ms without server latency.
- **Zero-Cost Scalable Architecture:** Low-overhead architecture utilizing Google Cloud Spot VMs for training and Firebase Free Tier for storage.
- **Cross-Platform UI:** Built with Flutter for seamless deployment on both Android and iOS devices.

---

## 📁 Repository Structure

.
├── app/                          # Flutter Mobile Application Source Code
│   ├── assets/
│   │   └── glucose_model.tflite   # Quantized On-Device AI Model
│   ├── lib/
│   │   ├── models/               # Data structures & Cole-Cole formulas
│   │   ├── services/             # BLE Communication & Firebase SDK
│   │   ├── viewmodels/           # State management & TFLite inference logic
│   │   └── views/                # Dashboard & Trend graph UI components
│   └── pubspec.yaml              # App dependencies & assets configuration
│
├── ai_model/                     # PyTorch Training & Model Conversion Pipeline
│   ├── data/                     # Phantom & Clinical dataset directory
│   ├── preprocessing/            # Cole-Cole nonlinear fitting scripts
│   ├── models/                   # ResNet1D + TCN Network Architecture definition
│   ├── train.py                  # Training pipeline (Designed for Colab / Spot GPU)
│   └── convert_to_tflite.py      # PyTorch (.pt) -> ONNX -> TFLite export script
│
└── README.md                     # Project documentation


---

## 🧠 AI Model Pipeline (`ai_model/`)

### Architecture
The deep learning model combines **1D Residual Networks (ResNet1D)** for spatial feature extraction across dielectric/NIR channels with **Temporal Convolutional Networks (TCN)** to capture temporal dependencies in multi-channel time-series data.

### Training & Export Steps
1. **Train Model on Cloud GPU (Google Colab / Cloud Spot VM):**
   ```bash
   python ai_model/train.py --data_path ./data/clinical_data.csv --epochs 200 --batch_size 32
   Convert & Quantize to TFLite:

Bash
python ai_model/convert_to_tflite.py --model_path ./models/best_model.pt
Deploy: Copy the generated glucose_model.tflite to app/assets/ directory.

🚀 Mobile App Setup (app/)
Prerequisites
Flutter SDK: >=3.0.0

Dart SDK: >=3.0.0

IDE: VS Code / Cursor / Android Studio

Installation
Clone the Repository:

Bash
git clone [https://github.com/jianlee1111/HY-MATCH]
cd noninvasive-glucose-monitoring/app
Install Dependencies:

Bash
flutter pub get
Configure Firebase:

Create a project on Firebase Console.

Add Android (google-services.json) and iOS (GoogleService-Info.plist) configuration files into their respective app folders.

Run the Application:

Bash
flutter run
📄 License & References
License: Distributed under the MIT License.

Reference Models: Built based on Cole-Cole biological tissue dielectric dispersion equations and Gabriel dielectric property databases.