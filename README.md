# Speech Emotion Recognition (SER) – CNN–BiGRU  
Multi-Corpus Training • FastAPI Deployment • Flutter Mobile Demo

This repository contains the full workflow for a Speech Emotion Recognition system developed for the Advanced Computing & Systems seminar at Leiden University. The project integrates three emotional speech corpora, applies a unified preprocessing pipeline, trains a CNN–BiGRU model, and deploys it using a FastAPI server with an optional Flutter mobile demo.

---

## 1. Project Overview

This project provides an end-to-end SER pipeline:

- Datasets: RAVDESS, CREMA-D, IEMOCAP  
- Unified emotion labels: angry, happy, neutral, sad  
- Acoustic features: log-Mel spectrograms (128 × 300, 3 seconds)  
- Model: CNN (3 convolutional blocks) + Bidirectional GRU (128 units)  
- Evaluation: ~67.4% test accuracy  
- Deployment: FastAPI inference server  
- Mobile App: Flutter-based real-time SER demo

---

## 2. Repository Structure

speech_emotion_detector_project/  
├── notebooks/  
│   ├── 01_data_overview.ipynb  
│   ├── 02_metadata_labels.ipynb  
│   ├── 03_split_data.ipynb  
│   ├── 04_feature_extraction.ipynb  
│   ├── 05_train_cnn_gru.ipynb  
│   └── 06_evaluation.ipynb  
│  
├── ser_api/  
│   ├── main.py  
│   ├── model/best_cnn_gru_ser.keras  
│   └── utils/  
│        ├── audio_utils.py  
│        └── features.py  
│  
├── flutter_app/   
├── reports/  
└── requirements.txt  

---

## 3. Installation

### Create environment
conda create -n ser_env python=3.10  
conda activate ser_env

### Install dependencies
pip install -r requirements.txt

Main dependencies:
- numpy  
- librosa  
- scikit-learn  
- tensorflow==2.15  
- keras==3.0.0  
- fastapi  
- uvicorn  
- soundfile  

---

## 4. Running the Inference Server

conda activate ser_env  
cd ser_api  
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload

Server starts at:
http://0.0.0.0:8000

### API Endpoint: POST /predict  
Input: 16 kHz mono WAV file  
Output example:

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

---
