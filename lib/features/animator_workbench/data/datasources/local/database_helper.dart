import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'animator_workbench.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE assets (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        parent_id TEXT,
        type TEXT NOT NULL,
        file_path TEXT NOT NULL,
        metadata TEXT,
        pipeline_info TEXT,
        is_master_reference INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY(parent_id) REFERENCES assets(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        source_asset_id TEXT NOT NULL,
        target_asset_id TEXT NOT NULL,
        parameters TEXT,
        error_message TEXT,
        progress REAL DEFAULT 0.0,
        retry_count INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY(source_asset_id) REFERENCES assets(id),
        FOREIGN KEY(target_asset_id) REFERENCES assets(id)
      )
    ''');
  }
}
