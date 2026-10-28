import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/activity.dart';
import '../models/transport.dart';
import '../models/waste.dart';
import '../models/energy.dart';
import '../models/goal.dart';
import '../models/user.dart';

class DatabaseService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // =========================
  // ACTIVITIES
  // =========================

  Future<int> addActivity(Activity activity) async {
    final db = await _databaseHelper.database;

    return await db.insert(
      'activities',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Activity>> getActivities() async {
    final db = await _databaseHelper.database;

    final result = await db.query('activities', orderBy: 'id DESC');

    return result.map((map) => Activity.fromMap(map)).toList();
  }

  Future<int> updateActivity(Activity activity) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> deleteActivity(int id) async {
    final db = await _databaseHelper.database;

    return await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  // =========================
  // TRANSPORT
  // =========================

  Future<int> addTransport(Transport transport) async {
    final db = await _databaseHelper.database;

    return await db.insert(
      'transport',
      transport.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Transport>> getTransport() async {
    final db = await _databaseHelper.database;

    final result = await db.query('transport', orderBy: 'id DESC');

    return result.map((map) => Transport.fromMap(map)).toList();
  }

  Future<int> deleteTransport(int id) async {
    final db = await _databaseHelper.database;

    return await db.delete('transport', where: 'id = ?', whereArgs: [id]);
  }

  // =========================
  // WASTE
  // =========================

  Future<int> addWaste(Waste waste) async {
    final db = await _databaseHelper.database;

    return await db.insert(
      'waste',
      waste.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Waste>> getWaste() async {
    final db = await _databaseHelper.database;

    final result = await db.query('waste', orderBy: 'id DESC');

    return result.map((map) => Waste.fromMap(map)).toList();
  }

  Future<int> deleteWaste(int id) async {
    final db = await _databaseHelper.database;

    return await db.delete('waste', where: 'id = ?', whereArgs: [id]);
  }

  // =========================
  // ENERGY
  // =========================

  Future<int> addEnergy(Energy energy) async {
    final db = await _databaseHelper.database;

    return await db.insert(
      'energy',
      energy.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Energy>> getEnergy() async {
    final db = await _databaseHelper.database;

    final result = await db.query('energy', orderBy: 'id DESC');

    return result.map((map) => Energy.fromMap(map)).toList();
  }

  Future<int> deleteEnergy(int id) async {
    final db = await _databaseHelper.database;

    return await db.delete('energy', where: 'id = ?', whereArgs: [id]);
  }

  // =========================
  // GOALS
  // =========================

  Future<int> addGoal(Goal goal) async {
    final db = await _databaseHelper.database;

    return await db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Goal>> getGoals() async {
    final db = await _databaseHelper.database;

    final result = await db.query('goals', orderBy: 'id DESC');

    return result.map((map) => Goal.fromMap(map)).toList();
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await _databaseHelper.database;

    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  // =========================
  // USERS
  // =========================

  Future<int> registerUser(User user) async {
    final db = await _databaseHelper.database;

    // Check whether this email is already registered.
    final existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [user.email],
      limit: 1,
    );

    // Email already exists.
    // Return 0 instead of throwing a SQLite UNIQUE constraint error.
    if (existingUser.isNotEmpty) {
      return 0;
    }

    // New email → create the account.
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // =========================
  // LOGIN
  // =========================

  Future<User?> loginUser(String email, String password) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }

    return null;
  }

  // =========================
  // GET ALL REGISTERED USERS
  // =========================

  Future<List<User>> getUsers() async {
    final db = await _databaseHelper.database;

    final result = await db.query('users', orderBy: 'id DESC');

    return result.map((map) => User.fromMap(map)).toList();
  }
}
