Speech Emotion Recognition (SER) – CNN–BiGRU

Unified Multi-Corpus Training • FastAPI Deployment • Flutter Demo

This repository contains the full workflow and implementation of a Speech Emotion Recognition system developed for the Advanced Computing & Systems seminar at Leiden University.
The project integrates three acted emotion datasets, uses a unified preprocessing pipeline, trains a CNN–BiGRU model, and deploys it through a FastAPI server with an optional Flutter mobile interface.

1. Project Overview

This project builds a complete SER pipeline:

Datasets: RAVDESS, CREMA-D, IEMOCAP

Unified labels: angry, happy, neutral, sad

Fixed feature input: 3-second log-Mel spectrograms (128 × 300)

Model: 3-block CNN + Bidirectional GRU + Dense classifier

Resulting test accuracy: ~67.4% (macro-F1 ≈ 0.68)

Deployment: Real-time inference via FastAPI

Mobile App: Flutter client with audio recording + model output visualisation

2. Repository Structure
speech_emotion_detector_project/
│
├── notebooks/                  # Step-by-step pipeline notebooks
│   ├── 01_data_overview.ipynb
│   ├── 02_metadata_labels.ipynb
│   ├── 03_split_data.ipynb
│   ├── 04_feature_extraction.ipynb
│   ├── 05_train_cnn_gru.ipynb
│   └── 06_evaluation.ipynb
│
├── ser_api/                    # FastAPI inference server
│   ├── main.py
│   ├── model/best_cnn_gru_ser.keras
│   └── utils/
│        ├── audio_utils.py
│        └── features.py
│
├── flutter_app/                # Optional: mobile demo client
│
├── reports/                    # LaTeX report and images
│
└── requirements.txt            # Python dependencies

3. Requirements
Install dependencies (recommended: conda environment):
conda create -n ser_env python=3.10
conda activate ser_env
pip install -r requirements.txt

Main libraries used:
numpy
librosa
tensorflow==2.15
keras==3.0.0
fastapi
uvicorn
scikit-learn
soundfile

4. Running the Inference Server
From the project root:
conda activate ser_env
cd ser_api
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
Server will be available at:
http://0.0.0.0:8000

API (POST /predict)

Send a 16 kHz mono WAV file:

Response example:
{
  "emotion": "neutral",
  "probability": 0.74,
  "all_probs": {
    "angry": 0.05,
    "happy": 0.11,
    "neutral": 0.74,
    "sad": 0.10
  }
}

 
