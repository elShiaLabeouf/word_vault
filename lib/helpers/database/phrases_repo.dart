import 'package:bootcamp/helpers/database_helper.dart';
import 'dart:async';
import 'package:bootcamp/models/phrase.dart';
import 'package:sqflite/sqflite.dart';

class PhrasesRepo {
  static final DatabaseHelper instance = DatabaseHelper.instance;

  Future<List<Phrase>> getPhrasesAll(String filter) async {
    Database? db = await instance.database;
    var parsed = await db!.rawQuery('''
      SELECT phrases.*, labels.labels
      FROM phrases
      left join (
        SELECT phrase_labels.phrase_id, GROUP_CONCAT(labels.name) as labels
        FROM labels
        left join phrase_labels on phrase_labels.label_id = labels.id
        group by phrase_labels.phrase_id
      ) labels on labels.phrase_id = phrases.id
      where active = 1 
      ${filter.isNotEmpty ? 'AND (phrase LIKE \'%$filter%\' OR definition LIKE \'%$filter%\')' : ''}
      ''');
    return parsed.map<Phrase>((json) => Phrase.fromJson(json)).toList();
  }

  Future<List<Phrase>> getPhrasesForQuiz() async {
    Database? db = await instance.database;
    var parsed = await db!.rawQuery('''
      SELECT phrases.*, labels.labels
      FROM phrases
      left join (
        SELECT phrase_labels.phrase_id, GROUP_CONCAT(labels.name) as labels
        FROM labels
        left join phrase_labels on phrase_labels.label_id = labels.id
        group by phrase_labels.phrase_id
      ) labels on labels.phrase_id = phrases.id
      where active = 1 
      ORDER BY RANDOM()
      LIMIT 10
      ''');
    return parsed.map<Phrase>((json) => Phrase.fromJson(json)).toList();
  }

  Future<List<Phrase>> getPhrasesByLabel(String labelValue) async {
    Database? db = await instance.database;
    var parsed = await db!.rawQuery('''
      SELECT phrases.*, labels
      FROM phrases
      left join (
        SELECT phrase_id, GROUP_CONCAT(name) as labels
        FROM labels
        left join phrase_labels on phrase_labels.label_id = labels.id
        group by phrase_labels.phrase_id
      ) labels on labels.phrase_id = phrases.id
      where active = 1 and labels like '%$labelValue%'
      ''');
    return parsed.map<Phrase>((json) => Phrase.fromJson(json)).toList();
  }

  Future<List<Phrase>> getPhrasesArchived(String filter) async {
    Database? db = await instance.database;
    var parsed = await db!.query('phrases',
        orderBy: 'created_at DESC',
        where:
            'active = 0${filter.isNotEmpty ? ' AND (phrase LIKE \'%$filter%\' OR definition LIKE \'%$filter%\')' : ''}');
    return parsed.map<Phrase>((json) => Phrase.fromJson(json)).toList();
  }

  Future<bool> archivePhrase(int id, bool active) async {
    Database? db = await instance.database;
    Map<String, dynamic> map = {'id': id, 'active': active};
    String _id = map['id'];
    final rowsAffected =
        await db!.update('phrases', map, where: 'id = ?', whereArgs: [_id]);

    return (rowsAffected == 1);
  }

  Future<bool> insertPhrase(Phrase phrase) async {
    Database? db = await instance.database;
    Map<String, dynamic> map = {
      'phrase': phrase.phrase,
      'definition': phrase.definition
    };

    await db!.insert('phrases', map);
    return true;
  }

  Future<bool> updatePhrase(Phrase phrase) async {
    Database? db = await instance.database;
    Map<String, dynamic> map = {
      'id': phrase.id,
      'phrase': phrase.phrase,
      'definition': phrase.definition,
      'updated_at': DateTime.now().toString()
    };
    String _id = map['id'];
    final rowsAffected =
        await db!.update('phrases', map, where: 'id = ?', whereArgs: [_id]);
    return (rowsAffected == 1);
  }

  Future<bool> deletePhrase(int id) async {
    Database? db = await instance.database;
    int rowsAffected =
        await db!.delete('phrases', where: 'id = ?', whereArgs: [id]);
    await db.delete('phrase_labels', where: 'phrase_id = ?', whereArgs: [id]);
    return (rowsAffected >= 1);
  }

  Future<bool> deletePhrasesAll() async {
    Database? db = await instance.database;
    int rowsAffected = await db!.delete('phrases');
    return (rowsAffected >= 0);
  }
}
