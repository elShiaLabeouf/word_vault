import 'package:word_vault/helpers/database_helper.dart';
import 'dart:async';
import 'package:word_vault/models/vocabulary.dart';
import 'package:sqflite/sqflite.dart';

class VocabulariesRepo {
  static final DatabaseHelper instance = DatabaseHelper.instance;

  Future<List<Map<String, Object?>>> getWordsCount() async {
    Database? db = await instance.database;
    var parsed = await db!.rawQuery('''
      SELECT locale, count(phrases.id) as count FROM vocabularies LEFT JOIN phrases ON phrases.vocabulary_id=vocabularies.id GROUP BY locale;
    ''');
    return parsed.toList();
  }

  Future<List<String>> getAllVocabularies() async {
    Database? db = await instance.database;
    var parsed = await db!.rawQuery('''
      SELECT locale FROM vocabularies
    ''');
    return parsed.map((e) => e['locale'] as String).toList();
  }

  Future<int> findOrCreateVocabulary(String locale) async {
    Database? db = await instance.database;
    var parsed = await db!.rawQuery('''
      SELECT id
      FROM vocabularies
      where locale = '$locale'
      ''');
    if (parsed.isNotEmpty) {
      return parsed[0]['id'] as int;
    } else {
      Map<String, dynamic> map = {'locale': locale};
      await db.insert('vocabularies', map);
      return await findOrCreateVocabulary(locale);
    }
  }
}
