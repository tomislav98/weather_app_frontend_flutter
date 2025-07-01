import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'weather.db');

    return await openDatabase(dbPath, version: 2, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cities(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city TEXT NOT NULL,
        country TEXT NOT NULL,
        UNIQUE(city, country)
      )
    ''');

    // Insert default city: Vatican
    await db.insert('cities', {
      'city': 'Vatican City',
      'country': 'Vatican',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<Map<String, dynamic>?> getCity(String cityName, String country) async {
    final db = await database;

    final result = await db.query(
      'cities',
      where: 'city = ? AND country = ?',
      whereArgs: [cityName, country],
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertCity(String cityName, String country) async {
    final db = await database;

    return await db.insert('cities', {
      'city': cityName,
      'country': country,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> deleteCity(String cityName, String country) async {
    final db = await database;

    return await db.delete(
      'cities',
      where: 'city = ? AND country = ?',
      whereArgs: [cityName, country],
    );
  }

  Future<List<Map<String, dynamic>>> getAllCities() async {
    final db = await database;

    return await db.query('cities', orderBy: 'id DESC');
  }
}
