class Users {
  final String id;
  final String email;
  final String name;

  Users(this.id, this.email, this.name);

  Users.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        email = json['email'],
        name = json['name'];
}
