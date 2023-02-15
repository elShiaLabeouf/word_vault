class Vocabulary {
  final int id;
  final String locale;

  Vocabulary(this.id, this.locale);

  Vocabulary.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        locale = json['locale'];

  Map<String, dynamic> toJson() => {'id': id, 'locale': locale};
}
