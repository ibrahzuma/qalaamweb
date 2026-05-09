class Dua {
  final int id;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;
  final String category; // human name (category_name from backend)
  final int? categoryId;
  final String audioUrl;

  Dua({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
    required this.category,
    this.categoryId,
    this.audioUrl = '',
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? '',
      // Backend uses `arabic_text`; older payloads may use `arabic`.
      arabic: (json['arabic_text'] as String?) ?? (json['arabic'] as String?) ?? '',
      transliteration: (json['transliteration'] as String?) ?? '',
      translation: (json['translation'] as String?) ?? '',
      reference: (json['reference'] as String?) ?? '',
      category: (json['category_name'] as String?) ??
          (json['category']?.toString()) ??
          'General',
      categoryId: json['category'] is int ? json['category'] as int : null,
      audioUrl: (json['audio_url'] as String?) ?? (json['audio_file'] as String?) ?? '',
    );
  }
}
