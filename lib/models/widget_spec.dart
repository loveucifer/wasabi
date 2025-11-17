import 'package:flutter/material.dart';
import 'widget_size.dart';
import 'widget_element.dart';
import 'widget_animation.dart';

class BackgroundConfig {
  final String type;
  final String? color;
  final List<String>? gradientColors;
  final String? gradientDirection;

  BackgroundConfig({
    this.type = 'solid',
    this.color,
    this.gradientColors,
    this.gradientDirection = 'vertical',
  });

  factory BackgroundConfig.fromJson(Map<String, dynamic> json) {
    return BackgroundConfig(
      type: json['type'] ?? 'solid',
      color: json['color'],
      gradientColors: json['gradientColors'] != null
          ? List<String>.from(json['gradientColors'])
          : null,
      gradientDirection: json['gradientDirection'] ?? 'vertical',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (color != null) 'color': color,
      if (gradientColors != null) 'gradientColors': gradientColors,
      'gradientDirection': gradientDirection,
    };
  }

  Color get colorValue {
    try {
      return Color(int.parse((color ?? '#FFFFFF').replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.white;
    }
  }

  List<Color> get gradientColorValues {
    if (gradientColors == null) return [Colors.white, Colors.grey[200]!];
    return gradientColors!.map((c) {
      try {
        return Color(int.parse(c.replaceFirst('#', '0xFF')));
      } catch (e) {
        return Colors.grey;
      }
    }).toList();
  }

  AlignmentGeometry get gradientBegin {
    switch (gradientDirection?.toLowerCase()) {
      case 'horizontal':
        return Alignment.centerLeft;
      case 'diagonal':
        return Alignment.topLeft;
      default:
        return Alignment.topCenter;
    }
  }

  AlignmentGeometry get gradientEnd {
    switch (gradientDirection?.toLowerCase()) {
      case 'horizontal':
        return Alignment.centerRight;
      case 'diagonal':
        return Alignment.bottomRight;
      default:
        return Alignment.bottomCenter;
    }
  }
}

class WidgetSpec {
  final String name;
  final WidgetSize size;
  final BackgroundConfig background;
  final double padding;
  final double cornerRadius;
  final List<WidgetElement> elements;
  final List<WidgetAnimation> animations;
  final Map<String, String> dataBindings;
  final int updateInterval;

  WidgetSpec({
    required this.name,
    required this.size,
    required this.background,
    this.padding = 16.0,
    this.cornerRadius = 16.0,
    this.elements = const [],
    this.animations = const [],
    this.dataBindings = const {},
    this.updateInterval = 60000,
  });

  factory WidgetSpec.fromJson(Map<String, dynamic> json) {
    try {
      return WidgetSpec(
        name: json['name']?.toString() ?? 'Untitled Widget',
        size: WidgetSize.fromString(json['size']?.toString() ?? 'medium'),
        background: BackgroundConfig.fromJson(
          json['background'] is Map<String, dynamic>
              ? json['background']
              : {'type': 'solid', 'color': '#FFFFFF'},
        ),
        padding: _parseDouble(json['padding'], 16.0),
        cornerRadius: _parseDouble(json['cornerRadius'], 16.0),
        elements: _parseElements(json['elements']),
        animations: _parseAnimations(json['animations']),
        dataBindings: json['dataBindings'] != null
            ? Map<String, String>.from(json['dataBindings'])
            : {},
        updateInterval: _parseInt(json['updateInterval'], 60000),
      );
    } catch (e) {
      throw FormatException('Invalid widget spec format: ${e.toString()}');
    }
  }

  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static List<WidgetElement> _parseElements(dynamic elementsJson) {
    if (elementsJson == null) return [];
    if (elementsJson is! List) return [];

    final elements = <WidgetElement>[];
    for (final element in elementsJson) {
      try {
        if (element is Map<String, dynamic>) {
          elements.add(WidgetElement.fromJson(element));
        }
      } catch (e) {
        continue;
      }
    }
    return elements;
  }

  static List<WidgetAnimation> _parseAnimations(dynamic animationsJson) {
    if (animationsJson == null) return [];
    if (animationsJson is! List) return [];

    final animations = <WidgetAnimation>[];
    for (final animation in animationsJson) {
      try {
        if (animation is Map<String, dynamic>) {
          animations.add(WidgetAnimation.fromJson(animation));
        }
      } catch (e) {
        continue;
      }
    }
    return animations;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'size': size.name,
      'background': background.toJson(),
      'padding': padding,
      'cornerRadius': cornerRadius,
      'elements': elements.map((e) => e.toJson()).toList(),
      'animations': animations.map((a) => a.toJson()).toList(),
      'dataBindings': dataBindings,
      'updateInterval': updateInterval,
    };
  }
}
