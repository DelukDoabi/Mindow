---
baseline_commit: 3564048
---

# Story 2.4: Edit and delete a Preoccupation

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user,
I want to edit or delete a worry,
So that my backpack reflects reality.

## Acceptance Criteria

1. **Given** an existing Preoccupation in the list, **When** I tap it, **Then** an item-detail view opens, showing the current content and offering Edit and Delete actions (FR-5; UX: "Item detail | Backpack item tap | Read / edit / release one mental item").
2. **Given** the item-detail view is open, **When** I edit the content and save, **Then** a `preoccupation.updated` event is emitted with the trimmed new content and the item's text updates in the list — and if the edit is non-trivial (trimmed content differs from the original), AI Analysis re-runs asynchronously so the Mental Weight reflects the edited worry (FR-5, NFR-11 cost guardrail: debounce trivial edits = skip re-analysis when trimmed content is unchanged).
3. **Given** the item-detail view is open, **When** I choose Delete and confirm, **Then** a `preoccupation.deleted` event is emitted, the Preoccupation disappears from the open list, and its Mental Weight is no longer included in the load (FR-5, architecture: `preoccupation.deleted` is an explicitly named event).
4. **And** all operations work offline-first: the events are appended to the Hive outbox immediately and the UI updates from the projection; no network call is required for edit or delete to take effect locally (NFR-3).
5. **And** copy passes the tone-as-gate — no guilt, urgency, or failure language; delete confirmation is warm and non-pressuring; all new copy is French-source-of-truth localized (NFR-5, UX-DR16).

## Tasks / Subtasks

