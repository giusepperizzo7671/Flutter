import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// DbHelper è una classe singleton che gestisce il database SQLite.
// Il pattern singleton garantisce che esista una sola istanza del database
// in tutta l'applicazione, evitando conflitti e sprechi di risorse
class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _database;

  // getter che restituisce il database, inizializzandolo se necessario.
  // è async perché aprire un database è un'operazione che richiede tempo
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // getDatabasesPath restituisce il percorso della cartella dei database
    final dbPath = await getDatabasesPath();

    // join costruisce il percorso completo del file database
    final path = join(dbPath, 'note_immagini.db');

    return await openDatabase(
      path,
      version: 9,
      onCreate: (db, version) async {
        // tabella per le città aggiunte dall'utente.
        // image_name può contenere un percorso assoluto (galleria)
        // oppure un nome file (asset dell'app)
        await db.execute('''
          CREATE TABLE citta (
            id TEXT PRIMARY KEY NOT NULL,
            name TEXT NOT NULL,
            country TEXT NOT NULL,
            is_visited INTEGER NOT NULL DEFAULT 0,
            image_name TEXT,
            note TEXT
          )
        ''');

        // tabella per le note delle card città (chiave: city id)
        await db.execute('''
          CREATE TABLE note (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            immagine TEXT UNIQUE NOT NULL,
            testo TEXT NOT NULL
          )
        ''');

        // tabella per lo stato visitata/non visitata di ogni città.
        // SQLite non ha boolean: usa 1 per true e 0 per false
        await db.execute('''
          CREATE TABLE citta_stato (
            id TEXT PRIMARY KEY NOT NULL,
            is_visited INTEGER NOT NULL
          )
        ''');

        // tabella principale per le immagini della griglia collegate a una città.
        // immagine: nome file asset oppure percorso assoluto dalla galleria
        // percorso: percorso assoluto del file locale se importato dalla galleria.
        //           ha priorità su immagine per la visualizzazione
        // la coppia (city_id, immagine) è univoca per evitare duplicati
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
            UNIQUE(city_id, immagine)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // onUpgrade viene chiamato quando la versione del db aumenta.
        // aggiunge le nuove tabelle e colonne senza cancellare i dati esistenti
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS citta_stato (
              id TEXT PRIMARY KEY NOT NULL,
              is_visited INTEGER NOT NULL
            )
          ''');
        }
        if (oldVersion < 6) {
          // ricrea la tabella immagini_citta con tutti i campi aggiornati
          await db.execute('DROP TABLE IF EXISTS immagini_citta');
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
              UNIQUE(city_id, immagine)
            )
          ''');
        }
        if (oldVersion < 7) {
          // aggiunge la tabella città per la persistenza delle città aggiunte
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
        if (oldVersion < 8) {
          // aggiunge la colonna percorso se non esiste già.
          // il try-catch gestisce il caso in cui la colonna esista già
          try {
            await db.execute(
              'ALTER TABLE immagini_citta ADD COLUMN percorso TEXT',
            );
          } catch (_) {
            // la colonna esiste già, ignora l'errore silenziosamente
          }
        }
        if (oldVersion < 9) {
          // versione 9: nessuna modifica strutturale,
          // usata per forzare la riesecuzione di onUpgrade
          // su dispositivi con versioni intermedie del db
        }
      },
    );
  }

  // ── CITTÀ ─────────────────────────────────────────────────────────────────

  // salva una nuova città nel database.
  // INSERT OR REPLACE sovrascrive se esiste già una città con lo stesso id
  Future<void> salvaCitta({
    required String id,
    required String name,
    required String country,
    required bool isVisited,
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

  // recupera tutte le città salvate dall'utente nel database.
  // ordinate per nome in ordine alfabetico
  Future<List<Map<String, dynamic>>> leggiCitta() async {
    final db = await database;
    return await db.query('citta', orderBy: 'name ASC');
  }

  // elimina una città dal database in base al suo id
  Future<void> eliminaCitta(String id) async {
    final db = await database;
    await db.delete('citta', where: 'id = ?', whereArgs: [id]);
  }

  // aggiorna lo stato isVisited di una città nel database
  Future<void> aggiornaIsVisited(String id, bool isVisited) async {
    final db = await database;
    await db.update(
      'citta',
      {'is_visited': isVisited ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // aggiorna la nota di una città nel database
  Future<void> aggiornaNotaCitta(String id, String nota) async {
    final db = await database;
    await db.update('citta', {'note': nota}, where: 'id = ?', whereArgs: [id]);
  }

  // ── NOTE CARD CITTÀ ───────────────────────────────────────────────────────

  // salva o aggiorna una nota per una specifica card città.
  // INSERT OR REPLACE sovrascrive la nota se esiste già per quella chiave
  Future<void> salvaNota(String immagine, String testo) async {
    final db = await database;
    await db.rawInsert(
      'INSERT OR REPLACE INTO note (immagine, testo) VALUES (?, ?)',
      [immagine, testo],
    );
  }

  // recupera la nota salvata per una specifica card città.
  // restituisce null se non esiste nessuna nota per quella chiave
  Future<String?> leggiNota(String immagine) async {
    final db = await database;
    final risultati = await db.query(
      'note',
      where: 'immagine = ?',
      whereArgs: [immagine],
    );
    if (risultati.isEmpty) return null;
    return risultati.first['testo'] as String?;
  }

  // elimina la nota per una specifica card città
  Future<void> eliminaNota(String immagine) async {
    final db = await database;
    await db.delete('note', where: 'immagine = ?', whereArgs: [immagine]);
  }

  // ── IS VISITED ────────────────────────────────────────────────────────────

  // salva lo stato visitata/non visitata per una città.
  // aggiorna sia la tabella citta_stato che la tabella citta
  Future<void> salvaIsVisited(String cityId, bool isVisited) async {
    final db = await database;
    // salva nella tabella citta_stato
    await db.rawInsert(
      'INSERT OR REPLACE INTO citta_stato (id, is_visited) VALUES (?, ?)',
      [cityId, isVisited ? 1 : 0],
    );
    // aggiorna anche nella tabella città se la città esiste
    await db.update(
      'citta',
      {'is_visited': isVisited ? 1 : 0},
      where: 'id = ?',
      whereArgs: [cityId],
    );
  }

  // recupera lo stato visitata/non visitata per una città.
  // restituisce null se non è mai stato salvato
  Future<bool?> leggiIsVisited(String cityId) async {
    final db = await database;
    final risultati = await db.query(
      'citta_stato',
      where: 'id = ?',
      whereArgs: [cityId],
    );
    if (risultati.isEmpty) return null;
    // converte il valore intero (1/0) in boolean
    return risultati.first['is_visited'] == 1;
  }

  // ── IMMAGINI GRIGLIA (da CSV) ─────────────────────────────────────────────

  // salva o aggiorna un'immagine con tutti i campi del file CSV.
  // il CSV usa ; come separatore per evitare conflitti con le virgole
  // nei campi come coordinate o "Bus 6, 9, 30".
  // percorso è opzionale: se presente indica un file locale dalla galleria
  Future<void> salvaImmagineGriglia({
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
    await db.rawInsert(
      '''INSERT OR REPLACE INTO immagini_citta
         (city_id, immagine, percorso, latitudine, longitudine, tipo,
          destinazione, orari, ticket, hh, zona, gg, metro_bus, note)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        cityId,
        immagine,
        percorso,
        latitudine,
        longitudine,
        tipo,
        destinazione,
        orari,
        ticket,
        hh,
        zona,
        gg,
        metroBus,
        note,
      ],
    );
  }

  // ── IMMAGINI GRIGLIA (dalla galleria del telefono) ────────────────────────

  // salva il percorso assoluto di un'immagine importata dalla galleria.
  // usa il percorso sia come immagine che come percorso così ImageCard
  // riconosce che è un file locale (inizia con /).
  // INSERT OR IGNORE evita duplicati senza generare errori
  Future<void> salvaImmagineLocale({
    required String cityId,
    required String percorso,
  }) async {
    final db = await database;
    await db.rawInsert(
      '''INSERT OR IGNORE INTO immagini_citta
         (city_id, immagine, percorso)
         VALUES (?, ?, ?)''',
      [cityId, percorso, percorso],
    );
  }

  // recupera tutte le immagini con i loro dati per una specifica città.
  // restituisce una lista di Map con tutti i campi della tabella
  Future<List<Map<String, dynamic>>> leggiImmaginiCitta(String cityId) async {
    final db = await database;
    return await db.query(
      'immagini_citta',
      where: 'city_id = ?',
      whereArgs: [cityId],
    );
  }

  // recupera i dati di una singola immagine per una specifica città
  Future<Map<String, dynamic>?> leggiDatiImmagine(
    String cityId,
    String immagine,
  ) async {
    final db = await database;
    final risultati = await db.query(
      'immagini_citta',
      where: 'city_id = ? AND immagine = ?',
      whereArgs: [cityId, immagine],
    );
    if (risultati.isEmpty) return null;
    return risultati.first;
  }

  // aggiorna solo la nota di una specifica immagine per una città.
  // usato dalla modale di ImageCard dopo che l'utente salva il testo
  Future<void> aggiornaNota(String cityId, String immagine, String nota) async {
    final db = await database;
    await db.update(
      'immagini_citta',
      {'note': nota},
      where: 'city_id = ? AND immagine = ?',
      whereArgs: [cityId, immagine],
    );
  }

  // aggiorna il percorso dell'immagine locale per una specifica scheda.
  // chiamato quando l'utente seleziona un'immagine dalla galleria
  // direttamente su una singola ImageCard tramite il bottone edit
  Future<void> aggiornaPercorsoImmagine(
    String cityId,
    String immagine,
    String percorso,
  ) async {
    final db = await database;
    await db.update(
      'immagini_citta',
      {'percorso': percorso},
      where: 'city_id = ? AND immagine = ?',
      whereArgs: [cityId, immagine],
    );
  }

  // elimina una singola immagine dalla griglia di una città
  Future<void> eliminaImmagine(String cityId, String immagine) async {
    final db = await database;
    await db.delete(
      'immagini_citta',
      where: 'city_id = ? AND immagine = ?',
      whereArgs: [cityId, immagine],
    );
  }

  // elimina tutte le immagini della griglia di una città.
  // usato quando si vuole resettare completamente la griglia di una città
  Future<void> eliminaTutteImmaginiCitta(String cityId) async {
    final db = await database;
    await db.delete(
      'immagini_citta',
      where: 'city_id = ?',
      whereArgs: [cityId],
    );
  }
}
