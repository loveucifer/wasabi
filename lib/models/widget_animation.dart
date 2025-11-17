import 'package:wasabi/theme/animations.dart';

class WidgetAnimation {
  final String id;
  final AnimationType type;
  final String targetElementId;
  final int duration;
  final String curve;
  final int delay;
  final bool loop;
  final bool autoStart;
  final Map<String, dynamic> properties;

  WidgetAnimation({
    required this.id,
    required this.type,
    required this.targetElementId,
    this.duration = 300,
    this.curve = 'easeInOut',
    this.delay = 0,
    this.loop = false,
    this.autoStart = true,
    this.properties = const {},
  });

  factory WidgetAnimation.fromJson(Map<String, dynamic> json) {
    return WidgetAnimation(
      id: json['id']?.toString() ?? '',
      type: getAnimationTypeByName(json['type']?.toString() ?? 'fade'),
      targetElementId: (json['targetElementId'] ?? json['target'])?.toString() ?? '',
      duration: _toInt(json['duration'], 300),
      curve: json['curve']?.toString() ?? 'easeInOut',
      delay: _toInt(json['delay'], 0),
      loop: json['loop'] == true || json['loop']?.toString() == 'true',
      autoStart: json['autoStart'] != false && json['autoStart']?.toString() != 'false',
      properties: json['properties'] is Map
          ? Map<String, dynamic>.from(json['properties'])
          : {},
    );
  }

  static int _toInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'targetElementId': targetElementId,
      'duration': duration,
      'curve': curve,
      'delay': delay,
      'loop': loop,
      'autoStart': autoStart,
      'properties': properties,
    };
  }
}
