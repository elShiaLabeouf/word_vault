import 'package:word_vault/common/constants.dart';
import 'package:word_vault/helpers/database/vocabularies_repo.dart';
import 'package:word_vault/helpers/database_helper.dart';
import 'dart:async';
import 'package:word_vault/models/phrase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class PhrasesRepo {
  static final DatabaseHelper instance = DatabaseHelper.instance;

  Future<List<Phrase>> getPhrasesAll(
      {String? filter,
      String? locale,
      List<int> active = const [1],
      String? labelFilter}) async {
    locale = locale ?? await getCurrentVocabulary();
    Database? db = await instance.database;
    var parsed = await db!.rawQuery('''
      SELECT phrases.*, labels.labels
      FROM phrases
      LEFT JOIN (
        SELECT phrase_labels.phrase_id, GROUP_CONCAT(labels.name) as labels
        FROM labels
        LEFT JOIN phrase_labels ON phrase_labels.label_id = labels.id
        GROUP BY phrase_labels.phrase_id
      ) labels ON labels.phrase_id = phrases.id
      LEFT JOIN vocabularies ON vocabularies.id = phrases.vocabulary_id
      WHERE active IN (${active.join(',')}) 
      AND vocabularies.locale = '$locale'
      ${labelFilter != null ? " AND labels like '%$labelFilter%'" : ''}
      ${filter != null && filter.isNotEmpty ? " AND (phrase LIKE '%$filter%' OR definition LIKE '%$filter%')" : ''}
      ORDER BY created_at DESC
      ''');
    return parsed.map<Phrase>((json) => Phrase.fromJson(json)).toList();
  }

  Future<List<Phrase>> getPhrasesForQuiz() async {
    Database? db = await instance.database;
    String locale = await getCurrentVocabulary() ?? 'en';
    var parsed = await db!.rawQuery('''
      SELECT * FROM (SELECT phrases.*
      FROM phrases
      LEFT JOIN vocabularies ON vocabularies.id = phrases.vocabulary_id
      WHERE active = 1 and vocabularies.locale = '${locale}' and rating <= 4
      ORDER BY RANDOM()
      LIMIT 6)

      UNION

      SELECT * FROM (SELECT phrases.*
      FROM phrases
      LEFT JOIN vocabularies ON vocabularies.id = phrases.vocabulary_id
      WHERE active = 1 and vocabularies.locale = '${locale}' and rating > 4 AND rating <= 6
      ORDER BY RANDOM()
      LIMIT 3)

      UNION

      SELECT * FROM (SELECT phrases.*
      FROM phrases
      LEFT JOIN vocabularies ON vocabularies.id = phrases.vocabulary_id
      WHERE active = 1 and vocabularies.locale = '${locale}' and rating > 6
      ORDER BY RANDOM()
      LIMIT 1)
      ''');
    if (parsed.length < 10) {
      var parsed2 = await db.rawQuery('''
      SELECT phrases.*
      FROM phrases
      LEFT JOIN vocabularies ON vocabularies.id = phrases.vocabulary_id
      WHERE active = 1 and vocabularies.locale = '${locale}'
      AND phrases.id NOT IN (${parsed.map((e) => e['id']).join(',')})
      ORDER BY RANDOM()
      LIMIT ${10 - parsed.length}''');
      parsed = [...parsed, ...parsed2];
    }
    var result = parsed.map<Phrase>((json) => Phrase.fromJson(json)).toList();
    result.shuffle();
    return result;
  }

  Future<bool> archivePhrase(int id, bool active) async {
    Database? db = await instance.database;
    Map<String, dynamic> map = {'id': id, 'active': active ? 1 : 0};
    final rowsAffected = await db!
        .update('phrases', map, where: 'id = ?', whereArgs: [map['id']]);

    return (rowsAffected == 1);
  }

  Future<int> insertPhrase(Phrase phrase) async {
    VocabulariesRepo vocabulariesRepo = VocabulariesRepo();
    if (phrase.vocabularyId == 0) {
      phrase.vocabularyId = await vocabulariesRepo
          .findOrCreateVocabulary(await getCurrentVocabulary() ?? 'en');
    }
    Database? db = await instance.database;
    Map<String, dynamic> map = {
      'phrase': phrase.phrase,
      'definition': phrase.definition,
      'vocabulary_id': phrase.vocabularyId,
    };

    int id = await db!
        .insert('phrases', map, conflictAlgorithm: ConflictAlgorithm.ignore);
    return id;
  }

  Future<int> updatePhrase(Phrase phrase) async {
    Database? db = await instance.database;
    Map<String, dynamic> map = {
      'id': phrase.id,
      'phrase': phrase.phrase,
      'definition': phrase.definition,
      'updated_at': DateTime.now().toString()
    };
    int id = map['id'];
    await db!.update('phrases', map, where: 'id = ?', whereArgs: [id]);
    return phrase.id;
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

  Future<String?> getCurrentVocabulary() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_vocabulary');
  }

  Future<void> updatePhraseRating(Phrase phrase, int ratingChange) async {
    phrase.rating += ratingChange;
    if (phrase.rating > phraseRatingEnum.length - 1) {
      phrase.rating = phraseRatingEnum.length - 1;
    } else if (phrase.rating < 0) {
      phrase.rating = 0;
    }
    Database? db = await instance.database;
    await db!.rawUpdate('''
      UPDATE phrases
      SET rating = ${phrase.rating}
      WHERE id = ${phrase.id}
      ''');
  }

  Future<double> getAverageRating() async {
    Database? db = await instance.database;
    String locale = await getCurrentVocabulary() ?? 'en';
    String ratingEnumSelect = phraseRatingEnum
        .map((e) => "SELECT ${phraseRatingEnum.indexOf(e)} as id, $e as rating")
        .toList()
        .join(' UNION ');
    var parsed = await db!.rawQuery('''
      WITH ratings AS ($ratingEnumSelect)
      SELECT AVG(ratings.rating) as average
      FROM phrases
      LEFT JOIN ratings ON ratings.id = phrases.rating
      LEFT JOIN vocabularies ON vocabularies.id = phrases.vocabulary_id
      WHERE active = 1 and vocabularies.locale = '$locale'
      ''');
    return double.parse("${parsed.first['average'] ?? '0'}");
  }
}
