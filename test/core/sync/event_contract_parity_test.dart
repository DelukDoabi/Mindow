import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/sync/domain_event.dart';

/// Path to the TypeScript envelope contract shared by the backend functions.
const String _contractPath = 'supabase/functions/_shared/events.ts';

void main() {
  group('event envelope contract parity', () {
    test('TypeScript EVENT_ENVELOPE_KEYS matches Dart eventEnvelopeKeys', () {
      final source = File(_contractPath).readAsStringSync();

      final block = RegExp(
        r'EVENT_ENVELOPE_KEYS\s*=\s*\[(.*?)\]',
        dotAll: true,
      ).firstMatch(source);
      expect(
        block,
        isNotNull,
        reason: 'EVENT_ENVELOPE_KEYS not found in $_contractPath',
      );

      final tsKeys = RegExp(
        '"([^"]+)"',
      ).allMatches(block!.group(1)!).map((m) => m.group(1)!).toList();

      // Order matters: both sides declare the canonical wire order.
      expect(tsKeys, eventEnvelopeKeys);
    });
  });
}
