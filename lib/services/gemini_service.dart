import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:wasabi/models/widget_spec.dart';
import 'package:wasabi/models/widget_size.dart';

class GeminiService {
  GenerativeModel? _model;

  void initialize(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
      ),
    );
  }

  Future<WidgetSpec> generateWidget({
    required String prompt,
    WidgetSize size = WidgetSize.medium,
    String theme = 'minimal',
    String? primaryColor,
  }) async {
    if (_model == null) {
      throw Exception('Gemini API not initialized');
    }

    try {
      final userPrompt = _buildPrompt(prompt, size, theme);

      final response = await _model!.generateContent([
        Content.text(userPrompt),
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('No response from Gemini');
      }

      final jsonString = _extractJson(response.text!);
      final jsonData = jsonDecode(jsonString);

      return WidgetSpec.fromJson(jsonData);
    } on FormatException catch (e) {
      throw Exception('Invalid JSON: ${e.message}');
    } catch (e) {
      final msg = e.toString();

      if (msg.contains('INVALID_ARGUMENT')) {
        throw Exception('Invalid request - try simpler prompt');
      }
      if (msg.contains('PERMISSION_DENIED')) {
        throw Exception('API key invalid or no access');
      }
      if (msg.contains('RESOURCE_EXHAUSTED')) {
        throw Exception('Quota exceeded - wait and retry');
      }
      if (msg.contains('UNAUTHENTICATED')) {
        throw Exception('Invalid API key');
      }

      throw Exception('Error: $msg');
    }
  }

  String _buildPrompt(String userRequest, WidgetSize size, String theme) {
    final example = '''{"name":"Clock","size":"${size.name}","background":{"type":"solid","color":"#FFFFFF"},"padding":16,"cornerRadius":16,"elements":[{"id":"t1","type":"value","binding":"time","format":"HH:mm","fontSize":32,"fontWeight":700,"color":"#000000"}],"animations":[],"updateInterval":60000}''';

    return '''Create a ${size.name} widget (${size.width}x${size.height}pt) for: $userRequest

Theme: $theme
Max elements: ${size.maxElements}

Example JSON format:
$example

Element types: text, icon, value (binding: time|date|battery), progress
Return ONLY valid JSON, no markdown or explanation.''';
  }

  String _extractJson(String text) {
    final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
    if (jsonMatch != null) {
      return jsonMatch.group(1)!.trim();
    }

    final codeMatch = RegExp(r'```\s*([\s\S]*?)\s*```').firstMatch(text);
    if (codeMatch != null) {
      return codeMatch.group(1)!.trim();
    }

    final braceStart = text.indexOf('{');
    final braceEnd = text.lastIndexOf('}');
    if (braceStart != -1 && braceEnd != -1) {
      return text.substring(braceStart, braceEnd + 1);
    }

    return text.trim();
  }

}
