import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wasabi/models/widget_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('wasabi.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE widgets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        prompt TEXT NOT NULL,
        json_spec TEXT NOT NULL,
        background_color TEXT,
        size TEXT NOT NULL,
        theme TEXT,
        created_at INTEGER NOT NULL,
        use_count INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> createWidget(WidgetModel widget) async {
    final db = await instance.database;
    await db.insert('widgets', widget.toMap());
  }

  Future<WidgetModel?> getWidget(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'widgets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return WidgetModel.fromMap(maps.first);
  }

  Future<List<WidgetModel>> getAllWidgets() async {
    final db = await instance.database;
    final maps = await db.query(
      'widgets',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => WidgetModel.fromMap(map)).toList();
  }

  Future<void> updateWidget(WidgetModel widget) async {
    final db = await instance.database;
    await db.update(
      'widgets',
      widget.toMap(),
      where: 'id = ?',
      whereArgs: [widget.id],
    );
  }

  Future<void> deleteWidget(String id) async {
    final db = await instance.database;
    await db.delete(
      'widgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementUseCount(String id) async {
    final db = await instance.database;
    await db.rawUpdate(
      'UPDATE widgets SET use_count = use_count + 1 WHERE id = ?',
      [id],
    );
  }

  Future<void> clearAllWidgets() async {
    final db = await instance.database;
    await db.delete('widgets');
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
