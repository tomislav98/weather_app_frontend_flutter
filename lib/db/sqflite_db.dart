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

    return await openDatabase(dbPath, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cities(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city TEXT UNIQUE
      )
    ''');
    // Insert default city: Vatican
    await db.insert(
      'cities',
      {'city': 'Vatican'},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Just in case
    );
  }

  Future<Map<String, dynamic>?> getCityByName(String cityName) async {
    final db = await database; // this calls the getter to get the DB instance

    final result = await db.query(
      'cities',
      where: 'city = ?',
      whereArgs: [cityName],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first; // returns a Map with the city's data
    } else {
      return null; // city not found
    }
  }

  Future<int> insertCity(String cityName) async {
    final db = await database; // get the database instance

    return await db.insert(
      'cities',
      {'city': cityName},
      conflictAlgorithm:
          ConflictAlgorithm
              .replace, // optional: replaces if city already exists
    );
  }

  Future<int> deleteCityByName(String cityName) async {
    final db = await database; // get the database instance

    return await db.delete('cities', where: 'city = ?', whereArgs: [cityName]);
  }

  Future<List<String>> getAllCities() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'cities',
      orderBy: 'id DESC', // 👈 newest first
    );

    // Extract just the city names into a List<String>
    return result.map((row) => row['city'] as String).toList();
  }
}
