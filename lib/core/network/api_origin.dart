// So origin chính xác (scheme + host + port), không dùng contains để tránh leak token
bool isSameOrigin(Uri url, Uri apiBase) =>
    url.scheme == apiBase.scheme &&
    url.host.toLowerCase() == apiBase.host.toLowerCase() &&
    url.port == apiBase.port;

// Chỉ gắn Bearer khi URL thuộc đúng API origin
Map<String, String> videoAuthHeaders(
  Uri url, {
  required Uri apiBase,
  required String? token,
}) {
  if (token == null || !isSameOrigin(url, apiBase)) return const {};
  return {'Authorization': 'Bearer $token'};
}
