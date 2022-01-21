import 'dart:developer' as developer;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants.dart';

class AppDatabase {
  Database? _database;

  Database get database => _database!;

  Future init() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
    await _openAppDatabase();
  }

  Future<void> _openAppDatabase() async {
    final databasePath = await getDatabasesPath();
    final databaseFilePath = join(databasePath, appDatabaseFileName);

    developer.log('Open database( $databaseFilePath )');
    _database = await openDatabase(
      databaseFilePath,
      version: appDatabaseVersion,
      onCreate: _onCreate,
    );
    developer.log('Opened database, status(${_database?.isOpen})');
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE $threadNamesTableName (
  ${ThreadsTableCols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${ThreadsTableCols.name} TEXT NOT NULL
)
''');
    await db.execute('''
CREATE TABLE $messagesTableName (
  ${MessagesTableCols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${MessagesTableCols.message} TEXT NOT NULL,
  ${MessagesTableCols.fkThreadNameId} INTEGER NOT NULL,
  ${MessagesTableCols.createdTime} TEXT NOT NULL,
  FOREIGN KEY(${MessagesTableCols.fkThreadNameId}) REFERENCES $threadNamesTableName(id)
)
''');
  }

  Future<void> closeAppDatabase() async {
    if (_database == null || _database!.isOpen == false) {
      return;
    }

    await _database?.close();
    _database = null;
    developer.log('Closed database');
  }

  Future<void> deleteAppDatabase() async {
    final databasePath = await getDatabasesPath();
    final databaseFilePath = join(databasePath, appDatabaseFileName);

    developer.log('Delete database( $databaseFilePath )');
    await deleteDatabase(databaseFilePath);
    _database = null;
    developer.log('Deleted database');
    return;
  }
}
