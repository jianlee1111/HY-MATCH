# ai_model/data

This folder holds the physics/simulation outputs behind the glucose estimation model, plus two small example datasets and one external pretraining dataset. **Nothing generated in-house here is real sensor or clinical measurement data** It's all simulation, Monte Carlo sampling, or analytical (Fisher-information) error modeling. See "Known limitations" below.

Files are grouped into subfolders by sensor modality, matching the numbering already used in the simulation folder map (01 EM, 02 NIR, 03 hardware noise, 06 pressure, 07 analysis/specs).

## `em/` — microwave resonator forward model

| File | What it is | Rows × cols |
|---|---|---|
| `EM_계수표_v1.csv` | S21 sensitivity (magnitude shift, Q change, dB/phase change at 6 frequencies 2.30–2.60 GHz) per unit change in blood permittivity, blood conductivity, skin permittivity, temperature, and clip gap thickness | 6 × 19 |
| `em_coeff_S11_v1_spectra.csv` | Full S-parameter sweep, 0.300–1.8+ GHz in 5 MHz steps: baseline S0 (complex) plus its derivative with respect to blood permittivity/conductivity, skin permittivity, temperature, at two clip-gap settings (3.5 mm, 4.5 mm) | ~300+ × 15 |
| `EM_구조비교_v1.md` | Write-up comparing EM structure choices (S11 vs. S21 vs. fused) | — |

## `nir/` — near-infrared optical forward model

| File | What it is | Rows × cols |
|---|---|---|
| `NIR_계수표_v1.csv` | NIR absorbance (1310/1370/1625 nm) sensitivity per +100 mg/dL glucose, +1 °C, +1 mm thickness, ×1.2 scattering, +0.02 water fraction, separating rows for phantom and earlobe geometry | 12 × 4 (+2 header rows) |
| `광자수송_v1.csv` | Monte Carlo / diffusion-model photon transport: per-wavelength sensitivity to glucose, temperature, thickness, water, scattering, across multiple source–detector geometries and two anisotropy values (g = 0.9, 0.7) | ~480 × 9 |
| `벤치예측_v1.md` | Bench-LED (1300/1450/1650 nm) predicted absorbance and variation; notes the current bench LEDs don't match the model's target wavelengths, so the model can't be validated against bench data yet | — |

## `noise/` — hardware noise budget

| File | What it is | Rows × cols |
|---|---|---|
| `HW_노이즈_v1.csv` | ADC, amplifier, thermal, shot, LED flicker/drift noise per wavelength, converted to glucose-equivalent error (mg/dL) for NIR-only, microwave-only, fused, and linear-model readings | 93 × 5 |
| `회로대조_v1.md` | Comparison of actual circuit specs against the analytical noise model | — |

## `pressure/` — ear-clip force/thickness model

| File | What it is | Rows × cols |
|---|---|---|
| `압력층_v1.csv` | Ear-clip force/gap operating points and person-to-person earlobe thickness variability (relaxed-lobe measurements at 2.7–4.14 mm) | 66 × 6 |
| `압력층_v1.md` | Write-up of the above | — |

## `examples/` — proposed input format demo (not a training set)

| File | What it is | Rows × cols |
|---|---|---|
| `예시_frames_v1.csv` | Example per-frame output in the proposed model input format: `A_1310/1370/1625`, `S21_dB_f1–f6`, `S21_deg_f1–f6`, `ntc_dT_C`, `fsr_N`, plus a `glucose_mgdl` label, across 3 sessions × 30 frames | 90 × 37 |
| `예시_frames_flag_v1.csv` | Same frames, with an added physics-fit residual/mismatch-flag pass (`glucose_hat_mgdl`, `resid_Q`, `flag_model_mismatch`, etc.) | 90 × 47 |
| `알고리즘_입력형식_기본안_v1.md` | The proposal document behind the format above, explicitly stating this is simulation output, not real measurement, and that the 6 `phys` model inputs are not yet defined | — |

These two CSVs total 90 rows across only 3 simulated sessions. They demonstrate the intended format. They are not large or varied enough to train the model on.

## `reports/` — design-comparison / error-budget reports (not sample data)

| File | What it is |
|---|---|
| `구조비교_v1.csv`, `구조비교_v1_results.json` | S11 vs. S21 vs. fused structure comparison, by theoretical glucose error (mg/dL) |
| `읽기방식_v1.csv` | ADC reading method comparison (direct / monitor-PD / slope-ratio) by theoretical error |
| `통합모델_v1.csv`, `통합모델_v1.md` | Combined-layer error projection; states directly that the trained model has not yet been run against this data ("the team's algorithm has not been connected to this pipeline yet") |

All of these come from Fisher-information calculations and Monte Carlo noise draws on the physics model, not from running the trained neural network.

## `external/` — third-party pretraining data

<!-- TODO: fill in once the dataset name/path is confirmed -->
| File/folder | Source | Notes |
|---|---|---|
| *(Kaggle dataset — name pending)* | Kaggle | Used for pretraining the wave-branch backbone before fine-tuning on the simulated data above |

If a PhysioNet D1NAMO dataset is added later, it goes here too.

## Known limitations

- No real sensor measurements exist for the `em/`, `nir/`, `noise/`, and `pressure/` tables, or for the `examples/` frames . All of it is simulation or analytical modeling.
- A model trained only on `em/`, `nir/`, `noise/`, `pressure/`, and `examples/` should be treated as a pretraining/initialization step, not a final model. It will need fine-tuning and validation against real measurements before deployment.
- The 6 `phys` input parameters the training notebook (`colab_training_pipeline.ipynb`) expects are **not defined anywhere in this data**.
- Even the physics model itself hasn't been checked against real measurements yet (see `벤치예측_v1.md`, `회로대조_v1.md`).
- The trained model (`glucose_model.tflite` / `MultimodalGlucoseModel`) has never been run against any file in this folder.

## Migration note

This structure replaces a flat layout where all files sat directly in `ai_model/data/`. When moving files, use `git mv` so history is preserved, and update any `write_*_md_v1.py` / `run_*.py` script paths that reference the old flat locations.
