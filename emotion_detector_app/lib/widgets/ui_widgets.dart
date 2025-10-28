import 'package:flutter/material.dart';
import '../model/emotion_view_model.dart';

// --- Header Widget ---
class HeaderWidget extends StatelessWidget {
  final int predictionCount;
  const HeaderWidget({required this.predictionCount, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.psychology_outlined, size: 28, color: Colors.white),
              const SizedBox(width: 12),
              const Text(
                'Speech Emotion Recognition',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Deep Learning Audio Processing',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 0.3,
            ),
          ),
          if (predictionCount > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Predictions: $predictionCount',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// --- Status Card Container ---
class StatusCardWidget extends StatelessWidget {
  final EmotionViewModel viewModel;
  final AnimationController animationController; // Needed for recording animation

  const StatusCardWidget({
    required this.viewModel,
    required this.animationController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    switch (viewModel.status) {
      case EmotionStatus.ready:
        return _buildReadyCard(context);
      case EmotionStatus.recording:
        return _buildRecordingCard(context, viewModel.recordingProgress, animationController);
      case EmotionStatus.processing:
        return _buildProcessingCard(context);
      case EmotionStatus.complete:
      case EmotionStatus.error: // Show result card for both complete and error
        return _buildResultCard(context, viewModel.currentEmotionData, viewModel.errorMessage);
    }
  }

  // --- Individual Status Card Widgets (Private helpers) ---
  Widget _buildReadyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20), // Adjusted padding
      decoration: _cardDecoration(context),
      child: Column(
        children: [
          Icon(Icons.mic_none, size: 70, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'System Ready',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Awaiting audio input signal',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingCard(BuildContext context, int progress, AnimationController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Reduced vertical padding
      decoration: _cardDecoration(context, shadowColor: Colors.red.withOpacity(0.15)),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  return Container(
                    width: 90 + (controller.value * 20), // Pulsating effect
                    height: 90 + (controller.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.1 + (controller.value * 0.1)),
                    ),
                  );
                },
              ),
              const Icon(Icons.mic, size: 50, color: Colors.red),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Recording Audio Signal',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6, // Relative width
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress / 40.0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  minHeight: 6, // Slightly thicker
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress / 10.0).toStringAsFixed(1)}s / 4.0s',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: _cardDecoration(context),
      child: Column(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3.5, // Slightly thicker
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Neural Network Inference',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Extracting features & classifying...',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, EmotionData? emotionData, String errorMessage) {
    final bool isError = emotionData?.label == 'Error'; // Check based on label

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: _cardDecoration(context,
          shadowColor: isError
              ? Colors.orange.withOpacity(0.15)
              : emotionData?.color.withOpacity(0.2) ?? Colors.grey.withOpacity(0.1)),
      child: Column(
        children: [
          if (isError) ...[
            Icon(Icons.error_outline, size: 70, color: Colors.orange.shade600),
            const SizedBox(height: 16),
            Text(
              'System Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage.isNotEmpty ? errorMessage : 'Prediction failed. Check connection.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ] else if (emotionData != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: emotionData.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(emotionData.icon, size: 50, color: emotionData.color),
                ),
                const SizedBox(width: 20),
                Flexible( // Added Flexible
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Classification Result',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        emotionData.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: emotionData.color,
                        ),
                        overflow: TextOverflow.ellipsis, // Prevent overflow
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildQuickMetrics(context, viewModel.confidence, viewModel.processingTime),
          ] else ...[
            // Fallback for unexpected null emotionData when not an error
            const Icon(Icons.question_mark, size: 70, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("Unknown State", style: TextStyle(fontSize: 18)),
          ]
        ],
      ),
    );
  }

  Widget _buildQuickMetrics(BuildContext context, double confidence, int processingTime) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Adjusted padding
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickMetric('Confidence', '${confidence.toStringAsFixed(1)}%',
              Icons.verified_outlined, Colors.green.shade600),
          Container(width: 1, height: 40, color: Colors.grey.shade300), // Increased height
          _buildQuickMetric('Latency', '${processingTime} ms',
              Icons.speed_outlined, Colors.blue.shade600),
        ],
      ),
    );
  }

  Widget _buildQuickMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color), // Slightly larger icon
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 2), // Reduced space
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // Helper for consistent card decoration
  BoxDecoration _cardDecoration(BuildContext context, {Color? shadowColor}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: shadowColor ?? Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

// --- Record Button Widget ---
class RecordButtonWidget extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;

  const RecordButtonWidget({
    required this.isRecording,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isRecording ? null : onPressed, // Disable tap when recording
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 90, // Slightly larger base size
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isRecording
                ? [Colors.red.shade500, Colors.red.shade700]
                : [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isRecording ? Colors.red : Theme.of(context).colorScheme.primary)
                  .withOpacity(0.4),
              blurRadius: isRecording ? 15 : 20, // Different blur for states
              spreadRadius: isRecording ? 1 : 0, // Slight spread when recording
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          isRecording ? Icons.mic_off_outlined : Icons.mic_none_outlined, // Changed icons
          size: 42, // Slightly larger icon
          color: Colors.white,
        ),
      ),
    );
  }
}

