import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wasabi/providers/widget_provider.dart';
import 'package:wasabi/theme/colors.dart';
import 'package:wasabi/theme/typography.dart';
import 'package:wasabi/theme/spacing.dart';
import 'package:wasabi/theme/animations.dart';
import 'package:wasabi/models/widget_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WidgetProvider>().loadWidgets();
    });
  }

  void _navigateToGenerator() {
    Navigator.of(context).pushNamed('/generator');
  }

  void _navigateToPreview(WidgetModel widget) {
    Navigator.of(context).pushNamed('/preview', arguments: widget);
  }

  void _navigateToSettings() {
    Navigator.of(context).pushNamed('/settings');
  }

  void _showDeleteDialog(WidgetModel widget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Widget'),
        content: Text('Are you sure you want to delete "${widget.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WidgetProvider>().deleteWidget(widget.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        leading: Container(),
        leadingWidth: 0,
        title: Row(
          children: [
            Text('Wasabi', style: AppTypography.title2),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Consumer<WidgetProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.pureBlack,
              ),
            );
          }

          if (!provider.hasWidgets) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.widgets_outlined,
                      size: 120,
                      color: AppColors.gray300,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'No Widgets Yet',
                      style: AppTypography.title2.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Tap the + button to create your first widget',
                      style: AppTypography.body.copyWith(
                        color: AppColors.gray600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.base),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.base,
              mainAxisSpacing: AppSpacing.base,
              childAspectRatio: 1.0,
            ),
            itemCount: provider.widgets.length,
            itemBuilder: (context, index) {
              final widget = provider.widgets[index];
              return _WidgetCard(
                widget: widget,
                delay: index * 50,
                onTap: () => _navigateToPreview(widget),
                onLongPress: () => _showDeleteDialog(widget),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToGenerator,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _WidgetCard extends StatefulWidget {
  final WidgetModel widget;
  final int delay;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _WidgetCard({
    required this.widget,
    required this.delay,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_WidgetCard> createState() => _WidgetCardState();
}

class _WidgetCardState extends State<_WidgetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value * (_isPressed ? 0.98 : 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: Card(
          elevation: _isPressed ? AppElevation.level1 : AppElevation.level2,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: Text(
                        widget.widget.size.displayName,
                        style: AppTypography.finePrint.copyWith(
                          color: AppColors.gray800,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.widgets,
                      size: 20,
                      color: AppColors.gray400,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  widget.widget.name,
                  style: AppTypography.headline.copyWith(fontSize: 18),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.widget.theme,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
