# Non-Invasive Blood Glucose Monitoring Dataset Specification

This directory contains data processing guidelines, schema definitions, and sample datasets for training the **Multi-Modal (7-Channel Microwave/NIR + Physical Parameters) Blood Glucose Estimation Model**.

---

## 1. Overview & Data Acquisition Protocol

This dataset combines non-invasive time-series signals acquired from earlobe contact sensors with clinical invasive ground-truth blood glucose values.

* **Target Subject Area:** Earlobe (Lobulus auriculae)
* **Sampling Rate:** 10 Hz (10 samples per second)
* **Measurement Duration:** 10 seconds per session (Sequence Length = 100 timesteps)
* **Reference Device (Ground Truth $y$):** ISO 15197:2013-compliant clinical capillary blood glucose meter ($mg/dL$)

---

## 2. Data Architecture & Feature Schema

The data consists of **Independent Variables ($X$)** split into time-series signals and scalar physical parameters, and a **Dependent Variable ($y$)**.

### A. Time-Series Signal Tensor ($X_{\text{wave}} \in \mathbb{R}^{B \times 7 \times 100}$)

| Channel Index | Signal Type | Sensor / Physical Origin | Frequency / Wavelength | Unit / Format |
| :--- | :--- | :--- | :--- | :--- |
| `Ch 0` | Microwave $S_{11}$ Magnitude | Reflection Coefficient ($\vert{}S_{11}\vert{}$) | Low-band (1.5 - 2.5 GHz) | dB |
| `Ch 1` | Microwave $S_{11}$ Phase | Phase Shift ($\angle S_{11}$) | Low-band (1.5 - 2.5 GHz) | Radians |
| `Ch 2` | Microwave $S_{21}$ Magnitude | Transmission Coefficient ($\vert{}S_{21}\vert{}$) | High-band (3.5 - 5.0 GHz) | dB |
| `Ch 3` | Microwave $S_{21}$ Phase | Phase Shift ($\angle S_{21}$) | High-band (3.5 - 5.0 GHz) | Radians |
| `Ch 4` | NIR Absorbance 1 | Photodiode Detector A | $\lambda_1 = 850\text{ nm}$ | Optical Density (OD) |
| `Ch 5` | NIR Absorbance 2 | Photodiode Detector B | $\lambda_2 = 940\text{ nm}$ | Optical Density (OD) |
| `Ch 6` | NIR Absorbance 3 | Photodiode Detector C | $\lambda_3 = 1300\text{ nm}$ | Optical Density (OD) |

### B. Physical Parameter Vector ($X_{\text{phys}} \in \mathbb{R}^{B \times 6}$)

Extracted via non-linear Cole-Cole relaxation model fitting and environmental sensors to compensate for artifact noise and inter-subject variance.

| Index | Parameter | Description | Unit |
| :--- | :--- | :--- | :--- |
| `0` | $\epsilon_s$ | Static Low-Frequency Dielectric Permittivity | Dimensionless |
| `1` | $\epsilon_\infty$ | Optical High-Frequency Dielectric Permittivity | Dimensionless |
| `2` | $\tau$ | Dielectric Relaxation Time | Picoseconds ($ps$) |
| `3` | $\alpha$ | Broadening Parameter (Cole-Cole exponent) | Range $[0, 1]$ |
| `4` | $T_{\text{skin}}$ | Earlobe Surface Contact Temperature | Celsius ($^\circ\text{C}$) |
| `5` | $H_{\text{amb}}$ | Ambient Air Relative Humidity | Percentage ($\%$) |

### C. Ground Truth Label ($y \in \mathbb{R}^{B \times 1}$)

* **Value:** Invasive blood glucose level ($70.0 \sim 250.0\text{ mg/dL}$)
* **Measurement Window:** Obtained within $\pm 60$ seconds of non-invasive sensor acquisition.

---

## 3. Directory Structure

```text
ai_model/data/
├── README.md                 # Data specification and guidelines (This file)
├── sample_data.csv           # Small 7-channel CSV sample for rapid unit testing
├── synthetic_generator.py    # Script to synthesize phantom Cole-Cole datasets
└── external/                 # External pre-training optical datasets (Git-ignored)
    ├── kaggle_nir/           # Pre-processed NIR dataset from Kaggle
    └── physionet_d1namo/     # Filtered PPG/time-series dataset from PhysioNet
