import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/design_system/widgets/aurore_canvas.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/core/router/app_router.dart';
import 'package:mindow/features/auth/auth_repository.dart';
import 'package:mindow/features/onboarding/onboarding_repository.dart';

/// Settings surface holding the GDPR data rights (Story 1.7, NFR-10).
///
/// Exposes "export my data" (invokes the `account-export` Edge Function) and
/// "delete my account" (confirmation dialog → `account-delete` Edge Function →
/// sign-out → back to welcome). Both degrade gracefully with no backend.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;
  bool _hasError = false;
  bool _aiConsent = false;
  bool _aiConsentLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadAiConsent());
  }

  Future<void> _loadAiConsent() async {
    final granted = await ref
        .read(onboardingRepositoryProvider)
        .isAiConsentGranted();
    if (mounted) {
      setState(() {
        _aiConsent = granted;
        _aiConsentLoading = false;
      });
    }
  }

  Future<void> _toggleAiConsent(bool value) async {
    setState(() => _aiConsent = value);
    await ref.read(onboardingRepositoryProvider).setAiConsent(granted: value);
  }

  Future<void> _runExport() async {
    setState(() {
      _busy = true;
      _hasError = false;
    });
    try {
      await ref.read(authRepositoryProvider).exportData();
      if (!mounted) return;
      setState(() => _busy = false);
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsExportRequested)),
      );
    } on Object {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _hasError = true;
      });
    }
  }

  Future<void> _runDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsDeleteConfirmTitle),
        content: Text(l10n.settingsDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.settingsCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AuroreColors.danger,
            ),
            child: Text(l10n.settingsDeleteConfirmCta),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _busy = true;
      _hasError = false;
    });
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      if (!mounted) return;
      context.go(Routes.welcome);
    } on Object {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AuroreCanvas(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuroreSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _busy ? null : () => context.go(Routes.home),
                  color: AuroreColors.inkMuted,
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              const SizedBox(height: AuroreSpacing.md),
              Text(l10n.settingsTitle, style: textTheme.headlineMedium),
              const SizedBox(height: AuroreSpacing.xl),
              Text(
                l10n.settingsAiSection,
                style: textTheme.titleMedium?.copyWith(
                  color: AuroreColors.inkMuted,
                ),
              ),
              const SizedBox(height: AuroreSpacing.sm),
              if (_aiConsentLoading)
                const Center(child: CircularProgressIndicator())
              else
                SwitchListTile(
                  value: _aiConsent,
                  onChanged: _busy ? null : _toggleAiConsent,
                  title: Text(l10n.settingsAiConsentToggle),
                  subtitle: Text(
                    l10n.settingsAiConsentSubtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AuroreColors.inkMuted,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              const SizedBox(height: AuroreSpacing.lg),
              Text(
                l10n.settingsPrivacySection,
                style: textTheme.titleMedium?.copyWith(
                  color: AuroreColors.inkMuted,
                ),
              ),
              const SizedBox(height: AuroreSpacing.md),
              FilledButton(
                onPressed: _busy ? null : _runExport,
                child: Text(l10n.settingsExportData),
              ),
              const SizedBox(height: AuroreSpacing.md),
              TextButton(
                onPressed: _busy ? null : _runDelete,
                style: TextButton.styleFrom(
                  foregroundColor: AuroreColors.danger,
                ),
                child: Text(l10n.settingsDeleteAccount),
              ),
              if (_hasError) ...[
                const SizedBox(height: AuroreSpacing.md),
                Text(
                  l10n.settingsActionError,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AuroreColors.danger,
                  ),
                ),
              ],
              const Spacer(),
              if (_busy) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
