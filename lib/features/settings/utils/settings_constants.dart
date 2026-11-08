class SettingsConstants {
  static const List<String> clearDataTypes = ['chats', 'journal', 'moods'];

  static Map<String, String> getClearDataTitle(String dataType) {
    switch (dataType) {
      case 'chats':
        return {
          'title': 'Clear Chat History',
          'message': 'This will delete all your chat conversations.',
        };
      case 'journal':
        return {
          'title': 'Clear Journal Entries',
          'message': 'This will delete all your journal entries.',
        };
      case 'moods':
        return {
          'title': 'Clear Mood Data',
          'message': 'This will delete all your mood tracking data.',
        };
      default:
        return {'title': '', 'message': ''};
    }
  }
}