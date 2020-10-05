class SettingsRepository {
  final String requestsImporterExecutable;

  const SettingsRepository(this.requestsImporterExecutable);

  factory SettingsRepository.fromJson(Map<String, dynamic> data) =>
      SettingsRepository(data['requests_exec']);
}
