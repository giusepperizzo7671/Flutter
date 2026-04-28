import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// ===========================================================================
// DbHelper — gestore unico del database SQLite dell'app my_cities.
// Pattern Singleton: esiste UN SOLO addetto al magazzino in tutta l'app.
// ===========================================================================

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'note_immagini.db');
    return await openDatabase(
      path,
      version: 11,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // --------------------------------------------------------------------------
  // onCreate — crea tutte le tabelle da zero
  // --------------------------------------------------------------------------
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE citta (
        id         TEXT PRIMARY KEY NOT NULL,
        name       TEXT NOT NULL,
        country    TEXT NOT NULL,
        is_visited INTEGER NOT NULL DEFAULT 0,
        image_name TEXT,
        note       TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE citta_stato (
        id         TEXT PRIMARY KEY NOT NULL,
        is_visited INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE note (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        immagine TEXT UNIQUE NOT NULL,
        testo    TEXT NOT NULL
      )
    ''');

    // tabella principale schede griglia.
    // is_visitata: 1 = posto visitato → card semitrasparente, 0 = non visitato
    await db.execute('''
      CREATE TABLE immagini_citta (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        city_id      TEXT    NOT NULL,
        immagine     TEXT    NOT NULL,
        percorso     TEXT,
        latitudine   REAL,
        longitudine  REAL,
        tipo         TEXT,
        destinazione TEXT,
        orari        TEXT,
        ticket       TEXT,
        hh           TEXT,
        zona         TEXT,
        gg           TEXT,
        metro_bus    TEXT,
        note         TEXT,
        is_visitata  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_immagini_city_id ON immagini_citta (city_id)',
    );
  }

  // --------------------------------------------------------------------------
  // onUpgrade — migrazioni incrementali (non perdono dati esistenti)
  // --------------------------------------------------------------------------
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS citta_stato (
          id TEXT PRIMARY KEY NOT NULL,
          is_visited INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS immagini_citta (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          city_id TEXT NOT NULL,
          immagine TEXT NOT NULL,
          percorso TEXT,
          latitudine REAL,
          longitudine REAL,
          tipo TEXT,
          destinazione TEXT,
          orari TEXT,
          ticket TEXT,
          hh TEXT,
          zona TEXT,
          gg TEXT,
          metro_bus TEXT,
          note TEXT,
          is_visitata INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }

    if (oldVersion < 5) {
      for (final col in [
        'tipo',
        'destinazione',
        'orari',
        'ticket',
        'hh',
        'zona',
        'gg',
        'metro_bus',
        'note',
      ]) {
        await _addCol(db, 'immagini_citta', col, 'TEXT');
      }
    }

    if (oldVersion < 6) {
      await _addCol(db, 'immagini_citta', 'percorso', 'TEXT');
    }

    if (oldVersion < 7) {
      await _addCol(db, 'citta', 'note', 'TEXT');
    }

    if (oldVersion < 8) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS citta (
          id TEXT PRIMARY KEY NOT NULL,
          name TEXT NOT NULL,
          country TEXT NOT NULL,
          is_visited INTEGER NOT NULL DEFAULT 0,
          image_name TEXT,
          note TEXT
        )
      ''');
    }

    if (oldVersion < 9) {
      // rimuove eventuale UNIQUE(city_id, immagine) se presente
      final res = await db.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name='immagini_citta'",
      );
      if (res.isNotEmpty) {
        final sql = res.first['sql']?.toString() ?? '';
        if (sql.contains('UNIQUE(city_id')) {
          await db.execute(
            'ALTER TABLE immagini_citta RENAME TO immagini_citta_old',
          );
          await db.execute('''
            CREATE TABLE immagini_citta (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              city_id TEXT NOT NULL,
              immagine TEXT NOT NULL,
              percorso TEXT,
              latitudine REAL,
              longitudine REAL,
              tipo TEXT,
              destinazione TEXT,
              orari TEXT,
              ticket TEXT,
              hh TEXT,
              zona TEXT,
              gg TEXT,
              metro_bus TEXT,
              note TEXT,
              is_visitata INTEGER NOT NULL DEFAULT 0
            )
          ''');
          await db.execute(
            'INSERT INTO immagini_citta SELECT *, 0 FROM immagini_citta_old',
          );
          await db.execute('DROP TABLE immagini_citta_old');
        }
      }
    }

    if (oldVersion < 10) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_immagini_city_id ON immagini_citta (city_id)',
      );
    }

    if (oldVersion < 11) {
      // aggiunge il campo is_visitata se non esiste già
      await _addCol(
        db,
        'immagini_citta',
        'is_visitata',
        'INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  // helper: aggiunge colonna solo se mancante (sicuro da chiamare più volte)
  Future<void> _addCol(
    Database db,
    String table,
    String col,
    String type,
  ) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $col $type');
    } catch (_) {
      // colonna già esistente — ignora
    }
  }

  // ==========================================================================
  // CRUD — CITTÀ
  // ==========================================================================

  Future<void> salvacitta({
    required String id,
    required String name,
    required String country,
    bool isVisited = false,
    String? imageName,
    String? note,
  }) async {
    final db = await database;
    await db.rawInsert(
      '''INSERT OR REPLACE INTO citta
         (id, name, country, is_visited, image_name, note)
         VALUES (?, ?, ?, ?, ?, ?)''',
      [id, name, country, isVisited ? 1 : 0, imageName, note],
    );
  }

  Future<List<Map<String, dynamic>>> getTutteCitta() async {
    final db = await database;
    return db.query('citta', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getCitta(String id) async {
    final db = await database;
    final r = await db.query('citta', where: 'id = ?', whereArgs: [id]);
    return r.isEmpty ? null : r.first;
  }

  Future<void> eliminaCitta(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('citta', where: 'id = ?', whereArgs: [id]);
      await txn.delete('citta_stato', where: 'id = ?', whereArgs: [id]);
      await txn.delete('immagini_citta', where: 'city_id = ?', whereArgs: [id]);
    });
  }

  // ==========================================================================
  // CRUD — STATO VISITATA CITTÀ
  // ==========================================================================

  Future<void> salvaIsVisited(String cityId, bool isVisited) async {
    final db = await database;
    await db.rawInsert(
      'INSERT OR REPLACE INTO citta_stato (id, is_visited) VALUES (?, ?)',
      [cityId, isVisited ? 1 : 0],
    );
  }

  Future<bool> leggiIsVisited(String cityId) async {
    final db = await database;
    final r = await db.query(
      'citta_stato',
      where: 'id = ?',
      whereArgs: [cityId],
    );
    if (r.isEmpty) return false;
    return (r.first['is_visited'] as int) == 1;
  }

  // ==========================================================================
  // CRUD — NOTE CITY CARD
  // ==========================================================================

  Future<void> salvaNota(String immagine, String testo) async {
    final db = await database;
    await db.rawInsert(
      'INSERT OR REPLACE INTO note (immagine, testo) VALUES (?, ?)',
      [immagine, testo],
    );
  }

  Future<String?> leggiNota(String immagine) async {
    final db = await database;
    final r = await db.query(
      'note',
      where: 'immagine = ?',
      whereArgs: [immagine],
    );
    return r.isEmpty ? null : r.first['testo'] as String?;
  }

  Future<void> eliminaNota(String immagine) async {
    final db = await database;
    await db.delete('note', where: 'immagine = ?', whereArgs: [immagine]);
  }

  // ==========================================================================
  // CRUD — SCHEDE GRIGLIA
  // ==========================================================================

  // aggiunge UNA scheda — NON cancella mai quelle esistenti
  Future<int> salvaImmagineGriglia({
    required String cityId,
    required String immagine,
    String? percorso,
    double? latitudine,
    double? longitudine,
    String? tipo,
    String? destinazione,
    String? orari,
    String? ticket,
    String? hh,
    String? zona,
    String? gg,
    String? metroBus,
    String? note,
  }) async {
    final db = await database;
    return db.insert('immagini_citta', {
      'city_id': cityId,
      'immagine': immagine,
      'percorso': percorso,
      'latitudine': latitudine,
      'longitudine': longitudine,
      'tipo': tipo,
      'destinazione': destinazione,
      'orari': orari,
      'ticket': ticket,
      'hh': hh,
      'zona': zona,
      'gg': gg,
      'metro_bus': metroBus,
      'note': note,
      'is_visitata': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getImmaginiGriglia(String cityId) async {
    final db = await database;
    return db.query(
      'immagini_citta',
      where: 'city_id = ?',
      whereArgs: [cityId],
      orderBy: 'id ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getTutteImmaginiGriglia() async {
    final db = await database;
    return db.query('immagini_citta', orderBy: 'city_id ASC, id ASC');
  }

  // aggiorna i metadati di una scheda (solo i campi non-null vengono toccati)
  Future<void> aggiornaImmagineGriglia({
    required int id,
    String? percorso,
    double? latitudine,
    double? longitudine,
    String? tipo,
    String? destinazione,
    String? orari,
    String? ticket,
    String? hh,
    String? zona,
    String? gg,
    String? metroBus,
    String? note,
  }) async {
    final db = await database;
    await db.update(
      'immagini_citta',
      {
        if (percorso != null) 'percorso': percorso,
        if (latitudine != null) 'latitudine': latitudine,
        if (longitudine != null) 'longitudine': longitudine,
        if (tipo != null) 'tipo': tipo,
        if (destinazione != null) 'destinazione': destinazione,
        if (orari != null) 'orari': orari,
        if (ticket != null) 'ticket': ticket,
        if (hh != null) 'hh': hh,
        if (zona != null) 'zona': zona,
        if (gg != null) 'gg': gg,
        if (metroBus != null) 'metro_bus': metroBus,
        if (note != null) 'note': note,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // aggiorna SOLO il flag is_visitata di una singola scheda
  Future<void> aggiornaIsVisitataScheda(int id, bool isVisitata) async {
    final db = await database;
    await db.update(
      'immagini_citta',
      {'is_visitata': isVisitata ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // elimina UNA singola scheda — le altre rimangono intatte
  Future<void> eliminaImmagineGriglia(int id) async {
    final db = await database;
    await db.delete('immagini_citta', where: 'id = ?', whereArgs: [id]);
  }

  // elimina TUTTE le schede di una città (solo reset manuale, mai durante import)
  Future<void> eliminaTutteSchedeDiCitta(String cityId) async {
    final db = await database;
    await db.delete(
      'immagini_citta',
      where: 'city_id = ?',
      whereArgs: [cityId],
    );
  }

  Future<int> contaSchedeDiCitta(String cityId) async {
    final db = await database;
    final res = await db.rawQuery(
      'SELECT COUNT(*) as n FROM immagini_citta WHERE city_id = ?',
      [cityId],
    );
    return (res.first['n'] as int?) ?? 0;
  }

  // ==========================================================================
  // UTILITÀ
  // ==========================================================================

  Future<void> chiudi() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> resetDatabase() async {
    final db = await database;
    final path = db.path;
    await chiudi();
    await deleteDatabase(path);
    _database = await _initDatabase();
  }
}
