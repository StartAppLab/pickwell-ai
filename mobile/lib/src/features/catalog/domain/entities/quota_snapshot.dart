enum QuotaMetric { barcodeLookup, aiAnalysis }

// Advisory server response only. Never used to authorize or locally spend allowance.
class QuotaSnapshot {
  final QuotaMetric metric;
  final int limit, remaining, used, reserved, version;
  final DateTime resetAt, receivedAt;
  // Local SDK session identity, not a server capability or a persisted account cache.
  final String? ownerId;
  const QuotaSnapshot({
    required this.metric,
    required this.limit,
    required this.remaining,
    required this.used,
    required this.reserved,
    required this.version,
    required this.resetAt,
    required this.receivedAt,
    this.ownerId,
  });
  bool expired(DateTime now) => !now.toUtc().isBefore(resetAt.toUtc());
}
