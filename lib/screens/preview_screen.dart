import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wasabi/providers/generation_provider.dart';
import 'package:wasabi/providers/widget_provider.dart';
import 'package:wasabi/models/widget_model.dart';
import 'package:wasabi/widgets/widget_renderer.dart';
import 'package:wasabi/theme/colors.dart';
import 'package:wasabi/theme/typography.dart';
import 'package:wasabi/theme/spacing.dart';
import 'package:intl/intl.dart';

class PreviewScreen extends StatefulWidget {
  final WidgetModel? widget;

  const PreviewScreen({super.key, this.widget});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addToHomeScreen() async {
    final generationProvider = context.read<GenerationProvider>();
    final widgetProvider = context.read<WidgetProvider>();

    final widgetToAdd =
        widget.widget ?? generationProvider.generatedWidget;

    if (widgetToAdd == null) return;

    final success = await widgetProvider.addWidget(widgetToAdd);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Widget added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      generationProvider.clearGeneration();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add widget'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _regenerate() async {
    final generationProvider = context.read<GenerationProvider>();
    await generationProvider.regenerateWidget();

    if (mounted && generationProvider.state == GenerationState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            generationProvider.error ?? 'Failed to regenerate widget',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Preview'),
      ),
      body: Consumer<GenerationProvider>(
        builder: (context, generationProvider, widgetChild) {
          final displayWidget =
              widget.widget ?? generationProvider.generatedWidget;

          if (displayWidget == null) {
            return const Center(
              child: Text('No widget to preview'),
            );
          }

          if (generationProvider.isGenerating) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.pureBlack,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Regenerating Widget...',
                    style: AppTypography.headline,
                  ),
                ],
              ),
            );
          }

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, animChild) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child: Text(
                          displayWidget.name,
                          style: AppTypography.title2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child: WidgetRenderer(
                          spec: displayWidget.spec,
                          enableAnimations: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          decoration: BoxDecoration(
                            color: AppColors.gray50,
                            borderRadius:
                                BorderRadius.circular(AppRadius.medium),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _MetadataChip(
                                icon: Icons.aspect_ratio,
                                label: displayWidget.size.displayName,
                              ),
                              _MetadataChip(
                                icon: Icons.palette,
                                label: displayWidget.theme,
                              ),
                              _MetadataChip(
                                icon: Icons.calendar_today,
                                label: DateFormat('MMM dd')
                                    .format(displayWidget.createdAt),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    if (widget.widget == null) ...[
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ElevatedButton(
                            onPressed: _addToHomeScreen,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                            ),
                            child: const Text('Add to Home Screen'),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: OutlinedButton(
                            onPressed: _regenerate,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              side: const BorderSide(color: AppColors.gray300),
                            ),
                            child: const Text('Regenerate'),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetadataChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.gray600),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.caption,
        ),
      ],
    );
  }
}
