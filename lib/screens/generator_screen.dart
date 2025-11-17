import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wasabi/providers/generation_provider.dart';
import 'package:wasabi/models/widget_size.dart';
import 'package:wasabi/theme/colors.dart';
import 'package:wasabi/theme/typography.dart';
import 'package:wasabi/theme/spacing.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final _promptController = TextEditingController();
  WidgetSize _selectedSize = WidgetSize.medium;
  String _selectedTheme = 'minimal';
  bool _showAdvanced = false;

  final List<Map<String, dynamic>> _templates = [
    {'icon': Icons.wb_sunny, 'label': 'Weather', 'prompt': 'Show current weather with temperature and condition'},
    {'icon': Icons.fitness_center, 'label': 'Fitness', 'prompt': 'Display step count and daily progress'},
    {'icon': Icons.calendar_today, 'label': 'Calendar', 'prompt': 'Show today\'s date and upcoming events'},
    {'icon': Icons.access_time, 'label': 'Clock', 'prompt': 'Display current time in large format'},
    {'icon': Icons.battery_charging_full, 'label': 'Battery', 'prompt': 'Show battery level with progress bar'},
  ];

  final List<String> _themes = [
    'minimal',
    'gradient',
    'glass',
    'material',
    'neon',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateWidget() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a widget description'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final generationProvider = context.read<GenerationProvider>();

    await generationProvider.generateWidget(
      prompt: _promptController.text.trim(),
      size: _selectedSize,
      theme: _selectedTheme,
    );

    if (mounted && generationProvider.state == GenerationState.success) {
      Navigator.of(context).pushNamed('/preview');
    } else if (mounted && generationProvider.state == GenerationState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(generationProvider.error ?? 'Failed to generate widget'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _useTemplate(String prompt) {
    _promptController.text = prompt;
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
        title: const Text('Create Widget'),
      ),
      body: Consumer<GenerationProvider>(
        builder: (context, provider, child) {
          if (provider.isGenerating) {
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
                    'Generating Widget...',
                    style: AppTypography.headline,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'This may take a few seconds',
                    style: AppTypography.body.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _promptController,
                  maxLines: 5,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Describe your widget...\n\nExample: "Show the current time with a sunset gradient background and animated numbers"',
                    border: OutlineInputBorder(),
                  ),
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Quick Templates',
                  style: AppTypography.headline.copyWith(fontSize: 16),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _templates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final template = _templates[index];
                      return _TemplateChip(
                        icon: template['icon'],
                        label: template['label'],
                        onTap: () => _useTemplate(template['prompt']),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                InkWell(
                  onTap: () {
                    setState(() {
                      _showAdvanced = !_showAdvanced;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        _showAdvanced ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.gray800,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Advanced Options',
                        style: AppTypography.headline.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _showAdvanced
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.base),
                            Text('Size', style: AppTypography.body),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: WidgetSize.values.map((size) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                                    child: ChoiceChip(
                                      label: Center(child: Text(size.displayName)),
                                      selected: _selectedSize == size,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() => _selectedSize = size);
                                        }
                                      },
                                      selectedColor: AppColors.pureBlack,
                                      labelStyle: TextStyle(
                                        color: _selectedSize == size
                                            ? AppColors.pureWhite
                                            : AppColors.gray800,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: AppSpacing.base),
                            Text('Theme', style: AppTypography.body),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: _themes.map((theme) {
                                return ChoiceChip(
                                  label: Text(theme[0].toUpperCase() + theme.substring(1)),
                                  selected: _selectedTheme == theme,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _selectedTheme = theme);
                                    }
                                  },
                                  selectedColor: AppColors.pureBlack,
                                  labelStyle: TextStyle(
                                    color: _selectedTheme == theme
                                        ? AppColors.pureWhite
                                        : AppColors.gray800,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                ElevatedButton(
                  onPressed: _generateWidget,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: const Text('Generate Widget'),
                ),
                const SizedBox(height: AppSpacing.base),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TemplateChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.gray300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.gray900),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.finePrint.copyWith(
                color: AppColors.gray800,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
