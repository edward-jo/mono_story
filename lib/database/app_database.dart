import 'dart:developer' as developer;
import 'dart:math';
import 'dart:io';

import 'package:mono_story/constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  Database? _database;

  Database get database => _database!;

  //----------------------------------------------------------------------------
  // V1
  //----------------------------------------------------------------------------

  void _createTableThreadsV1(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS $threadsTableNameV1');
    batch.execute('''CREATE TABLE $threadsTableNameV1 (
      ${ThreadsTableCols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${ThreadsTableCols.name} TEXT NOT NULL
)''');
  }

  void _createTableStoriesV1(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS $storiesTableNameV1');
    batch.execute('''CREATE TABLE $storiesTableNameV1 (
      ${StoriesTableCols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${StoriesTableCols.story} TEXT NOT NULL,
      ${StoriesTableCols.fkThreadId} INTEGER,
      ${StoriesTableCols.createdTime} TEXT NOT NULL,
      ${StoriesTableCols.starred} INTEGER NOT NULL,
      FOREIGN KEY(${StoriesTableCols.fkThreadId})
      REFERENCES $threadsTableNameV1 (_id)
      ON DELETE SET NULL
)''');
  }
  //----------------------------------------------------------------------------
  // V2
  //----------------------------------------------------------------------------

  void _createTableThreadsV2(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS $threadsTableNameV2');
    batch.execute('''CREATE TABLE $threadsTableNameV2 (
      ${ThreadsTableCols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${ThreadsTableCols.name} TEXT NOT NULL
)''');
  }

  void _createTableStoriesV2(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS $storiesTableNameV2');
    batch.execute('''CREATE TABLE $storiesTableNameV2 (
      ${StoriesTableCols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${StoriesTableCols.story} TEXT NOT NULL,
      ${StoriesTableCols.fkThreadId} INTEGER,
      ${StoriesTableCols.createdTime} TEXT NOT NULL,
      ${StoriesTableCols.starred} INTEGER NOT NULL,
      FOREIGN KEY(${StoriesTableCols.fkThreadId})
      REFERENCES $threadsTableNameV2 (_id)
      ON DELETE SET NULL
)''');
  }
  //----------------------------------------------------------------------------
  // V1 to V2
  //----------------------------------------------------------------------------

  // void _updateTableThreadsV1toV2(Batch batch) {
  //   batch.execute(
  //     'ALTER TABLE $threadsTableNameV1 RENAME TO $threadsTableNameV2',
  //   );
  // }

  void _updateTableStoriesV1toV2(Batch batch) {
    batch.execute(
      'ALTER TABLE $storiesTableNameV1 RENAME COLUMN ${StoriesTableColsV1.message} TO ${StoriesTableCols.story}',
    );
    batch.execute(
      'ALTER TABLE $storiesTableNameV1 RENAME TO $storiesTableNameV2',
    );
  }
  //----------------------------------------------------------------------------
  // Database Control
  //----------------------------------------------------------------------------

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
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        var batch = db.batch();
        _createTableThreadsV2(batch);
        _createTableStoriesV2(batch);
        await batch.commit();
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion == 1) {
          var batch = db.batch();
          _updateTableStoriesV1toV2(batch);
          await batch.commit();
        }
      },
    );
    developer.log('Opened database, status(${_database?.isOpen})');
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

  Future<void> replaceAppDatabaseWithRestore() async {
    final restoreFilePath = await getRestoreFilePath();
    final restoreFile = File(restoreFilePath);
    var path = restoreFile.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + appDatabaseFileName;
    restoreFile.renameSync(newPath);
    developer.log(
      'Renamed restore backup file( $restoreFilePath ) to\n $newPath',
    );
    return;
  }

  Future<String> getAppDatabaseDirPath() async {
    return getDatabasesPath();
  }

  Future<String> getRestoreFilePath() async {
    final databasePath = await getDatabasesPath();
    final databaseFilePath = join(databasePath, appRestoreDatabaseFileName);
    return databaseFilePath;
  }
}
