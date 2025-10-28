from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
import librosa
import keras
from keras.layers import Layer

app = Flask(__name__)

# --- We define our custom layer exactly as it was in the notebook ---
class SpecAugment(Layer):
    def __init__(self, freq_mask_param, time_mask_param, **kwargs):
        super(SpecAugment, self).__init__(**kwargs)
        self.freq_mask_param = freq_mask_param
        self.time_mask_param = time_mask_param
    
    def call(self, inputs, training=None):
        if not training:
            return inputs
        
        freq_max = tf.shape(inputs)[1]
        f = tf.random.uniform(shape=(), minval=0, maxval=self.freq_mask_param, dtype=tf.int32)
        f0 = tf.random.uniform(shape=(), minval=0, maxval=freq_max - f, dtype=tf.int32)
        mask_f = tf.concat([tf.ones((f0, tf.shape(inputs)[2])), tf.zeros((f, tf.shape(inputs)[2])), tf.ones((freq_max - f0 - f, tf.shape(inputs)[2]))], axis=0)
        
        time_max = tf.shape(inputs)[2]
        t = tf.random.uniform(shape=(), minval=0, maxval=self.time_mask_param, dtype=tf.int32)
        t0 = tf.random.uniform(shape=(), minval=0, maxval=time_max - t, dtype=tf.int32)
        mask_t = tf.concat([tf.ones((tf.shape(inputs)[1], t0)), tf.zeros((tf.shape(inputs)[1], t)), tf.ones((tf.shape(inputs)[1], time_max - t0 - t))], axis=1)
        
        augmented = inputs * mask_f[:, :, tf.newaxis]
        augmented = augmented * mask_t[:, :, tf.newaxis]
        return augmented
    
    def get_config(self):
        config = super(SpecAugment, self).get_config()
        config.update({
            "freq_mask_param": self.freq_mask_param,
            "time_mask_param": self.time_mask_param,
        })
        return config

# --- Load your CORRECT trained model ---
try:
    custom_objects = {"SpecAugment": SpecAugment}
    model = tf.keras.models.load_model('unbiased_app_model.keras', custom_objects=custom_objects)
    print("✅ Keras model 'unbiased_app_model.keras' loaded successfully.")
except Exception as e:
    print(f"❌ Error loading Keras model: {e}")
    exit()

LABELS = ['angry', 'happy', 'neutral', 'sad']

def get_linear_spectrogram(audio_data, sr, n_fft=2048, hop_length=512, max_pad_len=130):
    stft = librosa.stft(y=audio_data, n_fft=n_fft, hop_length=hop_length)
    stft_mag = np.abs(stft)
    stft_db = 20 * np.log10(np.maximum(1e-6, stft_mag))
    stft_db = stft_db[:128, :]
    
    if stft_db.shape[1] > max_pad_len:
        stft_db = stft_db[:, :max_pad_len]
    else:
        pad_width = max_pad_len - stft_db.shape[1]
        stft_db = np.pad(stft_db, pad_width=((0, 0), (0, pad_width)), mode='constant')
    return stft_db

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    try:
        audio, sr = librosa.load(file, sr=22050)
        spectrogram = get_linear_spectrogram(audio, sr)
        
        input_tensor = np.expand_dims(spectrogram, axis=0)
        input_tensor = np.expand_dims(input_tensor, axis=-1)
        
        # Get predictions (probabilities for all classes)
        prediction = model.predict(input_tensor)
        predicted_index = np.argmax(prediction, axis=1)[0]
        predicted_emotion = LABELS[predicted_index]
        
        # Get confidence (probability of predicted class)
        confidence = float(prediction[0][predicted_index])
        
        # Get all probabilities as a dictionary
        probabilities = {
            LABELS[i]: float(prediction[0][i]) 
            for i in range(len(LABELS))
        }
        
        print(f"Prediction successful: {predicted_emotion} (confidence: {confidence:.2%})")
        
        return jsonify({
            'emotion': predicted_emotion,
            'confidence': confidence,
            'probabilities': probabilities
        })
    except Exception as e:
        print(f"❌ Error during prediction: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)