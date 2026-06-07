import 'package:flutter/material.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/design_system/widgets/aurore_canvas.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/brain_dump/domain/crisis_resources.dart';
import 'package:url_launcher/url_launcher.dart';

/// Presents the calm crisis-support view as a modal sheet (AC2, NFR-8).
///
/// Shown when the crisis-gate trips. Carries NO weight, category, or
/// gamification — only a compassionate line and tappable vetted resources for
/// the current [languageCode]. Returns once the user dismisses it.
Future<void> showCrisisSupport(
  BuildContext context, {
  required String languageCode,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => CrisisSupportView(languageCode: languageCode),
);

/// The compassionate support view shown when distress is detected.
class CrisisSupportView extends StatelessWidget {
  /// Creates the view for the resources of [languageCode].
  const CrisisSupportView({required this.languageCode, super.key});

  /// The locale whose vetted resources are shown.
  final String languageCode;

  Future<void> _dial(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(uri);
  }

  String _labelFor(CrisisResourceId id, AppLocalizations l10n) => switch (id) {
    CrisisResourceId.frSuicidePrevention => l10n.crisisResourceFrSuicide,
    CrisisResourceId.frSamu => l10n.crisisResourceFrSamu,
    CrisisResourceId.enLifeline => l10n.crisisResourceEnLifeline,
    CrisisResourceId.enSamaritans => l10n.crisisResourceEnSamaritans,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final resources = crisisResourcesForLocale(languageCode);

    return AuroreCanvas(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AuroreSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AuroreSpacing.md),
              Text(l10n.crisisTitle, style: textTheme.headlineSmall),
              const SizedBox(height: AuroreSpacing.md),
              Text(
                l10n.crisisBody,
                style: textTheme.bodyLarge?.copyWith(
                  color: AuroreColors.inkMuted,
                ),
              ),
              const SizedBox(height: AuroreSpacing.xl),
              for (final resource in resources) ...[
                _CrisisResourceTile(
                  label: _labelFor(resource.id, l10n),
                  dialDisplay: resource.dialDisplay,
                  onTap: () => _dial(resource.phoneNumber),
                ),
                const SizedBox(height: AuroreSpacing.sm),
              ],
              const SizedBox(height: AuroreSpacing.md),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.crisisDismiss),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CrisisResourceTile extends StatelessWidget {
  const _CrisisResourceTile({
    required this.label,
    required this.dialDisplay,
    required this.onTap,
  });

  final String label;
  final String dialDisplay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AuroreColors.glass,
        borderRadius: BorderRadius.circular(AuroreRadii.md),
      ),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.favorite_outline, color: AuroreColors.ink),
        title: Text(label, style: textTheme.bodyLarge),
        trailing: Text(
          dialDisplay,
          style: textTheme.titleMedium?.copyWith(color: AuroreColors.ink),
        ),
      ),
    );
  }
}
