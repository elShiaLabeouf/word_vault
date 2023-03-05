import 'package:word_vault/helpers/database_helper.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

class PhraseLabelsRepo {
  static final DatabaseHelper instance = DatabaseHelper.instance;

  Future<bool> insertPhraseLabel(int id, int labelId) async {
    Database? db = await instance.database;
    await db!.rawInsert('''
      INSERT OR IGNORE into phrase_labels (phrase_id, label_id) values ('$id', '$labelId');
    ''');
    return true;
  }

  Future<void> removePhraseLabel(int phraseId, int labelId) async {
    Database? db = await instance.database;
    await db!.rawDelete('''
      DELETE from phrase_labels where phrase_id=$phraseId and label_id=$labelId;
    ''');
  }
}
