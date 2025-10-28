import 'package:emotion_detector_app/widgets/ui_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:io';

import 'model/emotion_view_model.dart'; // Import for HttpOverrides

void main() {
  // Allow connections to local server (remove for production)
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the entire app with ChangeNotifierProvider
    return ChangeNotifierProvider(
      create: (_) => EmotionViewModel(), // Create the ViewModel instance
      child: MaterialApp(
        title: 'Speech Emotion Recognition',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1976D2), // Consistent seed color
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Light background
          appBarTheme: const AppBarTheme( // Optional: Style AppBar if needed
            backgroundColor: Color(0xFF1976D2),
            foregroundColor: Colors.white,
          ),
        ),
        home: const EmotionHomePage(), // Keep EmotionHomePage as the entry
      ),
    );
  }
}

// EmotionHomePage now needs to be StatefulWidget for the AnimationController
class EmotionHomePage extends StatefulWidget {
  const EmotionHomePage({super.key});

  @override
  State<EmotionHomePage> createState() => _EmotionHomePageState();
}

class _EmotionHomePageState extends State<EmotionHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller here
    _animationController = AnimationController(
      vsync: this, // Use 'this' as the TickerProvider
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to changes in EmotionViewModel
    return Consumer<EmotionViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Use the HeaderWidget
                HeaderWidget(predictionCount: viewModel.predictionCount),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          // Use the StatusCardWidget
                          StatusCardWidget(
                            viewModel: viewModel,
                            animationController: _animationController,
                          ),
                          const SizedBox(height: 24),
                          // Use the RecordButtonWidget
                          RecordButtonWidget(
                            isRecording: viewModel.isRecording,
                            onPressed: viewModel.startRecording, // Call ViewModel method
                          ),
                          const SizedBox(height: 20),
                          // Conditionally display Instructions or Results/Info
                          if (viewModel.status == EmotionStatus.ready)
                            const InstructionsWidget(), // Use InstructionsWidget

                          if (viewModel.status == EmotionStatus.complete || viewModel.status == EmotionStatus.error) ...[
                            const SizedBox(height: 24),
                            // Use ProbabilityDistributionWidget
                            if (viewModel.allProbabilities.isNotEmpty && viewModel.status != EmotionStatus.error)
                              ProbabilityDistributionWidget(
                                probabilities: viewModel.allProbabilities,
                                emotionMap: viewModel.emotionMap,
                                predictedEmotion: viewModel.resultLabel,
                              ),
                            if (viewModel.status != EmotionStatus.error)
                              const SizedBox(height: 16),
                            // Use TechnicalSpecsWidget
                            if (viewModel.status != EmotionStatus.error)
                              TechnicalSpecsWidget(
                                audioFileSizeKB: viewModel.audioFileSizeKB,
                                processingTime: viewModel.processingTime,
                              ),
                            if (viewModel.status != EmotionStatus.error)
                              const SizedBox(height: 16),
                            // Use ModelInfoWidget
                            if (viewModel.status != EmotionStatus.error)
                              ModelInfoWidget(
                                modelArchitecture: viewModel.modelArchitecture,
                                featureExtraction: viewModel.featureExtraction,
                              ),
                          ],
                          const SizedBox(height: 20), // Bottom padding
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Add a Reset button for Error state
          floatingActionButton: viewModel.status == EmotionStatus.error
              ? FloatingActionButton.extended(
            onPressed: viewModel.reset, // Call reset method
            label: const Text("Try Again"),
            icon: const Icon(Icons.refresh),
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
          )
              : null, // No FAB if not in error state (handled by RecordButton)
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}

// Keep MyHttpOverrides class here or move to a separate config file
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}