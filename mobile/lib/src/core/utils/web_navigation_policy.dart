/// Validates embedded browser destinations by scheme and hostname, never substrings.
class WebNavigationPolicy {
  WebNavigationPolicy({
    required Uri initialUri,
    Iterable<String> allowedDomains = const [],
    this.allowSubdomains = false,
  }) : allowedHosts = {
         initialUri.host.toLowerCase(),
         ...allowedDomains.map(_host).where((host) => host.isNotEmpty),
       } {
    if (!allows(initialUri)) {
      throw ArgumentError.value(initialUri, 'initialUri', 'An HTTPS URL is required');
    }
  }

  final Set<String> allowedHosts;
  final bool allowSubdomains;

  bool allows(Uri? uri) {
    if (uri == null || uri.scheme != 'https' || uri.userInfo.isNotEmpty || uri.host.isEmpty) {
      return false;
    }
    final host = uri.host.toLowerCase();
    return allowedHosts.any(
      (allowed) => host == allowed || (allowSubdomains && host.endsWith('.$allowed')),
    );
  }

  static bool canOpenExternally(Uri? uri) =>
      uri != null &&
      const {'https', 'http', 'mailto', 'tel'}.contains(uri.scheme) &&
      ((uri.scheme != 'https' && uri.scheme != 'http') || uri.host.isNotEmpty);

  static String _host(String value) {
    final normalized = value.trim().toLowerCase();
    return Uri.tryParse(normalized.contains('://') ? normalized : 'https://$normalized')?.host ??
        '';
  }
}
