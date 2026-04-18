class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://api.websocket.uk:3000',
  );

  static const String chatBaseUrl = String.fromEnvironment(
    'CHAT_BASE_URL',
    defaultValue: 'http://chat.websocket.uk:3001',
  );
}
