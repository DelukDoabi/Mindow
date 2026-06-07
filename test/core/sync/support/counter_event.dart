import 'package:mindow/core/sync/domain_event.dart';

/// A test-only [DomainEvent] used to exercise the generic sync engine without
/// pulling any real feature type into `core/sync`.
///
/// It models a trivial counter: each event adds [amount] to a running total,
/// so a converged projection is just the sum of all amounts.
class CounterIncremented extends DomainEvent {
  const CounterIncremented({
    required super.eventId,
    required super.aggregateId,
    required super.occurredAt,
    required this.amount,
    super.schemaVersion,
  });

  /// The `event_type` discriminator for this fake event.
  static const String type = 'counter.incremented';

  /// The amount to add to the running total.
  final int amount;

  @override
  String get eventType => type;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'amount': amount};
}

/// Decodes a [CounterIncremented] from its envelope.
DomainEvent decodeCounterIncremented(EventEnvelope envelope) =>
    CounterIncremented(
      eventId: envelope.eventId,
      aggregateId: envelope.aggregateId,
      occurredAt: envelope.createdAt,
      amount: (envelope.payload['amount'] as num).toInt(),
      schemaVersion: envelope.schemaVersion,
    );

/// A [DomainEventRegistry] preloaded with the counter decoder.
DomainEventRegistry counterRegistry() =>
    DomainEventRegistry()
      ..register(CounterIncremented.type, decodeCounterIncremented);

/// A reducer that sums counter increments into a running total.
int counterReducer(int state, DomainEvent event) =>
    state + (event as CounterIncremented).amount;
