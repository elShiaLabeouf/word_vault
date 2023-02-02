import 'package:bootcamp/helpers/database_helper.dart';
import 'dart:async';
import 'package:bootcamp/models/label.dart';
import 'package:sqflite/sqflite.dart';

class LabelsRepo {
  static final DatabaseHelper instance = DatabaseHelper.instance;
  
  Future<List<Label>> getLabelsAll() async {
    Database? db = await instance.database;
    var parsed = await db!.query('labels', orderBy: 'name');
    return parsed.map<Label>((json) => Label.fromJson(json)).toList();
  }

  Future<bool> insertLabel(String labelName) async {
    Database? db = await instance.database;
    await db!.rawInsert('''
      INSERT OR IGNORE into labels (name) values ('$labelName');
    ''');
    return true;
  }

  Future<bool> updateLabel(Label label) async {
    Database? db = await instance.database;
    Map<String, dynamic> map = {
      'id': label.id,
      'name': label.name
    };
    int _id = map['id'];
    final rowsAffected = await db!
        .update('labels', map, where: 'id = ?', whereArgs: [_id]);
    return (rowsAffected == 1);
  }

  Future<void> deleteLabel(int id) async {
    print("deleteLabel: id=${id}");
    Database? db = await instance.database;
    await db!.delete('labels', where: 'id = ?', whereArgs: [id]);
    await db.delete('phrase_labels', where: 'label_id = ?', whereArgs: [id]);
  }

}