import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wasabi/providers/api_key_provider.dart';
import 'package:wasabi/providers/generation_provider.dart';
import 'package:wasabi/theme/colors.dart';
import 'package:wasabi/theme/typography.dart';
import 'package:wasabi/theme/spacing.dart';

class ApiSetupScreen extends StatefulWidget {
  const ApiSetupScreen({super.key});

  @override
  State<ApiSetupScreen> createState() => _ApiSetupScreenState();
}

class _ApiSetupScreenState extends State<ApiSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  bool _isObscured = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    if (!_formKey.currentState!.validate()) return;

    final apiKeyProvider = context.read<ApiKeyProvider>();
    final generationProvider = context.read<GenerationProvider>();

    final success = await apiKeyProvider.saveApiKey(_apiKeyController.text.trim());

    if (success && mounted) {
      generationProvider.initializeGemini(_apiKeyController.text.trim());
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apiKeyProvider.error ?? 'Failed to save API key'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Icon(
                  Icons.key,
                  size: 80,
                  color: AppColors.gray900,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'API Setup',
                  style: AppTypography.title1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Enter your Google Gemini API key to get started',
                  style: AppTypography.body.copyWith(
                    color: AppColors.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),
                TextFormField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    hintText: 'Enter your Gemini API key',
                    prefixIcon: const Icon(Icons.vpn_key),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    ),
                  ),
                  obscureText: _isObscured,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an API key';
                    }
                    if (value.trim().length < 20) {
                      return 'API key seems too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.base),
                TextButton(
                  onPressed: () {},
                  child: const Text('Get API Key from Google AI Studio'),
                ),
                const Spacer(),
                Consumer<ApiKeyProvider>(
                  builder: (context, provider, child) {
                    return ElevatedButton(
                      onPressed: provider.isLoading ? null : _saveApiKey,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.pureWhite,
                              ),
                            )
                          : const Text('Continue'),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
