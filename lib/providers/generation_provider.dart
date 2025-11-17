import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:wasabi/models/widget_model.dart';
import 'package:wasabi/models/widget_size.dart';
import 'package:wasabi/services/gemini_service.dart';

enum GenerationState {
  idle,
  generating,
  success,
  error,
}

class GenerationProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();

  GenerationState _state = GenerationState.idle;
  WidgetModel? _generatedWidget;
  String? _error;

  GenerationState get state => _state;
  WidgetModel? get generatedWidget => _generatedWidget;
  String? get error => _error;
  bool get isGenerating => _state == GenerationState.generating;

  void initializeGemini(String apiKey) {
    _geminiService.initialize(apiKey);
  }

  Future<void> generateWidget({
    required String prompt,
    WidgetSize size = WidgetSize.medium,
    String theme = 'minimal',
    String? primaryColor,
  }) async {
    _state = GenerationState.generating;
    _error = null;
    _generatedWidget = null;
    notifyListeners();

    try {
      final spec = await _geminiService.generateWidget(
        prompt: prompt,
        size: size,
        theme: theme,
        primaryColor: primaryColor,
      );

      _generatedWidget = WidgetModel(
        id: const Uuid().v4(),
        name: spec.name,
        prompt: prompt,
        spec: spec,
        backgroundColor: spec.background.color,
        size: size,
        theme: theme,
        createdAt: DateTime.now(),
      );

      _state = GenerationState.success;
    } catch (e) {
      _error = e.toString();
      _state = GenerationState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> regenerateWidget() async {
    if (_generatedWidget == null) return;

    await generateWidget(
      prompt: _generatedWidget!.prompt,
      size: _generatedWidget!.size,
      theme: _generatedWidget!.theme,
      primaryColor: _generatedWidget!.backgroundColor,
    );
  }

  void clearGeneration() {
    _state = GenerationState.idle;
    _generatedWidget = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