// --- Instructions Widget ---
class InstructionsWidget extends StatelessWidget {
  const InstructionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20), // More padding
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align top
        children: [
          Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Tap the microphone button below to record 4 seconds of speech for emotion analysis.',
              style: TextStyle(
                fontSize: 13.5, // Slightly larger font
                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                height: 1.4, // Improved line spacing
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Probability Distribution Widget ---
class ProbabilityDistributionWidget extends StatelessWidget {
  final Map<String, double> probabilities;
  final Map<String, EmotionData> emotionMap;
  final String predictedEmotion;

  const ProbabilityDistributionWidget({
    required this.probabilities,
    required this.emotionMap,
    required this.predictedEmotion,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Sort probabilities high to low for display
    final sortedEntries = probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Probability Distribution',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20), // More space
          if (sortedEntries.isEmpty)
            const Text("No probability data available.", style: TextStyle(color: Colors.grey))
          else
            ...sortedEntries.map((entry) {
              final emotionData = emotionMap[entry.key];
              final isTop = entry.key == predictedEmotion;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14), // More space between bars
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(emotionData?.icon ?? Icons.circle_outlined, // Fallback icon
                                size: 18, color: emotionData?.color ?? Colors.grey),
                            const SizedBox(width: 10),
                            Text(
                              emotionData?.label ?? entry.key, // Use label if available
                              style: TextStyle(
                                fontSize: 14, // Larger font
                                fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                color: isTop ? emotionData?.color : Colors.grey.shade800, // Darker grey
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${entry.value.toStringAsFixed(1)}%', // One decimal place
                          style: TextStyle(
                            fontSize: 13, // Slightly larger
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8), // More space
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5), // More rounded
                      child: LinearProgressIndicator(
                        value: entry.value / 100.0,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          emotionData?.color ?? Colors.grey,
                        ),
                        minHeight: isTop ? 10 : 8, // Thicker bars
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}

// --- Technical Specs Widget ---
class TechnicalSpecsWidget extends StatelessWidget {
  final int audioFileSizeKB;
  final int processingTime;

  const TechnicalSpecsWidget({
    required this.audioFileSizeKB,
    required this.processingTime,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_input_component_outlined, // Outlined icon
                  size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Signal & Processing Metrics', // Updated title
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSpecRow('Sample Rate', '22,050 Hz', Icons.graphic_eq_outlined),
          _buildSpecRow('Audio Duration', '4.00 seconds', Icons.timer_outlined),
          _buildSpecRow('Est. File Size', '~ $audioFileSizeKB KB',
              Icons.insert_drive_file_outlined),
          _buildSpecRow('Encoding', '16-bit PCM WAV', Icons.waves_outlined),
          _buildSpecRow('Channels', 'Mono (1)', Icons.speaker_outlined),
          _buildSpecRow('Server Latency', '$processingTime ms', Icons.speed_outlined),
        ],
      ),
    );
  }

  // Helper for spec rows (can be kept private or moved to a utils file)
  Widget _buildSpecRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14), // More space
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500), // Slightly larger
          const SizedBox(width: 12), // More space
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700), // Slightly larger
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5, // Slightly larger
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900, // Darker
            ),
          ),
        ],
      ),
    );
  }
}

// --- Model Info Widget ---
class ModelInfoWidget extends StatelessWidget {
  final String modelArchitecture;
  final String featureExtraction;

  const ModelInfoWidget({
    required this.modelArchitecture,
    required this.featureExtraction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.memory_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Model Architecture',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSpecRow('Architecture', modelArchitecture, Icons.account_tree_outlined),
          _buildSpecRow('Features Used', featureExtraction, Icons.tune_outlined), // Renamed label
          _buildSpecRow('Framework', 'TensorFlow / Keras', Icons.code_outlined),
          _buildSpecRow('Output Classes', '4 Emotions', Icons.category_outlined), // Updated value
          _buildSpecRow('Final Activation', 'Softmax', Icons.functions_outlined),
          _buildSpecRow('Inference Target', 'CPU (Server)', Icons.dns_outlined), // Updated value
        ],
      ),
    );
  }
  // Re-use the spec row builder
  Widget _buildSpecRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }
}