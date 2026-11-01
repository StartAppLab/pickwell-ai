/// These client snapshots support presentation; backend authorization is independent.
enum EntitlementSource { revenueCat, server }

class EntitlementGrant {
  const EntitlementGrant({
    required this.id,
    required this.isActive,
    required this.isNonExpiring,
    this.expiresAt,
    this.isTrial = false,
  });

  final String id;
  final bool isActive;
  final bool isNonExpiring;
  final DateTime? expiresAt;
  final bool isTrial;

  bool allowsAt(DateTime now) =>
      isActive && (expiresAt != null ? expiresAt!.isAfter(now) : isNonExpiring);
}

class EntitlementSnapshot {
  EntitlementSnapshot({
    required this.subjectId,
    required this.source,
    required this.checkedAt,
    required Map<String, EntitlementGrant> grants,
  }) : grants = Map.unmodifiable(grants);

  /// The current application identity; null denotes the current guest session.
  final String? subjectId;
  final EntitlementSource source;
  final DateTime checkedAt;
  final Map<String, EntitlementGrant> grants;
}

/// Implementations own their listeners, but do not own the shared purchase client.
/// A server implementation must never fall back to client approval on failure.
abstract class EntitlementProvider {
  Future<EntitlementSnapshot> refresh({required String? userId});
  Future<EntitlementSnapshot> changeIdentity(String? userId);
  Stream<EntitlementSnapshot> get updates;
  Future<void> dispose();
}

/// Hard verification failures invalidate cached approval; transport failures do not.
class EntitlementVerificationException implements Exception {
  const EntitlementVerificationException();

  @override
  String toString() => 'Unable to verify entitlement information.';
}
