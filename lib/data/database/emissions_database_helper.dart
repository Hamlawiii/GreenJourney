import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:carbon_emission_app/data/database/user_provider.dart';
import 'package:carbon_emission_app/data/bloc/registration_bloc/user_model.dart';

/// A singleton helper class for managing emissions history in SQLite database.
class EmissionsDatabaseHelper {
  static EmissionsDatabaseHelper? _instance;
  late Database _database;

  /// Private constructor for singleton pattern.
  EmissionsDatabaseHelper._privateConstructor();

  /// Returns the singleton instance of [EmissionsDatabaseHelper].
  static Future<EmissionsDatabaseHelper> getInstance() async {
    _instance ??= await _initInstance();
    return _instance!;
  }

  /// Initializes the singleton instance and the database.
  static Future<EmissionsDatabaseHelper> _initInstance() async {
    final instance = EmissionsDatabaseHelper._privateConstructor();
    await instance._initDatabase();
    return instance;
  }

  /// Initializes the SQLite database.
  Future<void> _initDatabase() async {
    try {
      final User loggedInUser = await _getLoggedInUser();
      final String path = join(await getDatabasesPath(), 'emissions_app.db');

      _database = await openDatabase(path, version: 1, onCreate: (db, version) {
        _createTables(db);
      });
    } catch (e) {
      print('Error initializing database: $e');
      rethrow; // Propagate the error up the call stack
    }
  }

  /// Creates the necessary tables if they don't exist.
  Future<void> _createTables(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS emissions_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          emissions_value REAL,
          selected_date TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_info (
          id INTEGER PRIMARY KEY,
          name TEXT,
          age INTEGER,
          country TEXT
        )
      ''');
    } catch (e) {
      print('Error creating tables: $e');
      rethrow; // Propagate the error up the call stack
    }
  }

  /// Inserts a new emissions history record into the database.
  Future<int> insertEmissionsHistory({
    required double emissionsValue,
    required String selectedDate,
  }) async {
    try {
      return await _database.insert('emissions_history', {
        'emissions_value': emissionsValue,
        'selected_date': selectedDate,
      });
    } catch (e) {
      print('Error inserting emissions history: $e');
      rethrow; // Propagate the error up the call stack
    }
  }

  /// Retrieves all emissions history records from the database.
  Future<List<Map<String, dynamic>>> getEmissionsHistory() async {
    try {
      return await _database.query('emissions_history');
    } catch (e) {
      print('Error getting emissions history: $e');
      return []; // Return empty list or handle the error as needed
    }
  }

  /// Retrieves the logged-in user from [UserProvider].
  Future<User> _getLoggedInUser() async {
    try {
      final User? loggedInUser = UserProvider.getLoggedInUser();

      if (loggedInUser == null) {
        throw Exception('No logged-in user found');
      }

      return loggedInUser;
    } catch (e) {
      print('Error getting logged-in user: $e');
      rethrow; // Propagate the error up the call stack
    }
  }

  /// Retrieves user information from the database.
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final User loggedInUser = await _getLoggedInUser();
      final List<Map<String, dynamic>> result = await _database.query(
        'user_info',
        where: 'id = ?',
        whereArgs: [loggedInUser.id],
      );
      if (result.isNotEmpty) {
        return result.first;
      }
      return {};
    } catch (e) {
      print('Error getting user info: $e');
      return {};
    }
  }
}
