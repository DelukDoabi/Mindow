/// Vetted, localized crisis support resources (Resolved Decision #6, NFR-8).
///
/// Shipped as a client-side constant for MVP so the crisis-gate never depends
/// on network availability to show help. The descriptive labels live in the
/// l10n bundle (keyed by [CrisisResourceId]); only the dial targets are fixed
/// here. The exact numbers/wording remain subject to a final product/legal pass
/// before public release, and moving this list to a deployable backend config
/// is deferred post-MVP.
library;

/// Stable identifier for a crisis resource, mapped to its localized label.
enum CrisisResourceId {
  /// FR — Numéro national de prévention du suicide (24/7, gratuit).
  frSuicidePrevention,

  /// FR — SAMU (urgence médicale).
  frSamu,

  /// EN — 988 Suicide & Crisis Lifeline (US, 24/7).
  enLifeline,

  /// EN — Samaritans (UK/IE, 24/7, free).
  enSamaritans,
}

/// A single tappable support resource.
class CrisisResource {
  /// Creates a crisis resource.
  const CrisisResource({
    required this.id,
    required this.phoneNumber,
    required this.dialDisplay,
  });

  /// Identifies the localized label for this resource.
  final CrisisResourceId id;

  /// The `tel:` dial target (digits only, no spaces).
  final String phoneNumber;

  /// The human-friendly rendering of the number (may contain spaces).
  final String dialDisplay;
}

/// The vetted resources per locale (Resolved Decision #6).
const Map<String, List<CrisisResource>> crisisResourcesByLocale =
    <String, List<CrisisResource>>{
      'fr': <CrisisResource>[
        CrisisResource(
          id: CrisisResourceId.frSuicidePrevention,
          phoneNumber: '3114',
          dialDisplay: '3114',
        ),
        CrisisResource(
          id: CrisisResourceId.frSamu,
          phoneNumber: '15',
          dialDisplay: '15',
        ),
      ],
      'en': <CrisisResource>[
        CrisisResource(
          id: CrisisResourceId.enLifeline,
          phoneNumber: '988',
          dialDisplay: '988',
        ),
        CrisisResource(
          id: CrisisResourceId.enSamaritans,
          phoneNumber: '116123',
          dialDisplay: '116 123',
        ),
      ],
    };

/// Returns the vetted resources for [languageCode], falling back to English.
List<CrisisResource> crisisResourcesForLocale(String languageCode) =>
    crisisResourcesByLocale[languageCode] ?? crisisResourcesByLocale['en']!;
