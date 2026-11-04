/// Public derivative reference only. Never a private Storage key or captured file.
class ProductThumbnail {
  final String id, digest;
  final int width, height;
  const ProductThumbnail({
    required this.id,
    required this.digest,
    required this.width,
    required this.height,
  });

  String? url(String serverBaseUrl) {
    final origin = Uri.tryParse(serverBaseUrl);
    if (origin == null ||
        origin.host.isEmpty ||
        origin.userInfo.isNotEmpty ||
        (origin.scheme != 'https' &&
            !(origin.scheme == 'http' && ['localhost', '127.0.0.1'].contains(origin.host)))) {
      return null;
    }
    return origin
        .replace(
          path: '/functions/v1/get-product-thumbnail',
          queryParameters: {'id': id, 'v': digest},
          fragment: '',
        )
        .toString();
  }
}
