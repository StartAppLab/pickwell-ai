import '../../domain/entities/quota_snapshot.dart';

class QuotaModel {
  static QuotaSnapshot? parse(Map<String, dynamic> response, QuotaMetric metric) {
    final value = response['quota'];
    if (value is! Map) return null;
    for (final key in ['limit', 'remaining', 'used', 'reserved', 'version']) {
      if (value[key] is! int || (value[key] as int) < 0 || (value[key] as int) > 2147483647) {
        return null;
      }
    }
    if (value['version'] < 1 || value['remaining'] > value['limit']) return null;
    // Validate the protocol; display the server's remaining, never a mutable client counter.
    final expected = value['limit'] - value['used'] - value['reserved'];
    if (value['remaining'] != (expected < 0 ? 0 : expected)) return null;
    final reset = value['reset_at'];
    if (reset is! String || !RegExp(r'(Z|[+-]\d\d:\d\d)$').hasMatch(reset)) return null;
    final time = DateTime.tryParse(reset)?.toUtc();
    if (time == null ||
        time.hour != 0 ||
        time.minute != 0 ||
        time.second != 0 ||
        time.millisecond != 0) {
      return null;
    }
    return QuotaSnapshot(
      metric: metric,
      limit: value['limit'],
      remaining: value['remaining'],
      used: value['used'],
      reserved: value['reserved'],
      version: value['version'],
      resetAt: time,
      receivedAt: DateTime.now().toUtc(),
      ownerId: response['_quota_subject'] is String ? response['_quota_subject'] as String : null,
    );
  }
}
