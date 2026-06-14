class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.websocket.uk',
  );

  static const String chatBaseUrl = String.fromEnvironment(
    'CHAT_BASE_URL',
    defaultValue: 'https://chat.websocket.uk',
  );
}
