import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'partidas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE partidas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT UNIQUE,
            victoriasX INTEGER,
            victoriasO INTEGER,
            empates INTEGER,
            tablero TEXT,
            turno TEXT
          )
        ''');
      },
    );
  }

  Future<void> guardarPartida(String nombre, int victoriasX, int victoriasO, int empates, List<String> tablero, String turno) async {
    final db = await database;
    await db.insert(
      'partidas',
      {
        'nombre': nombre,
        'victoriasX': victoriasX,
        'victoriasO': victoriasO,
        'empates': empates,
        'tablero': tablero.join(','), // Guarda el tablero como una cadena separada por comas
        'turno': turno, // Guarda el turno actual
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> obtenerEstadisticas(String nombre) async {
    final db = await database;
    final result = await db.query(
      'partidas',
      where: 'nombre = ?',
      whereArgs: [nombre],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final datos = result.first;
      return {
        'victoriasX': datos['victoriasX'],
        'victoriasO': datos['victoriasO'],
        'empates': datos['empates'],
        'tablero': (datos['tablero'] as String).split(','),
        'turno': datos['turno'], // Cargar el turno
      };
    }
    return {};
  }

  Future<List<String>> getPartidasGuardadas() async {
    final db = await database;
    final result = await db.query('partidas', columns: ['nombre']);
    return result.map((row) => row['nombre'] as String).toList();
  }
}