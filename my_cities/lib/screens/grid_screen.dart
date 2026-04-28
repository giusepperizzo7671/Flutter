import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_cities/models/city.dart';
import 'package:my_cities/db_helper.dart';
import 'package:my_cities/utils/csv_converter.dart';
import 'package:my_cities/widgets/image_card.dart';

// ---------------------------------------------------------------------------
// ImmagineGriglia — modello che rappresenta una singola scheda della griglia.
//
// Analogia: ogni ImmagineGriglia è come una scheda in un archivio fisico.
// Ha un numero univoco (id), appartiene a una città (cityId) e contiene
// tutti i metadati. Il campo isVisitata è il bollino "già visto" che puoi
// attaccare sul fronte: la scheda diventa semitrasparente per indicare che
// il posto è già stato visitato.
// ---------------------------------------------------------------------------
class ImmagineGriglia {
  final int? id;
  final String cityId;
  final String immagine;
  final String? percorso;
  final double? latitudine;
  final double? longitudine;
  final String? tipo;
  final String? destinazione;
  final String? orari;
  final String? ticket;
  final String? hh;
  final String? zona;
  final String? gg;
  final String? metroBus;
  final String? note;
  final bool isVisitata; // true → card semitrasparente (posto già visitato)

  const ImmagineGriglia({
    this.id,
    required this.cityId,
    required this.immagine,
    this.percorso,
    this.latitudine,
    this.longitudine,
    this.tipo,
    this.destinazione,
    this.orari,
    this.ticket,
    this.hh,
    this.zona,
    this.gg,
    this.metroBus,
    this.note,
    this.isVisitata = false,
  });

  // costruisce un ImmagineGriglia dalla mappa restituita da SQLite.
  // latitudine/longitudine usano toDouble() perché SQLite può restituirle come int.
  factory ImmagineGriglia.fromMap(Map<String, dynamic> map) {
    return ImmagineGriglia(
      id: map['id'] as int?,
      cityId: map['city_id'] as String,
      immagine: map['immagine'] as String,
      percorso: map['percorso'] as String?,
      latitudine: (map['latitudine'] as num?)?.toDouble(),
      longitudine: (map['longitudine'] as num?)?.toDouble(),
      tipo: map['tipo'] as String?,
      destinazione: map['destinazione'] as String?,
      orari: map['orari'] as String?,
      ticket: map['ticket'] as String?,
      hh: map['hh'] as String?,
      zona: map['zona'] as String?,
      gg: map['gg'] as String?,
      metroBus: map['metro_bus'] as String?,
      note: map['note'] as String?,
      isVisitata: (map['is_visitata'] as int? ?? 0) == 1,
    );
  }

  // crea una copia con i campi specificati modificati
  ImmagineGriglia copyWith({
    int? id,
    String? cityId,
    String? immagine,
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
    bool? isVisitata,
  }) {
    return ImmagineGriglia(
      id: id ?? this.id,
      cityId: cityId ?? this.cityId,
      immagine: immagine ?? this.immagine,
      percorso: percorso ?? this.percorso,
      latitudine: latitudine ?? this.latitudine,
      longitudine: longitudine ?? this.longitudine,
      tipo: tipo ?? this.tipo,
      destinazione: destinazione ?? this.destinazione,
      orari: orari ?? this.orari,
      ticket: ticket ?? this.ticket,
      hh: hh ?? this.hh,
      zona: zona ?? this.zona,
      gg: gg ?? this.gg,
      metroBus: metroBus ?? this.metroBus,
      note: note ?? this.note,
      isVisitata: isVisitata ?? this.isVisitata,
    );
  }
}

// ---------------------------------------------------------------------------
// GridScreen — schermata principale della griglia immagini per una città.
// ---------------------------------------------------------------------------
class GridScreen extends StatefulWidget {
  const GridScreen({super.key, this.city});

  final City? city;

  @override
  State<GridScreen> createState() => _GridScreenState();
}

class _GridScreenState extends State<GridScreen> {
  List<ImmagineGriglia> _schede = [];
  String? _messaggioImport;
  bool _caricamento = false;

