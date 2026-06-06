import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:mindow/app/app.dart';
import 'package:mindow/app/env.dart';
import 'package:mindow/features/onboarding/onboarding_repository.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Single shared composition root for every flavor.
///
/// Each `lib/main_<flavor>.dart` entrypoint calls this with its [Flavor]. The
/// order here matters: local persistence first (offline-first source of
/// truth), then backend + observability, then the widget tree. Backend and
/// observability init are skipped when their public keys are absent so the
/// scaffold boots cleanly without a configured environment.
Future<void> bootstrap(Flavor flavor) async {
  final env = Env.of(flavor);

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Local-first persistence is always available.
      await Hive.initFlutter();

      // Read persisted routing state before the first frame so the router's
      // redirect resolves synchronously (no welcome flash / blocking spinner).
      final onboardingComplete = await OnboardingRepository().isComplete();

      if (env.hasSupabase) {
        await Supabase.initialize(
          url: env.supabaseUrl,
          // The `publishableKey` replacement is not yet available in the
          // pinned supabase_flutter version; `anonKey` is the public key.
          // ignore: deprecated_member_use
          anonKey: env.supabaseAnonKey,
        );
      }

      if (env.hasPostHog) {
        final config = PostHogConfig(env.posthogApiKey)
          ..host = env.posthogHost
          ..captureApplicationLifecycleEvents = true;
        await Posthog().setup(config);
      }

      final app = ProviderScope(
        overrides: [
          envProvider.overrideWithValue(env),
          onboardingCompleteProvider.overrideWithValue(onboardingComplete),
        ],
        child: const MindowApp(),
      );

      if (env.hasSentry) {
        await SentryFlutter.init(
          (options) {
            options
              ..dsn = env.sentryDsn
              ..environment = flavor.name
              ..tracesSampleRate = flavor.isProduction ? 0.2 : 1.0;
          },
          appRunner: () => runApp(app),
        );
      } else {
        runApp(app);
      }
    },
    (error, stack) {
      if (env.hasSentry) {
        unawaited(Sentry.captureException(error, stackTrace: stack));
      } else {
        debugPrint('Uncaught zone error: $error\n$stack');
      }
    },
  );
}
