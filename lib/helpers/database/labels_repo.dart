import 'package:word_vault/helpers/database_helper.dart';
import 'dart:async';
import 'package:word_vault/models/label.dart';
import 'package:sqflite/sqflite.dart';

class LabelsRepo {
  static final DatabaseHelper instance = DatabaseHelper.instance;

  Future<List<Label>> getLabelsAll() async {
    Database? db = await instance.database;
    var parsed = await db!.query('labels', orderBy: 'name');
    return parsed.map<Label>((json) => Label.fromJson(json)).toList();
  }

  Future<int> insertLabel(String labelName) async {
    Database? db = await instance.database;
    Map<String, dynamic> map = {
      'name': labelName,
    };

    int id = await db!
        .insert('labels', map, conflictAlgorithm: ConflictAlgorithm.ignore);
    return id;
  }

  Future<int> findOrCreateLabel(String labelName) async {
    Database? db = await instance.database;
    var parsed = await db!.rawQuery('''
      SELECT id
      FROM labels
      where name = '$labelName'
      ''');
    if (parsed.isNotEmpty) {
      return parsed[0]['id'] as int;
    } else {
      Map<String, dynamic> map = {'name': labelName};
      await db.insert('labels', map);
      return await findOrCreateLabel(labelName);
    }
  }

  Future<bool> updateLabel(Label label) async {
    Database? db = await instance.database;
    Map<String, dynamic> map = {'id': label.id, 'name': label.name};
    int _id = map['id'];
    final rowsAffected =
        await db!.update('labels', map, where: 'id = ?', whereArgs: [_id]);
    return (rowsAffected == 1);
  }

  Future<void> deleteLabel(int id) async {
    print("deleteLabel: id=${id}");
    Database? db = await instance.database;
    await db!.delete('labels', where: 'id = ?', whereArgs: [id]);
    await db.delete('phrase_labels', where: 'label_id = ?', whereArgs: [id]);
  }
}
