class Surah {
  final int number;
  final String name; // Arabic
  final String englishName; // Transliteration
  final String englishNameTranslation; // English meaning
  final int numberOfAyahs;
  final String revelationType;
  final int juzNumber;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    this.juzNumber = 1,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      name: (json['name'] as String?) ?? '',
      englishName: (json['english_name'] as String?) ?? (json['name_english'] as String?) ?? '',
      englishNameTranslation: (json['english_name_translation'] as String?) ?? '',
      numberOfAyahs: (json['number_of_ayahs'] as int?) ?? 0,
      revelationType: ((json['revelation_type'] as String?) ?? '').toUpperCase(),
      juzNumber: (json['juz_number'] as int?) ?? 1,
    );
  }
}
