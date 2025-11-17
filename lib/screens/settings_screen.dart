import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wasabi/providers/api_key_provider.dart';
import 'package:wasabi/providers/widget_provider.dart';
import 'package:wasabi/providers/generation_provider.dart';
import 'package:wasabi/theme/colors.dart';
import 'package:wasabi/theme/typography.dart';
import 'package:wasabi/theme/spacing.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showApiKeyDialog(BuildContext context) {
    final controller = TextEditingController();
    final apiKeyProvider = context.read<ApiKeyProvider>();
    final generationProvider = context.read<GenerationProvider>();

    controller.text = apiKeyProvider.apiKey ?? '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update API Key'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'API Key',
            hintText: 'Enter your Gemini API key',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await apiKeyProvider.saveApiKey(controller.text.trim());
                generationProvider.initializeGemini(controller.text.trim());
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteApiKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete API Key'),
        content: const Text(
          'Are you sure you want to delete your API key? You will need to enter it again to use the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final apiKeyProvider = context.read<ApiKeyProvider>();
              await apiKeyProvider.deleteApiKey();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                Navigator.of(context).pushReplacementNamed('/api-setup');
              }
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

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all widgets? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final widgetProvider = context.read<WidgetProvider>();
              await widgetProvider.clearAllWidgets();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All widgets deleted'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete All'),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.base),
          _SettingsSection(
            title: 'API Configuration',
            children: [
              _SettingsTile(
                icon: Icons.vpn_key,
                title: 'Update API Key',
                subtitle: 'Change your Gemini API key',
                onTap: () => _showApiKeyDialog(context),
              ),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: 'Delete API Key',
                subtitle: 'Remove saved API key',
                textColor: AppColors.error,
                onTap: () => _showDeleteApiKeyDialog(context),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Data',
            children: [
              Consumer<WidgetProvider>(
                builder: (context, provider, child) {
                  return _SettingsTile(
                    icon: Icons.widgets,
                    title: 'Widgets',
                    subtitle: '${provider.widgets.length} widgets saved',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.delete_sweep,
                title: 'Clear All Data',
                subtitle: 'Delete all saved widgets',
                textColor: AppColors.error,
                onTap: () => _showClearDataDialog(context),
              ),
            ],
          ),
          _SettingsSection(
            title: 'About',
            children: [
              const _SettingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: '1.0.0',
              ),
              const _SettingsTile(
                icon: Icons.copyright,
                title: 'WASABI',
                subtitle: 'Widget Builder with Gemini AI',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: AppSpacing.base),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? textColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.textColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppColors.gray900,
      ),
      title: Text(
        title,
        style: AppTypography.body.copyWith(
          color: textColor ?? AppColors.gray900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.caption,
      ),
      trailing: trailing,
      onTap: onTap,
      enabled: onTap != null,
    );
  }
}
