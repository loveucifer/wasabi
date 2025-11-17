import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wasabi/models/widget_spec.dart';
import 'package:wasabi/models/widget_element.dart';
import 'package:wasabi/models/widget_animation.dart';
import 'package:wasabi/services/data_binding_service.dart';
import 'package:wasabi/theme/animations.dart';

class WidgetRenderer extends StatefulWidget {
  final WidgetSpec spec;
  final bool enableAnimations;

  const WidgetRenderer({
    super.key,
    required this.spec,
    this.enableAnimations = true,
  });

  @override
  State<WidgetRenderer> createState() => _WidgetRendererState();
}

class _WidgetRendererState extends State<WidgetRenderer>
    with TickerProviderStateMixin {
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, Animation<double>> _animations = {};
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupUpdateTimer();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    _updateTimer?.cancel();
    super.dispose();
  }

  void _setupAnimations() {
    if (!widget.enableAnimations) return;

    for (final animation in widget.spec.animations) {
      final controller = AnimationController(
        duration: AppAnimations.getDurationFromMs(animation.duration),
        vsync: this,
      );

      Animation<double> anim;
      final curve = AppAnimations.getCurveByName(animation.curve);

      switch (animation.type) {
        case AnimationType.fade:
          final from = animation.properties['from']?.toDouble() ?? 0.0;
          final to = animation.properties['to']?.toDouble() ?? 1.0;
          anim = Tween<double>(begin: from, end: to).animate(
            CurvedAnimation(parent: controller, curve: curve),
          );
          break;

        case AnimationType.scale:
          final from = animation.properties['from']?.toDouble() ?? 0.0;
          final to = animation.properties['to']?.toDouble() ?? 1.0;
          anim = Tween<double>(begin: from, end: to).animate(
            CurvedAnimation(parent: controller, curve: curve),
          );
          break;

        case AnimationType.slide:
        case AnimationType.rotate:
          final from = animation.properties['from']?.toDouble() ?? 0.0;
          final to = animation.properties['to']?.toDouble() ?? 1.0;
          anim = Tween<double>(begin: from, end: to).animate(
            CurvedAnimation(parent: controller, curve: curve),
          );
          break;

        case AnimationType.pulse:
          anim = Tween<double>(begin: 1.0, end: 1.1).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );
          break;

        case AnimationType.bounce:
          anim = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.bounceOut),
          );
          break;

        default:
          anim = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: curve),
          );
      }

      _animationControllers[animation.id] = controller;
      _animations[animation.id] = anim;

      if (animation.autoStart) {
        Future.delayed(
          Duration(milliseconds: animation.delay),
          () {
            if (mounted) {
              if (animation.loop) {
                controller.repeat(reverse: true);
              } else {
                controller.forward();
              }
            }
          },
        );
      }
    }
  }

  void _setupUpdateTimer() {
    if (widget.spec.updateInterval > 0) {
      _updateTimer = Timer.periodic(
        Duration(milliseconds: widget.spec.updateInterval),
        (_) {
          if (mounted) setState(() {});
        },
      );
    }
  }

  WidgetAnimation? _getAnimationForElement(String elementId) {
    try {
      return widget.spec.animations.firstWhere(
        (a) => a.targetElementId == elementId,
      );
    } catch (e) {
      return null;
    }
  }

  Widget _buildElement(WidgetElement element) {
    Widget child;

    switch (element.type) {
      case ElementType.text:
        child = _buildTextElement(element as TextElement);
        break;
      case ElementType.icon:
        child = _buildIconElement(element as IconElement);
        break;
      case ElementType.value:
        child = _buildValueElement(element as ValueElement);
        break;
      case ElementType.progress:
        child = _buildProgressElement(element as ProgressElement);
        break;
      case ElementType.spacer:
        child = _buildSpacerElement(element as SpacerElement);
        break;
    }

    final animation = _getAnimationForElement(element.id);
    if (animation != null && widget.enableAnimations) {
      child = _applyAnimation(child, animation);
    }

    if (element.x != null && element.y != null) {
      return Positioned(
        left: element.x,
        top: element.y,
        width: element.width,
        height: element.height,
        child: child,
      );
    }

    return child;
  }

  Widget _applyAnimation(Widget child, WidgetAnimation animation) {
    final controller = _animationControllers[animation.id];
    final anim = _animations[animation.id];

    if (controller == null || anim == null) return child;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, animChild) {
        switch (animation.type) {
          case AnimationType.fade:
            return Opacity(
              opacity: anim.value,
              child: animChild,
            );

          case AnimationType.scale:
          case AnimationType.pulse:
            return Transform.scale(
              scale: anim.value,
              child: animChild,
            );

          case AnimationType.slide:
            final direction = animation.properties['direction'] ?? 'up';
            Offset offset;
            switch (direction) {
              case 'up':
                offset = Offset(0, 1 - anim.value);
                break;
              case 'down':
                offset = Offset(0, anim.value - 1);
                break;
              case 'left':
                offset = Offset(1 - anim.value, 0);
                break;
              case 'right':
                offset = Offset(anim.value - 1, 0);
                break;
              default:
                offset = Offset(0, 1 - anim.value);
            }
            return Transform.translate(
              offset: offset * 50,
              child: animChild,
            );

          case AnimationType.rotate:
            return Transform.rotate(
              angle: anim.value * 6.28318,
              child: animChild,
            );

          case AnimationType.bounce:
            return Transform.scale(
              scale: anim.value,
              child: animChild,
            );

          default:
            return animChild!;
        }
      },
      child: child,
    );
  }

  Widget _buildTextElement(TextElement element) {
    return Text(
      element.content,
      style: TextStyle(
        fontSize: element.fontSize,
        fontWeight: element.fontWeightValue,
        color: element.colorValue,
      ),
      textAlign: element.textAlign,
    );
  }

  Widget _buildIconElement(IconElement element) {
    return Icon(
      element.iconData,
      size: element.size,
      color: element.colorValue,
    );
  }

  Widget _buildValueElement(ValueElement element) {
    final value = DataBindingService.getBindingValue(
      element.binding,
      format: element.format,
    );

    return Text(
      '${element.prefix}$value${element.suffix}',
      style: TextStyle(
        fontSize: element.fontSize,
        fontWeight: element.fontWeightValue,
        color: element.colorValue,
      ),
    );
  }

  Widget _buildProgressElement(ProgressElement element) {
    final progress = DataBindingService.getBindingProgress(element.binding);

    return ClipRRect(
      borderRadius: BorderRadius.circular(element.cornerRadius),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: element.backgroundColorValue,
        valueColor: AlwaysStoppedAnimation<Color>(element.foregroundColorValue),
        minHeight: element.barHeight,
      ),
    );
  }

  Widget _buildSpacerElement(SpacerElement element) {
    if (element.flexible) {
      return const Spacer();
    }
    return SizedBox(height: element.spacing);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.spec.size.width,
      height: widget.spec.size.height,
      decoration: BoxDecoration(
        color: widget.spec.background.type == 'solid'
            ? widget.spec.background.colorValue
            : null,
        gradient: widget.spec.background.type == 'gradient'
            ? LinearGradient(
                colors: widget.spec.background.gradientColorValues,
                begin: widget.spec.background.gradientBegin,
                end: widget.spec.background.gradientEnd,
              )
            : null,
        borderRadius: BorderRadius.circular(widget.spec.cornerRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.spec.cornerRadius),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(widget.spec.padding),
              child: widget.spec.elements.any(
                (e) => e.x == null || e.y == null,
              )
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.spec.elements
                          .where((e) => e.x == null || e.y == null)
                          .map(_buildElement)
                          .toList(),
                    )
                  : const SizedBox.expand(),
            ),
            ...widget.spec.elements
                .where((e) => e.x != null && e.y != null)
                .map(_buildElement),
          ],
        ),
      ),
    );
  }
}
