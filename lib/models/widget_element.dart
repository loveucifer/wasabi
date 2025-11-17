import 'package:flutter/material.dart';

enum ElementType {
  text,
  icon,
  value,
  progress,
  spacer,
}

ElementType getElementTypeByName(String name) {
  switch (name.toLowerCase()) {
    case 'text':
      return ElementType.text;
    case 'icon':
      return ElementType.icon;
    case 'value':
      return ElementType.value;
    case 'progress':
      return ElementType.progress;
    case 'spacer':
      return ElementType.spacer;
    default:
      return ElementType.text;
  }
}

double _toDouble(dynamic value, double defaultValue) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

int _toInt(dynamic value, int defaultValue) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

double? _toDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

abstract class WidgetElement {
  final String id;
  final ElementType type;
  final double? x;
  final double? y;
  final double? width;
  final double? height;

  WidgetElement({
    required this.id,
    required this.type,
    this.x,
    this.y,
    this.width,
    this.height,
  });

  factory WidgetElement.fromJson(Map<String, dynamic> json) {
    final type = getElementTypeByName(json['type'] ?? 'text');

    switch (type) {
      case ElementType.text:
        return TextElement.fromJson(json);
      case ElementType.icon:
        return IconElement.fromJson(json);
      case ElementType.value:
        return ValueElement.fromJson(json);
      case ElementType.progress:
        return ProgressElement.fromJson(json);
      case ElementType.spacer:
        return SpacerElement.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}

class TextElement extends WidgetElement {
  final String content;
  final double fontSize;
  final int fontWeight;
  final String color;
  final String alignment;

  TextElement({
    required super.id,
    required this.content,
    this.fontSize = 16.0,
    this.fontWeight = 400,
    this.color = '#000000',
    this.alignment = 'left',
    super.x,
    super.y,
    super.width,
    super.height,
  }) : super(type: ElementType.text);

  factory TextElement.fromJson(Map<String, dynamic> json) {
    return TextElement(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      fontSize: _toDouble(json['fontSize'], 16.0),
      fontWeight: _toInt(json['fontWeight'], 400),
      color: json['color']?.toString() ?? '#000000',
      alignment: json['alignment']?.toString() ?? 'left',
      x: _toDoubleOrNull(json['x']),
      y: _toDoubleOrNull(json['y']),
      width: _toDoubleOrNull(json['width']),
      height: _toDoubleOrNull(json['height']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'text',
      'content': content,
      'fontSize': fontSize,
      'fontWeight': fontWeight,
      'color': color,
      'alignment': alignment,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
    };
  }

  FontWeight get fontWeightValue {
    if (fontWeight >= 700) return FontWeight.w700;
    if (fontWeight >= 600) return FontWeight.w600;
    if (fontWeight >= 500) return FontWeight.w500;
    return FontWeight.w400;
  }

  TextAlign get textAlign {
    switch (alignment.toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  Color get colorValue {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.black;
    }
  }
}

class IconElement extends WidgetElement {
  final String iconName;
  final double size;
  final String color;

  IconElement({
    required super.id,
    required this.iconName,
    this.size = 24.0,
    this.color = '#000000',
    super.x,
    super.y,
    super.width,
    super.height,
  }) : super(type: ElementType.icon);

  factory IconElement.fromJson(Map<String, dynamic> json) {
    return IconElement(
      id: json['id']?.toString() ?? '',
      iconName: (json['name'] ?? json['iconName'])?.toString() ?? 'help',
      size: _toDouble(json['size'], 24.0),
      color: json['color']?.toString() ?? '#000000',
      x: _toDoubleOrNull(json['x']),
      y: _toDoubleOrNull(json['y']),
      width: _toDoubleOrNull(json['width']),
      height: _toDoubleOrNull(json['height']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'icon',
      'name': iconName,
      'size': size,
      'color': color,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
    };
  }

  Color get colorValue {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.black;
    }
  }

  IconData get iconData {
    return Icons.widgets;
  }
}

class ValueElement extends WidgetElement {
  final String binding;
  final String format;
  final String prefix;
  final String suffix;
  final double fontSize;
  final int fontWeight;
  final String color;

  ValueElement({
    required super.id,
    required this.binding,
    this.format = '',
    this.prefix = '',
    this.suffix = '',
    this.fontSize = 16.0,
    this.fontWeight = 400,
    this.color = '#000000',
    super.x,
    super.y,
    super.width,
    super.height,
  }) : super(type: ElementType.value);

  factory ValueElement.fromJson(Map<String, dynamic> json) {
    return ValueElement(
      id: json['id']?.toString() ?? '',
      binding: json['binding']?.toString() ?? 'time',
      format: json['format']?.toString() ?? '',
      prefix: json['prefix']?.toString() ?? '',
      suffix: json['suffix']?.toString() ?? '',
      fontSize: _toDouble(json['fontSize'], 16.0),
      fontWeight: _toInt(json['fontWeight'], 400),
      color: json['color']?.toString() ?? '#000000',
      x: _toDoubleOrNull(json['x']),
      y: _toDoubleOrNull(json['y']),
      width: _toDoubleOrNull(json['width']),
      height: _toDoubleOrNull(json['height']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'value',
      'binding': binding,
      'format': format,
      'prefix': prefix,
      'suffix': suffix,
      'fontSize': fontSize,
      'fontWeight': fontWeight,
      'color': color,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
    };
  }

  FontWeight get fontWeightValue {
    if (fontWeight >= 700) return FontWeight.w700;
    if (fontWeight >= 600) return FontWeight.w600;
    if (fontWeight >= 500) return FontWeight.w500;
    return FontWeight.w400;
  }

  Color get colorValue {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.black;
    }
  }
}

class ProgressElement extends WidgetElement {
  final String binding;
  final double barHeight;
  final String backgroundColor;
  final String foregroundColor;
  final double cornerRadius;

  ProgressElement({
    required super.id,
    required this.binding,
    this.barHeight = 8.0,
    this.backgroundColor = '#E0E0E0',
    this.foregroundColor = '#000000',
    this.cornerRadius = 4.0,
    super.x,
    super.y,
    super.width,
    super.height,
  }) : super(type: ElementType.progress);

  factory ProgressElement.fromJson(Map<String, dynamic> json) {
    return ProgressElement(
      id: json['id']?.toString() ?? '',
      binding: json['binding']?.toString() ?? 'battery',
      barHeight: _toDouble(json['height'] ?? json['barHeight'], 8.0),
      backgroundColor: json['backgroundColor']?.toString() ?? '#E0E0E0',
      foregroundColor: (json['foregroundColor'] ?? json['color'])?.toString() ?? '#000000',
      cornerRadius: _toDouble(json['cornerRadius'], 4.0),
      x: _toDoubleOrNull(json['x']),
      y: _toDoubleOrNull(json['y']),
      width: _toDoubleOrNull(json['width']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'progress',
      'binding': binding,
      'height': barHeight,
      'backgroundColor': backgroundColor,
      'foregroundColor': foregroundColor,
      'cornerRadius': cornerRadius,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (width != null) 'width': width,
    };
  }

  Color get backgroundColorValue {
    try {
      return Color(int.parse(backgroundColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey[300]!;
    }
  }

  Color get foregroundColorValue {
    try {
      return Color(int.parse(foregroundColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.black;
    }
  }
}

class SpacerElement extends WidgetElement {
  final double spacing;
  final bool flexible;

  SpacerElement({
    required super.id,
    this.spacing = 8.0,
    this.flexible = false,
    super.x,
    super.y,
    super.width,
    super.height,
  }) : super(type: ElementType.spacer);

  factory SpacerElement.fromJson(Map<String, dynamic> json) {
    return SpacerElement(
      id: json['id']?.toString() ?? '',
      spacing: _toDouble(json['height'] ?? json['spacing'], 8.0),
      flexible: json['flexible'] == true || json['flexible']?.toString() == 'true',
      x: _toDoubleOrNull(json['x']),
      y: _toDoubleOrNull(json['y']),
      width: _toDoubleOrNull(json['width']),
      height: _toDoubleOrNull(json['height']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'spacer',
      'height': spacing,
      'flexible': flexible,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (width != null) 'width': width,
    };
  }
}
