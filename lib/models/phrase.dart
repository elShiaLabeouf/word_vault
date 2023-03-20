class Phrase {
  int id;
  String phrase;
  String definition;
  bool active;
  DateTime createdAt;
  DateTime updatedAt;
  String? labels;
  int vocabularyId;
  int rating;
  isNewRecord() {
    return id == 0;
  }

  Phrase(this.id, this.phrase, this.definition, this.active, this.createdAt,
      this.updatedAt, this.vocabularyId, this.rating);

  Phrase.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        phrase = json['phrase'],
        definition = json['definition'],
        active = json['active'] == 1 || json['active'] == '1',
        createdAt = DateTime.parse(json['created_at']),
        updatedAt = DateTime.parse(json['updated_at']),
        labels = json['labels'],
        vocabularyId = json['vocabulary_id'],
        rating = json['rating'];
  Map<String, dynamic> toJson() => {
        'id': id,
        'phrase': phrase,
        'definition': definition,
        'active': active,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'labels': labels,
        'vocabulary_id': vocabularyId,
        'rating': rating
      };
}
