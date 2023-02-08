class Label {
  final int id;
  final String name;

  Label(this.id, this.name);

  Label.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
