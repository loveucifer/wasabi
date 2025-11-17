import 'package:flutter/material.dart';

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration verySlow = Duration(milliseconds: 600);
  static const Duration extraSlow = Duration(milliseconds: 800);

  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve spring = Curves.easeOutBack;

  static Curve getCurveByName(String name) {
    switch (name.toLowerCase()) {
      case 'easein':
        return Curves.easeIn;
      case 'easeout':
        return Curves.easeOut;
      case 'easeinout':
        return Curves.easeInOut;
      case 'elasticout':
        return Curves.elasticOut;
      case 'bounceout':
        return Curves.bounceOut;
      case 'linear':
        return Curves.linear;
      default:
        return Curves.easeInOut;
    }
  }

  static Duration getDurationFromMs(int milliseconds) {
    return Duration(milliseconds: milliseconds);
  }
}

enum AnimationType {
  fade,
  scale,
  slide,
  rotate,
  pulse,
  bounce,
  shimmer,
  countUp,
}

AnimationType getAnimationTypeByName(String name) {
  switch (name.toLowerCase()) {
    case 'fade':
      return AnimationType.fade;
    case 'scale':
      return AnimationType.scale;
    case 'slide':
      return AnimationType.slide;
    case 'rotate':
      return AnimationType.rotate;
    case 'pulse':
      return AnimationType.pulse;
    case 'bounce':
      return AnimationType.bounce;
    case 'shimmer':
      return AnimationType.shimmer;
    case 'countup':
      return AnimationType.countUp;
    default:
      return AnimationType.fade;
  }
}
