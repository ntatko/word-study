class AppConstants {
  // API URLs
  static const String passagesApiUrl =
      'https://homiletics-directus.cloud.plodamouse.com/items/suggested_passages';
  static const String bibleGatewayBaseUrl =
      'https://www.biblegateway.com/passage/';

  // Bible Versions
  static const List<String> bibleVersions = [
    'NIV',
    'ESV',
    'NASB',
    'KJV',
    'NKJV',
    'NLT',
    'MSG',
    'AMP',
    'CSB',
    'NET',
  ];

  // Hive Box Names
  static const String wordStudiesBoxName = 'word_studies';
  static const String passagesBoxName = 'passages';

  // App Info
  static const String appName = 'Word Study';
  static const String appVersion = '1.0.0';

  // UI Constants
  static const double cardElevation = 4.0;
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double spacing = 8.0;
}
