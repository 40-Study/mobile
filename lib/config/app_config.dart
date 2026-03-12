/// App config.
class AppConfig {
  AppConfig({required this.url});

  final String url;

  AppConfig copyWith({
    String? url,
    String? proxyUrl,
  }) =>
      AppConfig(
        url: url ?? this.url,
      );
}
