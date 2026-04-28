import 'package:flutter/material.dart';
import 'package:my_cities/models/city.dart';
import 'package:my_cities/data/cities.dart';
import 'package:my_cities/db_helper.dart';
import 'package:my_cities/widgets/image_card.dart';
import 'package:my_cities/utils/csv_converter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GridScreen extends StatefulWidget {
  const GridScreen({super.key, this.city});

  // city è nullable: se null mostra tutte le immagini di tutte le città,
  // altrimenti mostra solo le immagini della città specifica con i dati dal db
  final City? city;

  @override
  State<GridScreen> createState() => _GridScreenState();
}

class _GridScreenState extends State<GridScreen> {
  final DbHelper _dbHelper = DbHelper();
  final ImagePicker _picker = ImagePicker();

  // lista delle immagini con i relativi dati caricati dal database.
  // usata solo quando si apre GridScreen da una card specifica
  List<Map<String, dynamic>> _immaginiDaDb = [];

  // messaggio di stato mostrato all'utente dopo importazione o aggiunta foto
  String _messaggioImport = '';

  // indica se stiamo caricando i dati dal db
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // carica i dati dal database se è stata passata una città specifica.
    // altrimenti non serve caricare nulla, usiamo cities.dart
    if (widget.city != null) {
      _caricaImmaginiDaDb();
    } else {
      _loading = false;
    }
  }

  // carica tutte le immagini con i dati salvati per questa città dal database
  Future<void> _caricaImmaginiDaDb() async {
    try {
      final immagini = await _dbHelper.leggiImmaginiCitta(widget.city!.id);
      setState(() {
        _immaginiDaDb = immagini;
        _loading = false;
      });
    } catch (e, stack) {
      print('ERRORE _caricaImmaginiDaDb: $e');
      print('STACK: $stack');
      setState(() => _loading = false);
    }
  }

  // apre la galleria del telefono e permette di selezionare più immagini.
  // i percorsi assoluti vengono salvati nel database collegati alla città.
  // il percorso viene usato sia come chiave immagine che come percorso locale,
  // così ImageCard._buildImmagine riconosce che è un file locale (inizia con /)
  Future<void> _importaDaGalleria() async {
    if (widget.city == null) return;

    try {
      // pickMultiImage apre la galleria e permette selezione multipla
      final List<XFile> immaginiSelezionate = await _picker.pickMultiImage();
      if (immaginiSelezionate.isEmpty) return;

      int aggiunte = 0;
      for (final xfile in immaginiSelezionate) {
        // salva il percorso assoluto nel database collegato alla città corrente
        await _dbHelper.salvaImmagineLocale(
          cityId: widget.city!.id,
          percorso: xfile.path,
        );
        aggiunte++;
      }

      // ricarica la griglia con le nuove immagini
      await _caricaImmaginiDaDb();

      setState(() {
        _messaggioImport = '$aggiunte foto aggiunte per ${widget.city!.name}';
      });
    } catch (e, stack) {
      print('ERRORE _importaDaGalleria: $e');
      print('STACK: $stack');
      setState(() => _messaggioImport = 'Errore galleria: $e');
    }
  }

  // helper sicuro per leggere il valore di una cella CSV.
  // controlla che la colonna esista e che il valore non sia vuoto.
  // non usa mai l'operatore ! — restituisce null in caso di qualsiasi problema
  String? _leggiCella(List<dynamic> riga, int col) {
    try {
      if (col >= riga.length) return null;
      final v = riga[col];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    } catch (_) {
      return null;
    }
  }

  // importa i dati da un file CSV al percorso indicato.
  // separatore: ;
  // struttura colonne:
  // 0:  Immagine
  // 1:  Coordinate (formato "lat;lng" con punto e virgola)
  // 2:  TIPO
  // 3:  DESTINAZIONE
  // 4:  ORARI
  // 5:  TICKET
  // 6:  HH
  // 7:  ZONA
  // 8:  GG
  // 9:  METRO-BUS
  // 10: NOTE
  // 11: PERCORSO (opzionale: percorso assoluto file locale dalla galleria)
  Future<void> _importaCsvDaPercorso(String percorso) async {
    try {
      final file = File(percorso);

      if (!await file.exists()) {
        setState(() => _messaggioImport = 'Errore: file non trovato');
        return;
      }

      // legge il contenuto e normalizza i fine riga.
      // gestisce sia Windows (\r\n) che Unix (\n)
      final contenuto = await file.readAsString();
      final contenutoNormalizzato = contenuto
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n');

      // usa ; come separatore per evitare conflitti con le virgole
      // nei campi come "Bus 6, 9, 30" o nelle note
      final righe = const CsvToListConverter().convert(
        contenutoNormalizzato,
        fieldDelimiter: ';',
        eol: '\n',
      );

      // controlla che ci siano almeno 2 righe (intestazione + 1 dato)
      if (righe.length < 2) {
        setState(() => _messaggioImport = 'Errore: nessun dato nel file');
        return;
      }

      int righeImportate = 0;

      // scorre le righe saltando la prima (intestazioni)
      for (int i = 1; i < righe.length; i++) {
        try {
          final riga = righe[i];

          // colonna 0: nome immagine — obbligatorio, salta se mancante
          final immagine = _leggiCella(riga, 0);
          if (immagine == null) continue;

          // colonna 1: coordinate in formato "lat;lng".
          // split su ; divide latitudine e longitudine
          double? lat;
          double? lng;
          final coordStr = _leggiCella(riga, 1);
          if (coordStr != null) {
            final parti = coordStr.split(';');
            if (parti.length == 2) {
              lat = double.tryParse(parti[0].trim());
              lng = double.tryParse(parti[1].trim());
            }
          }

          // salva nel database — tutti i campi opzionali possono essere null
          await _dbHelper.salvaImmagineGriglia(
            cityId: widget.city!.id,
            immagine: immagine,
            percorso: _leggiCella(riga, 11),
            latitudine: lat,
            longitudine: lng,
            tipo: _leggiCella(riga, 2),
            destinazione: _leggiCella(riga, 3),
            orari: _leggiCella(riga, 4),
            ticket: _leggiCella(riga, 5),
            hh: _leggiCella(riga, 6),
            zona: _leggiCella(riga, 7),
            gg: _leggiCella(riga, 8),
            metroBus: _leggiCella(riga, 9),
            note: _leggiCella(riga, 10),
          );

          righeImportate++;
        } catch (e, stack) {
          // in caso di errore su una singola riga, stampa il dettaglio
          // e continua con la riga successiva senza bloccare tutto
          print('ERRORE riga $i: $e');
          print('STACK riga $i: $stack');
          continue;
        }
      }

      // ricarica le immagini dal database dopo l'importazione
      await _caricaImmaginiDaDb();

      setState(() {
        _messaggioImport = righeImportate > 0
            ? '$righeImportate schede importate per ${widget.city!.name}'
            : 'Nessuna riga valida trovata nel file';
      });
    } catch (e, stack) {
      print('ERRORE _importaCsvDaPercorso: $e');
      print('STACK: $stack');
      setState(() => _messaggioImport = 'Errore importazione: $e');
    }
  }

  // apre il selettore per scegliere un file CSV già pronto
  // e lo importa direttamente nell'app
  Future<void> _importaCsv() async {
    if (widget.city == null) return;

    final risultato = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (risultato == null) return;
    if (risultato.files.isEmpty) return;

    final percorso = risultato.files.single.path;
    if (percorso == null || percorso.isEmpty) return;

    await _importaCsvDaPercorso(percorso);
  }

  // apre il selettore per scegliere un file Excel (.xlsx),
  // lo converte automaticamente in CSV con ; come separatore
  // tramite CsvConverter, e poi lo importa nell'app.
  // l'utente non deve fare nessuna conversione manuale
  Future<void> _convertiEImporta() async {
    if (widget.city == null) return;

    final risultato = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (risultato == null) return;
    if (risultato.files.isEmpty) return;

    final percorsoXlsx = risultato.files.single.path;
    if (percorsoXlsx == null || percorsoXlsx.isEmpty) return;

    // mostra messaggio di attesa durante la conversione
    setState(() => _messaggioImport = 'Conversione Excel in corso...');

    // converte il file Excel in CSV usando CsvConverter
    final percorsoCsv = await CsvConverter.converti(percorsoXlsx);

    if (percorsoCsv == null) {
      setState(() => _messaggioImport = 'Errore: conversione Excel fallita');
      return;
    }

    // importa il CSV appena convertito
    await _importaCsvDaPercorso(percorsoCsv);
  }

  // mostra un menu con le tre opzioni di aggiunta immagini:
  // dalla galleria, da CSV già pronto, oppure da Excel con conversione automatica
  void _mostraMenuAggiunta() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Aggiungi immagini',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            // opzione 1: importa foto dalla galleria del telefono
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Importa dalla galleria'),
              subtitle: const Text('Seleziona una o più foto dal telefono'),
              onTap: () {
                Navigator.pop(context);
                _importaDaGalleria();
              },
            ),

            // opzione 2: importa da file CSV già pronto con ; come separatore
            ListTile(
              leading: const Icon(Icons.upload_file, color: Colors.green),
              title: const Text('Importa da CSV'),
              subtitle: const Text('File CSV con ; come separatore'),
              onTap: () {
                Navigator.pop(context);
                _importaCsv();
              },
            ),

            // opzione 3: converti Excel in CSV e importa automaticamente.
            // l'utente sceglie il file .xlsx e l'app fa tutto il resto
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.orange),
              title: const Text('Importa da Excel'),
              subtitle: const Text(
                'Converte automaticamente il file .xlsx e importa',
              ),
              onTap: () {
                Navigator.pop(context);
                _convertiEImporta();
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // costruisce la lista delle immagini da mostrare nella griglia.
    // se è stata passata una città specifica, usa i dati dal database.
    // altrimenti raccoglie tutte le immagini di tutte le città
    late final List<String> images;

    if (widget.city != null) {
      if (_immaginiDaDb.isNotEmpty) {
        // usa percorso se disponibile, altrimenti usa immagine.
        // percorso ha priorità perché indica un file locale dalla galleria
        images = _immaginiDaDb
            .map((r) {
              final percorso = r['percorso'];
              final immagine = r['immagine'];
              final v = (percorso != null && percorso.toString().isNotEmpty)
                  ? percorso
                  : immagine;
              return v != null ? v.toString() : '';
            })
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (widget.city!.images.isNotEmpty) {
        // fallback: usa le immagini del modello City se il db è vuoto
        images = widget.city!.images;
      } else if (widget.city!.imageName != null) {
        // fallback: usa l'immagine principale della card
        images = [widget.city!.imageName!];
      } else {
        images = [];
      }
    } else {
      // se non è stata passata nessuna città, raccoglie tutte le immagini
      // di tutte le città usando expand, che appiattisce le liste in una sola
      images = cities
          .expand<String>(
            (c) => c.images.isNotEmpty
                ? c.images
                : (c.imageName != null ? [c.imageName!] : <String>[]),
          )
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.city != null ? 'Foto di ${widget.city!.name}' : 'Galleria',
        ),
        actions: [
          // bottone aggiunta visibile solo nella griglia di una città specifica,
          // non nella galleria generale
          if (widget.city != null)
            IconButton(
              icon: const Icon(Icons.add_photo_alternate),
              tooltip: 'Aggiungi immagini',
              onPressed: _mostraMenuAggiunta,
            ),
        ],
      ),
      body: _loading
          // indicatore di caricamento mentre si leggono i dati dal db
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // banner di stato importazione/aggiunta.
                // verde se è andata bene, rosso se c'è stato un errore
                if (_messaggioImport.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: _messaggioImport.contains('Errore')
                        ? Colors.red.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    child: Text(
                      _messaggioImport,
                      style: TextStyle(
                        color: _messaggioImport.contains('Errore')
                            ? Colors.red
                            : Colors.green,
                        fontSize: 13,
                      ),
                    ),
                  ),

                // griglia delle immagini, occupa tutto lo spazio rimanente
                Expanded(
                  child: images.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.photo_library_outlined,
                                size: 64,
                                color: Colors.white24,
                              ),
                              const SizedBox(height: 16),
                              const Text('Nessuna immagine disponibile'),
                              // bottone centrale visibile solo nella griglia
                              // di una città specifica
                              if (widget.city != null) ...[
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _mostraMenuAggiunta,
                                  icon: const Icon(Icons.add_photo_alternate),
                                  label: const Text('Aggiungi immagini'),
                                ),
                              ],
                            ],
                          ),
                        )
                      // GridView.builder costruisce la griglia in modo lazy,
                      // cioè crea solo i widget visibili sullo schermo
                      : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 2 colonne
                                crossAxisSpacing: 8, // spazio orizzontale
                                mainAxisSpacing: 8, // spazio verticale
                              ),
                          itemCount: images.length,
                          itemBuilder: (context, i) {
                            // passa i dati del db all'ImageCard se disponibili.
                            // controlla anche che l'indice sia valido
                            final datiDb =
                                _immaginiDaDb.isNotEmpty &&
                                    i < _immaginiDaDb.length
                                ? _immaginiDaDb[i]
                                : null;
                            return ImageCard(
                              imageName: images[i],
                              cityId: widget.city?.id,
                              datiIniziali: datiDb,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