  // filtri attivi — null significa "nessun filtro" (mostra tutti)
  String? _filtroTipo;
  String? _filtroZona;

  // ricava i valori unici di tipo e zona dalle schede caricate,
  // ordinati alfabeticamente. Analogia: l'indice in fondo a un libro —
  // si costruisce automaticamente dai contenuti presenti.
  List<String> get _tipiDisponibili =>
      _schede
          .map((s) => s.tipo)
          .whereType<String>()
          .where((t) => t.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  List<String> get _zoneDisponibili =>
      _schede
          .map((s) => s.zona)
          .whereType<String>()
          .where((z) => z.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  // schede filtrate: applica tipo e zona in sequenza
  List<ImmagineGriglia> get _schedeFiltrate {
    var lista = _schede;
    if (_filtroTipo != null) {
      lista = lista.where((s) => s.tipo == _filtroTipo).toList();
    }
    if (_filtroZona != null) {
      lista = lista.where((s) => s.zona == _filtroZona).toList();
    }
    return lista;
  }

  final DbHelper _dbHelper = DbHelper();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _caricaSchedeDaDb();
  }

  Future<void> _caricaSchedeDaDb() async {
    setState(() => _caricamento = true);
    try {
      final List<Map<String, dynamic>> righe = widget.city != null
          ? await _dbHelper.getImmaginiGriglia(widget.city!.id)
          : await _dbHelper.getTutteImmaginiGriglia();
      setState(() {
        _schede = righe.map(ImmagineGriglia.fromMap).toList();
      });
    } catch (e) {
      _mostraSnackbar('Errore caricamento: $e', errore: true);
    } finally {
      setState(() => _caricamento = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Toggle visitata / non visitata — inverte lo stato e salva nel DB
  // ---------------------------------------------------------------------------
  Future<void> _toggleVisitata(ImmagineGriglia scheda) async {
    if (scheda.id == null) return;
    final nuovoStato = !scheda.isVisitata;
    try {
      await _dbHelper.aggiornaIsVisitataScheda(scheda.id!, nuovoStato);
      setState(() {
        final i = _schede.indexWhere((s) => s.id == scheda.id);
        if (i != -1) _schede[i] = _schede[i].copyWith(isVisitata: nuovoStato);
      });
    } catch (e) {
      _mostraSnackbar('Errore: $e', errore: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Cancellazione singola scheda
  // ---------------------------------------------------------------------------
  Future<void> _eliminaScheda(ImmagineGriglia scheda) async {
    if (scheda.id == null) return;

    final conferma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Elimina scheda',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Vuoi eliminare "${scheda.destinazione ?? scheda.immagine}"?\n'
          'Questa azione non può essere annullata.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (conferma != true) return;

    try {
      await _dbHelper.eliminaImmagineGriglia(scheda.id!);
      setState(() => _schede.removeWhere((s) => s.id == scheda.id));
      _mostraSnackbar('Scheda eliminata');
    } catch (e) {
      _mostraSnackbar('Errore eliminazione: $e', errore: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Import dalla galleria
  // ---------------------------------------------------------------------------
  Future<void> _importaDaGalleria() async {
    if (widget.city == null) return;
    final List<XFile> foto = await _picker.pickMultiImage();
    if (foto.isEmpty) return;

    setState(() {
      _caricamento = true;
      _messaggioImport = 'Importazione galleria in corso...';
    });

    int importate = 0;
    for (final f in foto) {
      try {
        await _dbHelper.salvaImmagineGriglia(
          cityId: widget.city!.id,
          immagine: f.name,
          percorso: f.path,
        );
        importate++;
      } catch (e) {
        print('ERRORE foto ${f.name}: $e');
      }
    }

    await _caricaSchedeDaDb();
    setState(() {
      _caricamento = false;
      _messaggioImport = '$importate foto importate da galleria';
    });
  }

  // ---------------------------------------------------------------------------
  // Import da CSV
  // ---------------------------------------------------------------------------
  Future<void> _importaCsv() async {
    if (widget.city == null) return;
    final risultato = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (risultato == null || risultato.files.isEmpty) return;
    final percorso = risultato.files.single.path;
    if (percorso == null || percorso.isEmpty) return;
    await _importaDaPercorso(percorso);
  }

  // ---------------------------------------------------------------------------
  // Import da Excel (.xlsx)
  // ---------------------------------------------------------------------------
  Future<void> _importaExcel() async {
    if (widget.city == null) return;
    final risultato = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (risultato == null || risultato.files.isEmpty) return;
    final percorsoXlsx = risultato.files.single.path;
    if (percorsoXlsx == null || percorsoXlsx.isEmpty) return;

    setState(() {
      _caricamento = true;
      _messaggioImport = 'Conversione Excel in corso...';
    });

    final percorsoCsv = await CsvConverter.converti(percorsoXlsx);
    if (percorsoCsv == null) {
      setState(() {
        _caricamento = false;
        _messaggioImport = 'Errore: conversione Excel fallita';
      });
      return;
    }
    await _importaDaPercorso(percorsoCsv);
  }

  // ---------------------------------------------------------------------------
  // Nucleo import — AGGIUNGE senza cancellare le schede esistenti
  // ---------------------------------------------------------------------------
  Future<void> _importaDaPercorso(String percorso) async {
    setState(() {
      _caricamento = true;
      _messaggioImport = 'Importazione in corso...';
    });

    try {
      final righe = (await File(percorso).readAsString()).split('\n');
      int importate = 0;

      for (int i = 1; i < righe.length; i++) {
        final riga = righe[i].trim();
        if (riga.isEmpty) continue;
        final celle = riga.split(';');

        String? leggi(int col) {
          if (col >= celle.length) return null;
          final v = celle[col].trim();
          return v.isEmpty ? null : v;
        }

        final immagine = leggi(0);
        if (immagine == null) continue;

        double? lat, lng;
        final coordStr = leggi(1);
        if (coordStr != null) {
          // le coordinate usano la virgola come separatore, come Google Maps:
          // "46.11299, 12.19358" → split su ',' → [lat, lng]
          // la virgola non crea conflitti perché il CSV usa ; come separatore colonne
          final parti = coordStr.split(',');
          if (parti.length == 2) {
            lat = double.tryParse(parti[0].trim());
            lng = double.tryParse(parti[1].trim());
          }
        }

        try {
          await _dbHelper.salvaImmagineGriglia(
            cityId: widget.city!.id,
            immagine: immagine,
            percorso: leggi(11),
            latitudine: lat,
            longitudine: lng,
            tipo: leggi(2),
            destinazione: leggi(3),
            orari: leggi(4),
            ticket: leggi(5),
            hh: leggi(6),
            zona: leggi(7),
            gg: leggi(8),
            metroBus: leggi(9),
            note: leggi(10),
          );
          importate++;
        } catch (e, stack) {
          print('ERRORE riga $i: $e\n$stack');
        }
      }

      await _caricaSchedeDaDb();
      setState(() {
        _messaggioImport = importate > 0
            ? '$importate schede aggiunte per ${widget.city?.name ?? "tutte le città"}'
            : 'Nessuna riga valida trovata nel file';
      });
    } catch (e, stack) {
      print('ERRORE _importaDaPercorso: $e\n$stack');
      setState(() => _messaggioImport = 'Errore importazione: $e');
    } finally {
      setState(() => _caricamento = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Menu aggiunta
  // ---------------------------------------------------------------------------
  void _mostraMenuAggiunta() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Aggiungi schede',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Importa dalla galleria'),
              onTap: () {
                Navigator.pop(ctx);
                _importaDaGalleria();
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file, color: Colors.green),
              title: const Text('Importa da CSV'),
              subtitle: const Text('File CSV con ; come separatore'),
              onTap: () {
                Navigator.pop(ctx);
                _importaCsv();
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.orange),
              title: const Text('Importa da Excel'),
              subtitle: const Text('Converte automaticamente il file .xlsx'),
              onTap: () {
                Navigator.pop(ctx);
                _importaExcel();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _mostraSnackbar(String messaggio, {bool errore = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messaggio),
        backgroundColor: errore ? Colors.red : Colors.green,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.city != null
              ? 'Schede di ${widget.city!.name}'
              : 'Tutte le schede',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            tooltip: 'Aggiungi schede',
            onPressed: widget.city != null ? _mostraMenuAggiunta : null,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_messaggioImport != null)
            Container(
              width: double.infinity,
              color: Colors.green.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _messaggioImport!,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _messaggioImport = null),
                  ),
                ],
              ),
            ),

          if (_caricamento) const LinearProgressIndicator(),

          // ---------- barra filtri tipo e zona ----------
          // Analogia: i cassetti di un archivio con le etichette colorate —
          // clicchi su un'etichetta e vedi solo le schede di quel cassetto.
          if (!_caricamento && _schede.isNotEmpty) _buildBarraFiltri(),

          Expanded(
            child: _schede.isEmpty && !_caricamento
                ? _buildStatoVuoto()
                : _schedeFiltrate.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list_off,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nessuna scheda con questi filtri',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() {
                            _filtroTipo = null;
                            _filtroZona = null;
                          }),
                          child: const Text('Rimuovi filtri'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.72,
                        ),
                    itemCount: _schedeFiltrate.length,
                    itemBuilder: (ctx, i) {
                      final scheda = _schedeFiltrate[i];
                      return ImageCard(
                        scheda: scheda,
                        onElimina: () => _eliminaScheda(scheda),
                        onToggleVisitata: () => _toggleVisitata(scheda),
                        onNotaAggiornata: (nota) {
                          setState(() {
                            final idx = _schede.indexWhere(
                              (s) => s.id == scheda.id,
                            );
                            if (idx != -1) {
                              _schede[idx] = _schede[idx].copyWith(note: nota);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Barra filtri: due righe di chip scrollabili (tipo e zona)
  //
  // Ogni chip funziona come un interruttore: selezionato filtra, ri-toccato
  // rimuove il filtro. I chip sono scrollabili orizzontalmente per gestire
  // molti valori senza andare a capo.
  // Analogia: i separatori colorati in uno schedario — clicchi sul divisore
  // "Natura" e vedi solo le schede di quel tipo.
  // ---------------------------------------------------------------------------
  Widget _buildBarraFiltri() {
    final haFiltri = _filtroTipo != null || _filtroZona != null;
    final conteggio = _schedeFiltrate.length;
    final totale = _schede.length;

    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // riga 1: filtro tipo
          if (_tipiDisponibili.isNotEmpty)
            _rigaChip(
              icona: Icons.category_outlined,
              etichetta: 'Tipo',
              valori: _tipiDisponibili,
              selezione: _filtroTipo,
              onSelezione: (v) =>
                  setState(() => _filtroTipo = _filtroTipo == v ? null : v),
            ),

          // riga 2: filtro zona
          if (_zoneDisponibili.isNotEmpty)
            _rigaChip(
              icona: Icons.map_outlined,
              etichetta: 'Zona',
              valori: _zoneDisponibili,
              selezione: _filtroZona,
              onSelezione: (v) =>
                  setState(() => _filtroZona = _filtroZona == v ? null : v),
            ),

          // contatore risultati + reset
          if (haFiltri)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
              child: Row(
                children: [
                  Text(
                    '$conteggio di $totale schede',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _filtroTipo = null;
                      _filtroZona = null;
                    }),
                    child: const Text(
                      'Rimuovi filtri',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _rigaChip({
    required IconData icona,
    required String etichetta,
    required List<String> valori,
    required String? selezione,
    required void Function(String) onSelezione,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(icona, size: 16, color: Colors.blueGrey),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: valori.map((v) {
                  final selezionato = selezione == v;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(
                        v,
                        style: TextStyle(
                          fontSize: 12,
                          color: selezionato ? Colors.white : null,
                        ),
                      ),
                      selected: selezionato,
                      onSelected: (_) => onSelezione(v),
                      selectedColor: Colors.blue,
                      checkmarkColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 0,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatoVuoto() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Nessuna scheda ancora',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          if (widget.city != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _mostraMenuAggiunta,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi la prima scheda'),
            ),
          ],
        ],
      ),
    );
  }
}
