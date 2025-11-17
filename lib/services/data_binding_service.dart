import 'package:intl/intl.dart';
import 'dart:math';

class DataBindingService {
  static String getBindingValue(String binding, {String format = ''}) {
    switch (binding.toLowerCase()) {
      case 'time':
        return _getTime(format);
      case 'date':
        return _getDate(format);
      case 'battery':
        return _getBattery();
      case 'weather':
        return _getWeather();
      case 'temperature':
        return _getTemperature();
      case 'steps':
        return _getSteps();
      default:
        return binding;
    }
  }

  static double getBindingProgress(String binding) {
    switch (binding.toLowerCase()) {
      case 'battery':
        return _getBatteryProgress();
      case 'steps':
        return _getStepsProgress();
      default:
        return 0.5;
    }
  }

  static String _getTime(String format) {
    final now = DateTime.now();
    if (format.isEmpty) {
      return DateFormat('HH:mm').format(now);
    }
    return DateFormat(format).format(now);
  }

  static String _getDate(String format) {
    final now = DateTime.now();
    if (format.isEmpty) {
      return DateFormat('MMM dd, yyyy').format(now);
    }
    return DateFormat(format).format(now);
  }

  static String _getBattery() {
    return '${(Random().nextInt(40) + 60)}%';
  }

  static double _getBatteryProgress() {
    return (Random().nextInt(40) + 60) / 100;
  }

  static String _getWeather() {
    final conditions = ['Sunny', 'Cloudy', 'Rainy', 'Partly Cloudy'];
    return conditions[Random().nextInt(conditions.length)];
  }

  static String _getTemperature() {
    return '${Random().nextInt(20) + 60}°';
  }

  static String _getSteps() {
    return '${Random().nextInt(5000) + 3000}';
  }

  static double _getStepsProgress() {
    final steps = Random().nextInt(5000) + 3000;
    return steps / 10000;
  }
}
