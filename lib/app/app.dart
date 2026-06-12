import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/app/env.dart';
import 'package:mindow/core/design_system/aurore_theme.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/core/router/app_router.dart';
import 'package:mindow/features/notifications/notification_handler.dart';

/// Root widget. Wires the Aurore theme, GoRouter, generated localizations,
/// and the FCM incoming-message handler (Story 5.2).
class MindowApp extends ConsumerStatefulWidget {
  const MindowApp({super.key});

  @override
  ConsumerState<MindowApp> createState() => _MindowAppState();
}

class _MindowAppState extends ConsumerState<MindowApp> {
  @override
  void initState() {
    super.initState();
    // Register FCM listeners after the first frame so the scaffoldMessengerKey
    // is connected to the widget tree and GoRouter's initial navigation has
    // been processed. Fire-and-forget: failures are non-critical.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final router = ref.read(appRouterProvider);
      NotificationHandler.init(router).ignore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final flavor = ref.watch(envProvider).flavor;

    return MaterialApp.router(
      title: flavor.label,
      debugShowCheckedModeBanner: !flavor.isProduction,
      theme: AuroreTheme.light(),
      routerConfig: router,
      scaffoldMessengerKey: NotificationHandler.scaffoldMessengerKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
