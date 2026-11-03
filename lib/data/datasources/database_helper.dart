import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/workout_log.dart';
import '../models/readiness_checkin.dart';
import '../models/session_change.dart';
import '../models/body_log.dart';
import '../models/posture_log.dart';
import '../models/user_settings.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fitness_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Workout logs
    await db.execute('''
      CREATE TABLE workout_logs (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        session_id TEXT NOT NULL,
        session_type TEXT NOT NULL,
        notes TEXT,
        rpe INTEGER,
        run_distance_km REAL,
        run_duration_seconds INTEGER,
        avg_pace_seconds INTEGER,
        created_at TEXT NOT NULL
      )
    ''');

    // Sets logged
    await db.execute('''
      CREATE TABLE set_logs (
        id TEXT PRIMARY KEY,
        workout_log_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        exercise_name TEXT NOT NULL,
        set_number INTEGER NOT NULL,
        target_reps INTEGER NOT NULL,
        target_weight_kg REAL NOT NULL,
        completed_reps INTEGER NOT NULL,
        completed_weight_kg REAL NOT NULL,
        is_completed INTEGER NOT NULL,
        FOREIGN KEY (workout_log_id) REFERENCES workout_logs (id) ON DELETE CASCADE
      )
    ''');

    // Readiness check-ins
    await db.execute('''
      CREATE TABLE readiness_checkins (
        date TEXT PRIMARY KEY,
        sleep_hours REAL NOT NULL,
        leg_soreness INTEGER NOT NULL,
        pain TEXT NOT NULL,
        stress INTEGER NOT NULL,
        note TEXT,
        suggestion TEXT
      )
    ''');

    // Session changes (swaps and skips)
    await db.execute('''
      CREATE TABLE session_changes (
        date TEXT PRIMARY KEY,
        original_session_id TEXT NOT NULL,
        replacement_session_id TEXT,
        replacement_type TEXT,
        is_skipped INTEGER NOT NULL,
        reason TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Body logs
    await db.execute('''
      CREATE TABLE body_logs (
        date TEXT PRIMARY KEY,
        weight_kg REAL,
        waist_cm REAL,
        photo_path TEXT,
        note TEXT
      )
    ''');

    // Posture logs
    await db.execute('''
      CREATE TABLE posture_logs (
        date TEXT PRIMARY KEY,
        routine_done INTEGER NOT NULL,
        minutes INTEGER NOT NULL
      )
    ''');

    // User settings
    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        plan_variant TEXT NOT NULL,
        race_date TEXT NOT NULL,
        finals_start TEXT NOT NULL,
        finals_end TEXT NOT NULL,
        units TEXT NOT NULL,
        theme_mode TEXT NOT NULL,
        reminder_sunday_export INTEGER NOT NULL,
        reminder_morning INTEGER NOT NULL,
        test_5k_time TEXT
      )
    ''');

    // Insert initial default settings
    await db.insert('app_settings', {
      'id': 1,
      'plan_variant': 'JAN_3',
      'race_date': '2027-01-03',
      'finals_start': '2026-12-01',
      'finals_end': '2026-12-15',
      'units': 'metric',
      'theme_mode': 'system',
      'reminder_sunday_export': 1,
      'reminder_morning': 0,
      'test_5k_time': null,
    });
  }

  // --- Workout Log Operations ---
  Future<void> saveWorkoutLog(WorkoutLog log) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'workout_logs',
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // Remove old sets if re-logging
      await txn.delete('set_logs', where: 'workout_log_id = ?', whereArgs: [log.id]);
      for (final s in log.sets) {
        await txn.insert('set_logs', s.toMap());
      }
    });
  }

  Future<WorkoutLog?> getWorkoutLogForDate(String date) async {
    final db = await database;
    final results = await db.query(
      'workout_logs',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (results.isEmpty) return null;
    final logMap = results.first;
    final logId = logMap['id'] as String;

    final setResults = await db.query(
      'set_logs',
      where: 'workout_log_id = ?',
      whereArgs: [logId],
      orderBy: 'exercise_id ASC, set_number ASC',
    );
    final sets = setResults.map((m) => SetLog.fromMap(m)).toList();
    return WorkoutLog.fromMap(logMap, sets);
  }

  Future<List<WorkoutLog>> getAllWorkoutLogs() async {
    final db = await database;
    final results = await db.query('workout_logs', orderBy: 'date DESC');
    final logs = <WorkoutLog>[];
    for (final m in results) {
      final logId = m['id'] as String;
      final setResults = await db.query(
        'set_logs',
        where: 'workout_log_id = ?',
        whereArgs: [logId],
        orderBy: 'exercise_id ASC, set_number ASC',
      );
      final sets = setResults.map((s) => SetLog.fromMap(s)).toList();
      logs.add(WorkoutLog.fromMap(m, sets));
    }
    return logs;
  }

  // --- Readiness Operations ---
  Future<void> saveReadiness(ReadinessCheckIn checkIn) async {
    final db = await database;
    await db.insert(
      'readiness_checkins',
      checkIn.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ReadinessCheckIn?> getReadinessForDate(String date) async {
    final db = await database;
    final res = await db.query('readiness_checkins', where: 'date = ?', whereArgs: [date]);
    if (res.isEmpty) return null;
    return ReadinessCheckIn.fromMap(res.first);
  }

  Future<List<ReadinessCheckIn>> getAllReadiness() async {
    final db = await database;
    final res = await db.query('readiness_checkins', orderBy: 'date DESC');
    return res.map((m) => ReadinessCheckIn.fromMap(m)).toList();
  }

  // --- Session Changes (Swap & Skip) ---
  Future<void> saveSessionChange(SessionChange change) async {
    final db = await database;
    await db.insert(
      'session_changes',
      change.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<SessionChange?> getSessionChangeForDate(String date) async {
    final db = await database;
    final res = await db.query('session_changes', where: 'date = ?', whereArgs: [date]);
    if (res.isEmpty) return null;
    return SessionChange.fromMap(res.first);
  }

  Future<List<SessionChange>> getAllSessionChanges() async {
    final db = await database;
    final res = await db.query('session_changes', orderBy: 'date DESC');
    return res.map((m) => SessionChange.fromMap(m)).toList();
  }

  // --- Body Logs ---
  Future<void> saveBodyLog(BodyLog log) async {
    final db = await database;
    await db.insert(
      'body_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<BodyLog?> getBodyLogForDate(String date) async {
    final db = await database;
    final res = await db.query('body_logs', where: 'date = ?', whereArgs: [date]);
    if (res.isEmpty) return null;
    return BodyLog.fromMap(res.first);
  }

  Future<List<BodyLog>> getAllBodyLogs() async {
    final db = await database;
    final res = await db.query('body_logs', orderBy: 'date DESC');
    return res.map((m) => BodyLog.fromMap(m)).toList();
  }

  // --- Posture Logs ---
  Future<void> savePostureLog(PostureLog log) async {
    final db = await database;
    await db.insert(
      'posture_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PostureLog?> getPostureLogForDate(String date) async {
    final db = await database;
    final res = await db.query('posture_logs', where: 'date = ?', whereArgs: [date]);
    if (res.isEmpty) return null;
    return PostureLog.fromMap(res.first);
  }

  Future<List<PostureLog>> getAllPostureLogs() async {
    final db = await database;
    final res = await db.query('posture_logs', orderBy: 'date DESC');
    return res.map((m) => PostureLog.fromMap(m)).toList();
  }

  // --- User Settings ---
  Future<UserSettings> getSettings() async {
    final db = await database;
    final res = await db.query('app_settings', where: 'id = 1');
    if (res.isEmpty) return const UserSettings();
    return UserSettings.fromMap(res.first);
  }

  Future<void> saveSettings(UserSettings settings) async {
    final db = await database;
    await db.update(
      'app_settings',
      settings.toMap(),
      where: 'id = 1',
    );
  }

  // Clear or Restore Database for Backup Import
  Future<void> restoreDatabase({
    required List<WorkoutLog> logs,
    required List<ReadinessCheckIn> readiness,
    required List<SessionChange> changes,
    required List<BodyLog> bodyLogs,
    required List<PostureLog> postureLogs,
    required UserSettings settings,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('set_logs');
      await txn.delete('workout_logs');
      await txn.delete('readiness_checkins');
      await txn.delete('session_changes');
      await txn.delete('body_logs');
      await txn.delete('posture_logs');

      await txn.update('app_settings', settings.toMap(), where: 'id = 1');

      for (final l in logs) {
        await txn.insert('workout_logs', l.toMap());
        for (final s in l.sets) {
          await txn.insert('set_logs', s.toMap());
        }
      }
      for (final r in readiness) {
        await txn.insert('readiness_checkins', r.toMap());
      }
      for (final c in changes) {
        await txn.insert('session_changes', c.toMap());
      }
      for (final b in bodyLogs) {
        await txn.insert('body_logs', b.toMap());
      }
      for (final p in postureLogs) {
        await txn.insert('posture_logs', p.toMap());
      }
    });
  }
}
