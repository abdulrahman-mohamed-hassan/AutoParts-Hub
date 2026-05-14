import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/shop.dart';
import '../models/part_item.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();

  static Database? _database;

  LocalDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('autoparts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;
    if (kIsWeb) {
      path = filePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create shops table
    await db.execute('''
    CREATE TABLE shops (
      id TEXT PRIMARY KEY,
      name TEXT,
      imageUrl TEXT
    )
    ''');

    // Create users table
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      role TEXT NOT NULL
    )
    ''');

    // Create parts table
    await db.execute('''
    CREATE TABLE parts (
      id TEXT PRIMARY KEY,
      shopId TEXT,
      name TEXT,
      price REAL,
      description TEXT,
      imageUrl TEXT,
      category TEXT
    )
    ''');

    await insertExampleData(db);
  }

  Future<void> insertExampleData(Database db) async {
    // Insert example shops
    await db.insert(
      'shops',
      {
        'id': 's1',
        'name': 'Elite Engine Parts',
        'imageUrl': 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=500&q=80'
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'shops',
      {
        'id': 's2',
        'name': 'Brake & Suspension Pro',
        'imageUrl': 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=500&q=80'
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'shops',
      {
        'id': 's3',
        'name': 'Professional Mechanic Hub',
        'imageUrl': 'https://images.unsplash.com/photo-1487754180451-c456f719a1fc?w=500&q=80'
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert example parts
    final List<Map<String, dynamic>> parts = [
      {
        'id': 'p1',
        'shopId': 's1',
        'name': 'Brembo Brake Pads',
        'price': 120.0,
        'description': 'High-performance ceramic brake pads for superior stopping power.',
        'imageUrl': 'https://images.unsplash.com/photo-1517524008697-84bbe3c3fd98?w=500&q=80',
        'category': 'Brakes'
      },
      {
        'id': 'p2',
        'shopId': 's1',
        'name': 'Castrol Edge 5W-30',
        'price': 45.0,
        'description': 'Fully synthetic engine oil for maximum performance.',
        'imageUrl': 'https://images.unsplash.com/photo-1620939511593-3ef7682976be?w=500&q=80',
        'category': 'Engine'
      },
      {
        'id': 'p3',
        'shopId': 's2',
        'name': 'Bosch Spark Plugs',
        'price': 15.0,
        'description': 'Double Iridium spark plugs for longer life and better ignition.',
        'imageUrl': 'https://images.unsplash.com/photo-1589148625905-045330835f11?w=500&q=80',
        'category': 'Electrical'
      },
      {
        'id': 'p4',
        'shopId': 's3',
        'name': 'Full Engine Diagnostic',
        'price': 80.0,
        'description': 'Comprehensive computer scan and manual inspection.',
        'imageUrl': 'https://images.unsplash.com/photo-1530046339160-ce3e530c7d2f?w=500&q=80',
        'category': 'Service'
      },
    ];

    for (var part in parts) {
      await db.insert('parts', part, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Insert example users
    await db.insert(
      'users',
      {
        'email': 'user@example.com',
        'password': 'password123',
        'role': 'user',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'users',
      {
        'email': 'admin@example.com',
        'password': 'admin123',
        'role': 'admin',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Shop>> getShops() async {
    final db = await database;
    final result = await db.query('shops');
    return result.map((json) => Shop.fromJson(json)).toList();
  }

  Future<bool> register(String email, String password, String role) async {
    final db = await database;
    try {
      await db.insert(
        'users',
        {
          'email': email,
          'password': password,
          'role': role,
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<PartItem>> getParts(String shopId) async {
    final db = await database;
    final result = await db.query(
      'parts',
      where: 'shopId = ?',
      whereArgs: [shopId],
    );
    return result.map((json) => PartItem.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}