import 'package:bootcamp/models/phrase.dart';
import 'package:bootcamp/models/label.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = 'bootcamp.s3db';
  static final _databaseVersion = 2;
  static final _databaseOldVersion = 1;
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
                                   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                   updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
    });
  }
}