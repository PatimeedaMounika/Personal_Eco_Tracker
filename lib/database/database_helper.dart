import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // =========================
  // DATABASE GETTER
  // =========================

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('personal_eco_tracker.db');

    return _database!;
  }

  // =========================
  // INITIALIZE DATABASE
  // =========================

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // =========================
  // CREATE DATABASE
  // =========================

  Future<void> _createDB(Database db, int version) async {
    // =========================
    // USERS TABLE
    // =========================

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // =========================
    // ACTIVITIES TABLE
    // =========================

    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_type TEXT NOT NULL,
        description TEXT,
        co2_saved REAL DEFAULT 0,
        date TEXT NOT NULL
      )
    ''');

    // =========================
    // TRANSPORT TABLE
    // =========================

    await db.execute('''
      CREATE TABLE transport (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mode TEXT NOT NULL,
        distance REAL NOT NULL,
        co2_emission REAL DEFAULT 0,
        date TEXT NOT NULL
      )
    ''');

    // =========================
    // WASTE TABLE
    // =========================

    await db.execute('''
      CREATE TABLE waste (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        waste_type TEXT NOT NULL,
        quantity REAL NOT NULL,
        recycled INTEGER DEFAULT 0,
        date TEXT NOT NULL
      )
    ''');

    // =========================
    // ENERGY TABLE
    // =========================

    await db.execute('''
      CREATE TABLE energy (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        appliance TEXT NOT NULL,
        usage_hours REAL NOT NULL,
        estimated_units REAL DEFAULT 0,
        date TEXT NOT NULL
      )
    ''');

    // =========================
    // GOALS TABLE
    // =========================

    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        target REAL NOT NULL,
        progress REAL DEFAULT 0,
        deadline TEXT
      )
    ''');
  }

  // =========================
  // DATABASE UPGRADE
  // =========================

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Version 1 → Version 2
    //
    // If an old database already exists,
    // add the users table.
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          full_name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');
    }
  }

  // =========================
  // CLOSE DATABASE
  // =========================

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
