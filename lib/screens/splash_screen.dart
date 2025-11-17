import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wasabi/providers/api_key_provider.dart';
import 'package:wasabi/providers/generation_provider.dart';
import 'package:wasabi/providers/widget_provider.dart';
import 'package:wasabi/theme/colors.dart';
import 'package:wasabi/theme/typography.dart';
import 'package:wasabi/theme/spacing.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    _checkApiKey();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkApiKey() async {
    final apiKeyProvider = context.read<ApiKeyProvider>();
    final generationProvider = context.read<GenerationProvider>();
    final widgetProvider = context.read<WidgetProvider>();

    await apiKeyProvider.loadApiKey();

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    if (apiKeyProvider.hasApiKey) {
      generationProvider.initializeGemini(apiKeyProvider.apiKey!);
      await widgetProvider.loadWidgets();
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/api-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.pureBlack,
                        borderRadius: BorderRadius.circular(AppRadius.xLarge),
                      ),
                      child: const Icon(
                        Icons.widgets,
                        size: 64,
                        color: AppColors.pureWhite,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'WASABI',
                      style: AppTypography.display.copyWith(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Widget Builder',
                      style: AppTypography.body.copyWith(
                        color: AppColors.gray600,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
