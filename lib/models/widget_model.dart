import 'dart:convert';
import 'widget_spec.dart';
import 'widget_size.dart';

class WidgetModel {
  final String id;
  final String name;
  final String prompt;
  final WidgetSpec spec;
  final String? backgroundColor;
  final WidgetSize size;
  final String theme;
  final DateTime createdAt;
  int useCount;

  WidgetModel({
    required this.id,
    required this.name,
    required this.prompt,
    required this.spec,
    this.backgroundColor,
    required this.size,
    this.theme = 'minimal',
    required this.createdAt,
    this.useCount = 0,
  });

  factory WidgetModel.fromMap(Map<String, dynamic> map) {
    final jsonSpec = jsonDecode(map['json_spec'] as String);

    return WidgetModel(
      id: map['id'] as String,
      name: map['name'] as String,
      prompt: map['prompt'] as String,
      spec: WidgetSpec.fromJson(jsonSpec),
      backgroundColor: map['background_color'] as String?,
      size: WidgetSize.fromString(map['size'] as String),
      theme: map['theme'] as String? ?? 'minimal',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      useCount: map['use_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'prompt': prompt,
      'json_spec': jsonEncode(spec.toJson()),
      'background_color': backgroundColor,
      'size': size.name,
      'theme': theme,
      'created_at': createdAt.millisecondsSinceEpoch,
      'use_count': useCount,
    };
  }

  WidgetModel copyWith({
    String? id,
    String? name,
    String? prompt,
    WidgetSpec? spec,
    String? backgroundColor,
    WidgetSize? size,
    String? theme,
    DateTime? createdAt,
    int? useCount,
  }) {
    return WidgetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      prompt: prompt ?? this.prompt,
      spec: spec ?? this.spec,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      size: size ?? this.size,
      theme: theme ?? this.theme,
      createdAt: createdAt ?? this.createdAt,
      useCount: useCount ?? this.useCount,
    );
  }
}
