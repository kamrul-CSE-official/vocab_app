class WordEntry {
  final int? id;
  final String word;
  final String banglaMeaning;
  final String synonyms; // comma-separated
  final String antonyms; // comma-separated
  final String exampleSentence;
  final DateTime createdAt;

  WordEntry({
    this.id,
    required this.word,
    required this.banglaMeaning,
    this.synonyms = '',
    this.antonyms = '',
    this.exampleSentence = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'banglaMeaning': banglaMeaning,
      'synonyms': synonyms,
      'antonyms': antonyms,
      'exampleSentence': exampleSentence,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WordEntry.fromMap(Map<String, dynamic> map) {
    return WordEntry(
      id: map['id'] as int?,
      word: map['word'] as String,
      banglaMeaning: map['banglaMeaning'] as String,
      synonyms: map['synonyms'] as String? ?? '',
      antonyms: map['antonyms'] as String? ?? '',
      exampleSentence: map['exampleSentence'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  WordEntry copyWith({
    int? id,
    String? word,
    String? banglaMeaning,
    String? synonyms,
    String? antonyms,
    String? exampleSentence,
    DateTime? createdAt,
  }) {
    return WordEntry(
      id: id ?? this.id,
      word: word ?? this.word,
      banglaMeaning: banglaMeaning ?? this.banglaMeaning,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Helper to split the comma-separated synonym/antonym strings into chips.
  static List<String> splitList(String raw) => raw
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}