- [ ] **Task 1 — `preoccupation.deleted` domain event + decoder + registration** (AC: #3, #4)
  - [ ] Create `lib/features/brain_dump/domain/preoccupation_deleted_event.dart`: extend `DomainEvent` with `static const String type = 'preoccupation.deleted'`, `eventType => type`, `schemaVersion = 1`, empty `toJson()` (`<String, dynamic>{}`). The `aggregateId` IS the Preoccupation id. No payload fields — this is a pure tombstone event.
  - [ ] Add a top-level `DomainEvent decodePreoccupationDeleted(EventEnvelope envelope)` function mirroring the `decodePreoccupationCaptured` decoder pattern (no `fromJson` factory — match the existing convention from `preoccupation_captured_event.dart` and `weight_assigned_event.dart`).
  - [ ] Register it: in `lib/features/brain_dump/brain_dump_providers.dart`, chain `..register(PreoccupationDeletedEvent.type, decodePreoccupationDeleted)` on `domainEventRegistry`.
  - [ ] No new Hive typeId — the event serializes into the existing `OutboxRecord` (typeId 11), like all other events.

- [ ] **Task 2 — `preoccupation.updated` domain event + decoder + registration** (AC: #2, #4)
  - [ ] Create `lib/features/brain_dump/domain/preoccupation_updated_event.dart`: extend `DomainEvent` with `static const String type = 'preoccupation.updated'`, `eventType => type`, `schemaVersion = 1`. Payload field: `final String content` (the trimmed new text). `toJson()` returns `<String, dynamic>{'content': content}`. The `aggregateId` IS the Preoccupation id.
  - [ ] Add a top-level `DomainEvent decodePreoccupationUpdated(EventEnvelope envelope)` decoder function.
  - [ ] Register it in `domainEventRegistry` alongside the other decoders.

- [ ] **Task 3 — Extend the projection reducer and `BrainDumpRepository`** (AC: #2, #3, #4)
  - [ ] In `lib/features/brain_dump/brain_dump_repository.dart`, extend `_reducePreoccupations` with two new branches:
    - `PreoccupationDeletedEvent`: remove `event.aggregateId` from the map (`state` without that key). If the key is absent, return `state` unchanged (defensive).
    - `PreoccupationUpdatedEvent`: find the existing aggregate; if absent, return `state` unchanged (orphan guard, same pattern as `WeightAssignedEvent`). Otherwise `copyWith(content: event.content)`. The Mental Weight and category fields are intentionally NOT cleared — they stay until re-analysis (if triggered) emits a fresh `weight.assigned` that latest-wins (Resolved Decision #4 from Story 2.3).
  - [ ] Add `Future<void> deletePreoccupation(String id)` to `BrainDumpRepository`: generates a new UUID v4 `eventId`, emits `PreoccupationDeletedEvent(eventId: ..., aggregateId: id, occurredAt: _clock())` via `_syncQueue.enqueue(...)`.
  - [ ] Add `Future<void> updatePreoccupation(String id, String newContent)` to `BrainDumpRepository`: trims `newContent`; rejects empty/whitespace-only silently (no event). Otherwise emits `PreoccupationUpdatedEvent(eventId: _uuid.v4(), aggregateId: id, occurredAt: _clock(), content: trimmed)` via `_syncQueue.enqueue(...)`.
  - [ ] Add the new event imports to `brain_dump_repository.dart`.

- [ ] **Task 4 — Re-analysis on non-trivial edit** (AC: #2, NFR-11)
  - [ ] In `lib/features/brain_dump/brain_dump_providers.dart`, expose a helper that the UI can call after an edit to trigger re-analysis when the edit is non-trivial. Wire it via `analysisServiceProvider`: after `updatePreoccupation` succeeds, the call site checks if `newContent.trim() != originalContent.trim()` and calls `ref.read(analysisServiceProvider).analyzePreoccupation(id: id, content: newContent.trim())` (unawaited, fire-and-forget — same pattern as capture).
  - [ ] `AnalysisService.analyzePreoccupation` already handles the in-flight guard — no changes needed to `AnalysisService`. The existing method already calls `_onProjectionChanged()` on success/fallback, which bumps `ProjectionRevision` and refreshes the list.
  - [ ] Trivial-edit definition (MVP, confirmed): `newContent.trim() == originalContent.trim()` → trivial → skip re-analysis. No fuzzy distance needed for MVP (simple, deterministic, no dependencies).
  - [ ] `ProjectionRevision.bump()` must also be called after `deletePreoccupation` and `updatePreoccupation` so the list refreshes. Call `ref.read(projectionRevisionProvider.notifier).bump()` from the UI after these operations (same pattern as post-capture `ref.invalidate(openPreoccupationsProvider)` in `_submit()`).

- [ ] **Task 5 — Item-detail UI: modal bottom sheet with edit + delete** (AC: #1, #2, #3, #5)
  - [ ] Create `lib/features/brain_dump/presentation/edit_preoccupation_sheet.dart`: a `ConsumerStatefulWidget` that accepts `Preoccupation item` as a constructor parameter. It presents:
    - A pre-filled `TextField` (using a `TextEditingController` initialized with `item.content`) for editing.
    - A **Save** `FilledButton` (disabled while trimmed text is empty or unchanged from `item.content`).
    - A **Supprimer** text-link button (secondary action, `ink-muted` colour per design system — `TextButton`, NOT a competing `FilledButton`).
    - No close button — the sheet dismisses on drag-down or tap-outside (standard modal behaviour).
  - [ ] **Save flow** (inside the sheet widget):
    1. Call `await ref.read(brainDumpRepositoryProvider).updatePreoccupation(item.id, trimmedNewContent)`.
    2. Bump revision: `ref.read(projectionRevisionProvider.notifier).bump()`.
    3. If `trimmedNewContent != item.content.trim()` → fire-and-forget `ref.read(analysisServiceProvider).analyzePreoccupation(id: item.id, content: trimmedNewContent)` (unawaited).
    4. Pop the sheet (`Navigator.of(context).pop()`).
    5. Show a brief, warm `SnackBar` (e.g. `l10n.editSuccess`) — do NOT show on pop if already unmounted.
  - [ ] **Delete flow** (inside the sheet widget):
    1. Show a confirmation `AlertDialog` (warm, non-pressuring copy — see Task 6 for keys).
    2. On confirm: `await ref.read(brainDumpRepositoryProvider).deletePreoccupation(item.id)`.
    3. Bump revision: `ref.read(projectionRevisionProvider.notifier).bump()`.
    4. Pop the sheet (close both the dialog and the sheet).
    5. Optionally show a brief `SnackBar` (e.g. `l10n.deleteSuccess`).
  - [ ] In `home_screen.dart` `_PreoccupationList._itemBuilder`, wrap each item card in a `GestureDetector` (or `InkWell`) that calls `showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => EditPreoccupationSheet(item: item))`. Pass a `ProviderScope.containerOf` so the sheet retains the Riverpod container (or use `ProviderScope`-aware `showModalBottomSheet` — since `showModalBottomSheet` inherits the widget tree's scope, no special handling needed). The `_PreoccupationList` widget is a `StatelessWidget` — to call `ref.read(...)` in the sheet actions, the sheet must be a `ConsumerStatefulWidget` (it is, by design).
  - [ ] Maintain the existing Aurore design tokens: `AuroreColors.glass` card decoration, `AuroreSpacing.*`, `AuroreRadii.*`, `textTheme.*` — no new colours or sizes.

- [ ] **Task 6 — Localization** (AC: #5, NFR-5)
  - [ ] Add ARB keys to `assets/l10n/app_fr.arb` (French = source of truth, then mirror to `assets/l10n/app_en.arb`):
    - `"editSheetSaveButton": "Enregistrer"` — save CTA in the sheet.
    - `"editSheetDeleteButton": "Supprimer"` — delete link in the sheet.
    - `"editSuccess": "C'est mis à jour."` — SnackBar after a successful edit.
    - `"deleteConfirmTitle": "Déposer cette pensée ?"` — warm delete dialog title.
    - `"deleteConfirmBody": "Elle disparaîtra de ton sac à dos. Rien ne se perd vraiment."` — warm, non-shaming body.
    - `"deleteConfirmCta": "Oui, libère-la"` — confirm delete CTA (use `ink-muted` secondary button, not gradient).
    - `"deleteSuccess": "Allégé d'un souci."` — SnackBar after delete.
    - `"editSheetTitle": "Ta préoccupation"` — bottom sheet handle/title (optional but aids accessibility).
  - [ ] Run `flutter gen-l10n` to regenerate `lib/core/l10n/*`.
  - [ ] Add `@key` description entries for each new key (accessibility / translator context).

- [ ] **Task 7 — Tests** (AC: all)
  - [ ] `test/features/brain_dump/domain/preoccupation_deleted_event_test.dart`: `eventType == 'preoccupation.deleted'`; `toJson()` returns empty map; decode via `decodePreoccupationDeleted`; decode via `DomainEventRegistry` registered decoder.
  - [ ] `test/features/brain_dump/domain/preoccupation_updated_event_test.dart`: `eventType == 'preoccupation.updated'`; `toJson()` contains `'content'` key; decode round-trip.
  - [ ] `test/features/brain_dump/brain_dump_repository_test.dart` (extend existing test file):
    - `deletePreoccupation`: captured item → deleted → `getOpenPreoccupations()` returns empty; orphan delete (no prior capture) is silently ignored.
    - `deletePreoccupation`: captured + weighted item → deleted → excluded from projection.
    - `updatePreoccupation`: captured item → updated → `getOpenPreoccupations()` shows new content; old weight/category remain on the projection (not cleared).
    - `updatePreoccupation`: reject empty/whitespace-only new content (no event emitted).
    - `updatePreoccupation`: orphan update (no prior capture) is silently ignored.
    - Replay order: capture → update → delete → item absent; capture → delete → update is also absent (delete tombstone wins regardless of subsequent update, because the delete removes the key and the update then finds no entry to fold onto).
  - [ ] (Optional, if time allows) Widget test `test/features/brain_dump/presentation/edit_preoccupation_sheet_test.dart`: renders pre-filled content; Save button disabled when content unchanged; tapping Supprimer shows confirmation dialog.
  - [ ] Validate: `dart run build_runner build`, `flutter gen-l10n`, `flutter analyze` (0 issues — no `[ref.xxx]` in doc comments, use backticks instead), `dart format lib test`, `flutter test`.

### Review Findings

- [x] [Review][Defer] `ReplayEngine._compare` falls through to random UUID tiebreaker for same-millisecond local events — two operations on the same clock tick get non-causal ordering [lib/core/sync/replay_engine.dart:_compare] — deferred, theoretical edge case; `createdAt` fix introduced in this story already reduces risk significantly in practice

## Dev Notes

### Architecture Patterns and Constraints

- **`preoccupation.deleted` is an explicitly named event type** in the architecture: `preoccupation.captured`, `weight.assigned`, `mission.validated`, `mission.deferred`, `preoccupation.deleted`. Use this exact type string. [Source: architecture.md#Naming Patterns]
- **`preoccupation.updated` follows the `domain.action` past-tense naming convention** and is not yet listed but fits the established pattern. It is the correct name for an edit event. [Source: architecture.md#Naming Patterns]
- **Event-sourced, append-only, immutable log.** Edit and delete are new events appended to the outbox; no existing events are mutated or removed. The projection rebuild (`_reducePreoccupations`) handles tombstoning (delete removes the map entry; update overwrites the content field). [Source: architecture.md#Architectural Principles (1); architecture.md#Communication Patterns]
- **Hive outbox — no new typeId needed.** Both new events serialize as JSON payload inside the existing `OutboxRecord` (typeId 11). Do NOT touch `lib/core/sync/hive_registry.dart`. [Source: Story 2.1; Story 2.3 Dev Notes]
- **Conflict-resolution matrix: validate vs delete.** If a `preoccupation.deleted` event arrives after a `weight.assigned`, the tombstone wins (no projection entry → effectively deleted). If a `preoccupation.updated` arrives after a delete, the orphan guard ignores it silently (no entry to fold onto). Both are correct by event-log replay order. [Source: architecture.md#Decisions to Nail (3)]
- **`ProjectionRevision.bump()` is the refresh mechanism** established in Story 2.3 fix commit (`3564048`). Use it instead of `ref.invalidate()` after edit/delete — call it from the UI layer via `ref.read(projectionRevisionProvider.notifier).bump()`. [Source: lib/features/brain_dump/brain_dump_providers.dart]
- **Weight NOT cleared on edit (MVP stance).** The existing weight/category stay on the projection until re-analysis returns a fresh `weight.assigned` (latest-wins). "Mental Weight frozen + versioned at capture" means we don't silently recalculate without recording it as a new event. If re-analysis produces a new weight, that `weight.assigned` supersedes — the log is still append-only. [Source: architecture.md#Architectural Principles (1); Story 2.3 Resolved Decision #4]
- **core/sync stays business-agnostic.** New events live under `lib/features/brain_dump/domain/`, never in `lib/core/sync/`. [Source: architecture.md#Project Structure & Boundaries; Story 2.1 CI invariant]
- **`comment_references` lint trap (very_good_analysis).** Doc comments must NOT use `[ref.someMethod]` or `[SomeUndeclaredType]` — use backticks instead (e.g. `` `ref.read()` ``). This was the root cause of CI #32 failure (fix commit `3564048`). [Source: Session learnings]
- **`prefer_initializing_formals` suppression.** Any new class with private fields assigned in the initializer list (like `BrainDumpRepository`, `AnalysisService`) requires `// ignore_for_file: prefer_initializing_formals` at the top. Check if the new sheet widget needs it. [Source: Story 2.3 Debug Log; lib/features/brain_dump/analysis_service.dart]
- **`pumpAndSettle` forbidden in widget tests with indeterminate progress indicators.** Use bounded `pump` calls instead. [Source: Story 2.3 Dev Notes (testing standards)]

### Source Tree Components to Touch

**NEW:**
- `lib/features/brain_dump/domain/preoccupation_deleted_event.dart`
- `lib/features/brain_dump/domain/preoccupation_updated_event.dart`
- `lib/features/brain_dump/presentation/edit_preoccupation_sheet.dart`
- `test/features/brain_dump/domain/preoccupation_deleted_event_test.dart`
- `test/features/brain_dump/domain/preoccupation_updated_event_test.dart`

**MODIFIED:**
- `lib/features/brain_dump/brain_dump_repository.dart` — new reducer branches + `deletePreoccupation` + `updatePreoccupation`
- `lib/features/brain_dump/brain_dump_providers.dart` — register two new decoders
- `lib/features/brain_dump/presentation/home_screen.dart` — tap handler on list items → `showModalBottomSheet`
- `assets/l10n/app_fr.arb`, `assets/l10n/app_en.arb` → regenerated `lib/core/l10n/*`
- `test/features/brain_dump/brain_dump_repository_test.dart` — new groups for delete + update

### Existing Code to Reuse (Verified Signatures)

- **`DomainEvent` base** (extend it, supply `eventType` + `toJson()`): `lib/core/sync/domain_event.dart`
- **Decoder pattern** (top-level function, NOT a `fromJson` factory): `lib/features/brain_dump/domain/preoccupation_captured_event.dart` — `DomainEvent decodePreoccupationCaptured(EventEnvelope e)`
- **`BrainDumpRepository` constructor** (reuse injected `_uuid` and `_clock` for new events, same as `capturePreoccupation`): `lib/features/brain_dump/brain_dump_repository.dart#L60-L77`
- **`SyncQueue.enqueue(DomainEvent)`**: append to outbox, idempotent by `event_id` — `lib/core/sync/sync_queue.dart`
- **`domainEventRegistry` provider** (chain `..register(...)` for both new types): `lib/features/brain_dump/brain_dump_providers.dart#L21-L23`
- **`ProjectionRevision.bump()`**: `ref.read(projectionRevisionProvider.notifier).bump()` — `lib/features/brain_dump/brain_dump_providers.dart#L43`
- **`analysisServiceProvider` / `AnalysisService.analyzePreoccupation(id, content)`**: already handles in-flight guard, consent check, crisis/fallback, and projection bump — just call it: `lib/features/brain_dump/analysis_service.dart`
- **Aurore design tokens**: `AuroreColors`, `AuroreSpacing`, `AuroreRadii` — `lib/core/design_system/`
- **Hive test setup** (tempDir + `Hive.registerAdapters()` + `Hive.init()` + box open/close pattern): `test/features/brain_dump/brain_dump_repository_test.dart#L15-L47`
- **`_reducePreoccupations` function signature and position**: top-level private function in `brain_dump_repository.dart` — add the two new branches BEFORE the final `return state` at the bottom. [Source: lib/features/brain_dump/brain_dump_repository.dart#L23-L59]

### Key Implementation Details

#### `PreoccupationDeletedEvent` (tombstone — no payload)
```dart
class PreoccupationDeletedEvent extends DomainEvent {
  const PreoccupationDeletedEvent({
    required super.eventId,
    required super.aggregateId,
    required super.occurredAt,
    super.schemaVersion,
  });

  static const String type = 'preoccupation.deleted';

  @override
  String get eventType => type;

  @override
  Map<String, dynamic> toJson() => const <String, dynamic>{};
}

DomainEvent decodePreoccupationDeleted(EventEnvelope envelope) =>
    PreoccupationDeletedEvent(
      eventId: envelope.eventId,
      aggregateId: envelope.aggregateId,
      occurredAt: envelope.createdAt,
      schemaVersion: envelope.schemaVersion,
    );
```

#### `PreoccupationUpdatedEvent` (content update)
```dart
class PreoccupationUpdatedEvent extends DomainEvent {
  const PreoccupationUpdatedEvent({
    required super.eventId,
    required super.aggregateId,
    required super.occurredAt,
    required this.content,
    super.schemaVersion,
  });

  static const String type = 'preoccupation.updated';

  final String content;

  @override
  String get eventType => type;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'content': content};
}

DomainEvent decodePreoccupationUpdated(EventEnvelope envelope) =>
    PreoccupationUpdatedEvent(
      eventId: envelope.eventId,
      aggregateId: envelope.aggregateId,
      occurredAt: envelope.createdAt,
      content: envelope.payload['content'] as String,
      schemaVersion: envelope.schemaVersion,
    );
```

#### `_reducePreoccupations` additional branches (add before final `return state`)
```dart
  if (event is PreoccupationUpdatedEvent) {
    final existing = state[event.aggregateId];
    if (existing == null) return state;
    return <String, Preoccupation>{
      ...state,
      event.aggregateId: existing.copyWith(content: event.content),
    };
  }
  if (event is PreoccupationDeletedEvent) {
    if (!state.containsKey(event.aggregateId)) return state;
    return Map<String, Preoccupation>.from(state)
      ..remove(event.aggregateId);
  }
```

#### Trivial-edit check (UI side, in `EditPreoccupationSheet._save()`)
```dart
final isNonTrivial = trimmedNew != item.content.trim();
await ref.read(brainDumpRepositoryProvider).updatePreoccupation(item.id, trimmedNew);
ref.read(projectionRevisionProvider.notifier).bump();
if (isNonTrivial) {
  unawaited(ref.read(analysisServiceProvider).analyzePreoccupation(
    id: item.id,
    content: trimmedNew,
  ));
}
```

### Testing Standards Summary

- Unit tests mirror `lib/` under `test/`. Use `package:flutter_test`, `package:mindow/...` imports, alphabetical import order (`dart:` first).
- Network/AI is never hit in tests — inject a fake `AiClient` where needed (see `analysis_service_test.dart` for the fake pattern).
- Real Hive boxes use a temp dir + `Hive.registerAdapters()` + `Hive.init()` pattern (see existing `brain_dump_repository_test.dart`).
- `dart format lib test` before every commit; `dart run build_runner build` (no `--delete-conflicting-outputs` locally); `flutter gen-l10n` after ARB changes.
- Do NOT use `[ref.xxx]` in doc comments — use backticks (CI lint trap, see Story 2.3 → fix `3564048`).
- Widget tests: avoid `pumpAndSettle` with indeterminate spinners.

### Scope Boundaries

**In scope (2.4):**
- `preoccupation.deleted` + `preoccupation.updated` events and decoders.
- `deletePreoccupation` + `updatePreoccupation` on `BrainDumpRepository`.
- Item-detail modal bottom sheet with edit and delete actions.
- Trivial-edit debounce (content-equality check) → re-analysis gate.
- Localization of all new copy (French first).

**Out of scope (later stories):**
- Mental Load sum display updating after delete (the projection is correct already — Story 2.5 will surface the sum in the kg hero number).
- "Backpack item tap opens backpack contents" (tapping the backpack SVG — Story 2.6).
- Couple Mode shared-item edit restrictions (Premium, Story 7+).
- Re-analysis debounce by time delay (a 1-second typing debounce on the edit field is acceptable UX but not required for MVP; the content-equality guard is the cost-guardrail).
- Server-side reconciliation of update/delete events via `reconcile` Edge Function (deferred from 2.1).

### References

- [Source: epics.md#Story 2.4: Edit and delete a Preoccupation] — user story + ACs
- [Source: epics.md#FR-5] — edit/delete + re-analysis debounce + Mental Weight removal
- [Source: epics.md#NFR-3] — offline-first (edit/delete work locally)
- [Source: epics.md#NFR-5] — i18n, French source of truth
- [Source: epics.md#NFR-11] — cost guardrail, debounce trivial edits
- [Source: architecture.md#Naming Patterns] — `preoccupation.deleted` explicitly listed; `domain.action` convention
- [Source: architecture.md#Decisions to Nail (3)] — conflict-resolution: validate vs delete
- [Source: architecture.md#Architectural Principles (1)] — append-only, frozen weight
- [Source: architecture.md#Project Structure & Boundaries] — features/, core/sync stays business-agnostic
- [Source: ux-designs/EXPERIENCE.md] — "Item detail | Backpack item tap | Read / edit / release one mental item"; "Modal stacks one level deep, never two"; tone-as-gate
- [Source: lib/features/brain_dump/brain_dump_repository.dart] — `_reducePreoccupations` note "a future edit/delete event (Story 2.4) can update or remove the same entry"; `BrainDumpRepository` constructor + existing methods
- [Source: lib/features/brain_dump/brain_dump_providers.dart] — `domainEventRegistry`, `projectionRevisionProvider`, `analysisServiceProvider` wiring
- [Source: lib/features/brain_dump/analysis_service.dart] — `analyzePreoccupation(id, content)` existing signature
- [Source: Story 2.3] — `ProjectionRevision` notifier introduced (fix commit `3564048`); `prefer_initializing_formals` ignore; `comment_references` lint trap
- [Source: Story 2.3#Resolved Decision #4] — latest `weight.assigned` wins; weight not cleared on edit

### Resolved Decisions

1. **Event name for edit**: `preoccupation.updated` — follows the `domain.action` past-tense convention; `preoccupation.deleted` is explicitly listed in architecture (confirmed).
2. **Trivial-edit definition (MVP)**: `newContent.trim() == originalContent.trim()` → skip re-analysis. No fuzzy/Levenshtein distance needed for MVP; the content-equality guard satisfies NFR-11 with zero dependencies.
3. **Weight NOT cleared on edit**: existing weight stays on the projection until a fresh `weight.assigned` arrives from re-analysis. Avoids a transient "pending" flicker and is consistent with "latest wins" — no new event type needed for this.
4. **Item-detail UX**: `showModalBottomSheet` from the list item tap (consistent with "Modal stacks one level deep" UX note). No new GoRouter route needed — reduces scope and prevents navigation-stack complexity.
5. **Orphan event guard**: both `PreoccupationUpdatedEvent` and `PreoccupationDeletedEvent` are silently ignored if no matching aggregate exists in the projection — same defensive pattern as `WeightAssignedEvent`.
6. **`preoccupation.deleted` payload**: empty `{}` tombstone — no content needed (the aggregate id is sufficient to remove the map entry).

## Dev Agent Record

### Agent Model Used

_to be filled by dev agent_

### Debug Log References

_to be filled by dev agent_

### Completion Notes List

_to be filled by dev agent_

### File List

_to be filled by dev agent_

## Change Log

| Date       | Version | Description                         | Author |
| ---------- | ------- | ----------------------------------- | ------ |
| 2026-06-09 | 0.1     | Story drafted, ready-for-dev        | boss   |
