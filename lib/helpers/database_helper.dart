import 'package:word_vault/models/phrase.dart';
import 'package:word_vault/models/label.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = 'word_vault.s3db';
  static final _databaseVersion = 6;
  Database? _database;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    var databasePath = await getDatabasesPath();

    String path = join(databasePath, _databaseName);
    // databaseFactory.deleteDatabase(path);
    return await openDatabase(path, version: _databaseVersion,
        onCreate: (Database db, int version) async {
      await db.execute('''CREATE TABLE phrases (id INTEGER primary key,
                                   phrase TEXT,
                                   definition TEXT,
                                   active INTEGER DEFAULT 1,
                                   vocabulary_id INTEGER,
                                   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                   updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                   rating INTEGER DEFAULT 0,
                                   CONSTRAINT phrase_unique UNIQUE (phrase, definition)
                                  ) ''');

      await db.execute('''CREATE TABLE phrase_labels (
                                    id INTEGER primary key,
                                    phrase_id INTEGER,
                                    label_id INTEGER,
                                    CONSTRAINT phrase_id_label_id UNIQUE (phrase_id, label_id)
                                  ) ''');

      await db.execute('''CREATE TABLE labels (id INTEGER primary key,
                                   name TEXT,
                                   CONSTRAINT name UNIQUE (name)
                                 ) ''');

      await db.execute('''CREATE TABLE vocabularies (id INTEGER primary key,
                                  locale TEXT
                                  )''');
    }, onUpgrade: (Database db, int oldVersion, int version) async {
      if (oldVersion == 2) {
        await db.execute('''ALTER TABLE phrases ADD vocabulary_id INTEGER ''');
        await db.execute('''CREATE TABLE vocabularies (id INTEGER primary key,
                                    name TEXT,
                                    icon TEXT
                                    )''');
      }

      if (oldVersion == 3) {
        await db.execute(
            '''ALTER TABLE vocabularies RENAME COLUMN name TO locale;''');
      }

      if (oldVersion == 4) {
        await db.execute(
            '''CREATE UNIQUE INDEX phrase_unique ON phrases(phrase, definition);''');
      }

      if (oldVersion == 5) {
        await db
            .execute('''ALTER TABLE phrases ADD rating INTEGER DEFAULT 0;''');
      }
    });
  }
}
