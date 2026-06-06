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

/// The terminal onboarding step: create an account via Apple, Google, or
/// Email so the user's data can be saved and synced (FR-2).
///
/// Account creation stays optional — a "Passer" link leaves to the home
/// placeholder. On success the onboarding-complete flag is persisted locally
/// so a returning user skips onboarding (the redirect itself is Story 1.5).
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _busy = false;
  bool _showEmailForm = false;
  bool _hasError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _runAuth(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _hasError = false;
    });
    try {
      await action();
      await ref.read(onboardingRepositoryProvider).markComplete();
      if (!mounted) return;
      context.go(Routes.home);
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
    final auth = ref.read(authRepositoryProvider);

    return AuroreCanvas(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuroreSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _busy ? null : () => context.go(Routes.home),
                  style: TextButton.styleFrom(
                    foregroundColor: AuroreColors.inkMuted,
                  ),
                  child: Text(l10n.onboardingSkip),
                ),
              ),
              const Spacer(),
              Text(
                l10n.accountTitle,
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AuroreSpacing.sm),
              Text(
                l10n.accountSubtitle,
                style: textTheme.bodyLarge?.copyWith(
                  color: AuroreColors.inkMuted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AuroreSpacing.xl),
              if (_hasError) ...[
                Text(
                  l10n.accountAuthError,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AuroreColors.danger,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AuroreSpacing.md),
              ],
              FilledButton(
                onPressed: _busy ? null : () => _runAuth(auth.signInWithApple),
                child: Text(l10n.accountContinueWithApple),
              ),
              const SizedBox(height: AuroreSpacing.md),
              FilledButton(
                onPressed: _busy ? null : () => _runAuth(auth.signInWithGoogle),
                child: Text(l10n.accountContinueWithGoogle),
              ),
              const SizedBox(height: AuroreSpacing.md),
              FilledButton(
                onPressed: _busy
                    ? null
                    : () => setState(() => _showEmailForm = !_showEmailForm),
                child: Text(l10n.accountContinueWithEmail),
              ),
              if (_showEmailForm) ...[
                const SizedBox(height: AuroreSpacing.lg),
                TextField(
                  controller: _emailController,
                  enabled: !_busy,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: l10n.accountEmailLabel,
                    hintText: l10n.accountEmailHint,
                  ),
                ),
                const SizedBox(height: AuroreSpacing.md),
                TextField(
                  controller: _passwordController,
                  enabled: !_busy,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: l10n.accountPasswordLabel,
                  ),
                ),
                const SizedBox(height: AuroreSpacing.md),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _runAuth(
                          () => auth.signInWithEmail(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          ),
                        ),
                  child: Text(l10n.onboardingContinue),
                ),
              ],
              const Spacer(),
              if (_busy)
                const Center(child: CircularProgressIndicator())
              else
                const SizedBox(height: AuroreSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
