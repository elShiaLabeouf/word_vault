import 'package:bootcamp/helpers/database_helper.dart';
import 'dart:async';
import 'package:bootcamp/models/vocabulary.dart';
import 'package:sqflite/sqflite.dart';

class VocabulariesRepo {
  static final DatabaseHelper instance = DatabaseHelper.instance;

  Future<List<Map>> getWordsCount() async {
    Database? db = await instance.database;
    var parsed = await db!.rawQuery('''
      SELECT locale, count(phrases.id) FROM vocabularies LEFT JOIN phrases ON phrases.vocabulary_id=vocabularies.id GROUP BY locale;
    ''');
    return parsed.toList();
  }

}
