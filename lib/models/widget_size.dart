enum WidgetSize {
  small,
  medium,
  large;

  String get displayName {
    switch (this) {
      case WidgetSize.small:
        return 'Small';
      case WidgetSize.medium:
        return 'Medium';
      case WidgetSize.large:
        return 'Large';
    }
  }

  double get width {
    switch (this) {
      case WidgetSize.small:
        return 158.0;
      case WidgetSize.medium:
        return 338.0;
      case WidgetSize.large:
        return 338.0;
    }
  }

  double get height {
    switch (this) {
      case WidgetSize.small:
        return 158.0;
      case WidgetSize.medium:
        return 158.0;
      case WidgetSize.large:
        return 354.0;
    }
  }

  int get maxElements {
    switch (this) {
      case WidgetSize.small:
        return 3;
      case WidgetSize.medium:
        return 6;
      case WidgetSize.large:
        return 12;
    }
  }

  static WidgetSize fromString(String value) {
    switch (value.toLowerCase()) {
      case 'small':
      case 's':
        return WidgetSize.small;
      case 'medium':
      case 'm':
        return WidgetSize.medium;
      case 'large':
      case 'l':
        return WidgetSize.large;
      default:
        return WidgetSize.medium;
    }
  }
}
