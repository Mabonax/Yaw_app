class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  factory AppConfig.fromEnvironment() {
    const configuredBaseUrl = String.fromEnvironment('YAW_API_BASE_URL');

    return AppConfig(
      apiBaseUrl: Uri.parse(
        configuredBaseUrl.isEmpty
            ? 'http://10.0.2.2:8000/api/v1'
            : configuredBaseUrl,
      ),
    );
  }

  final Uri apiBaseUrl;
}
