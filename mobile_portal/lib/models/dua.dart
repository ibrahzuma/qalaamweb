class Dua {
  final int id;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String category;
  final bool isFavorite;

  Dua({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.category,
    this.isFavorite = false,
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'],
      title: json['title'],
      arabic: json['arabic'],
      transliteration: json['transliteration'] ?? '',
      translation: json['translation'] ?? '',
      category: json['category'] ?? 'General',
      isFavorite: json['is_favorite'] ?? false,
    );
  }
}
