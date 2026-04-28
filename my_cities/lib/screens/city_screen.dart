import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_cities/add_city.dart';
import 'package:my_cities/city_category_filters.dart';
import 'package:my_cities/city_list.dart';
import 'package:my_cities/city_text_filter.dart';
import 'package:my_cities/data/cities.dart';
import 'package:my_cities/db_helper.dart';
import 'package:my_cities/models/city.dart';

// ===========================================================================
// CityScreen — schermata principale che mostra la lista di tutte le città.
//
// Struttura (analogia matrioska):
//   Scaffold
//   └── Column
//       ├── AppBar (titolo "Viaggi" + bottone +)
//       ├── CityTextFilter   (campo di ricerca per nome)
//       ├── CityCategoryFilters  (bottoni: Tutte / Visitate / Non visitate)
//       └── CityList  (lista scrollabile delle CityCard filtrate)
//
// Flusso dati (analogia archivio):
//   All'avvio leggiamo le città dall'archivio (DB) e le uniamo a quelle
//   predefinite (cities.dart). Ogni aggiunta/eliminazione aggiorna sia
//   la lista in memoria che l'archivio, così alla riapertura i dati
//   sono sempre aggiornati.
// ===========================================================================

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  // --------------------------------------------------------------------------
  // Stato interno
  // --------------------------------------------------------------------------

  // lista completa di tutte le città (DB + predefinite di cities.dart).
  // Analogia: è la scrivania su cui sono poggiate tutte le schede città —
  // da qui si decide quali mostrare applicando i filtri.
  List<City> allCities = [];

  // filtro attivo per categoria: Tutte / Visitate / Non visitate
  CityFilter filtroAttivo = CityFilter.all;

  // testo digitato dall'utente nel campo di ricerca
  String filtroNomeCitta = '';

  // true mentre stiamo leggendo i dati dal database all'avvio
  bool _loading = true;

  // unica istanza del database helper (pattern singleton — vedi DbHelper)
  final DbHelper _dbHelper = DbHelper();

  // --------------------------------------------------------------------------
  // Lifecycle
  // --------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // all'avvio carica subito le città salvate nel database.
    // Analogia: quando apri il negozio la mattina, vai nel magazzino
    // a prendere tutta la merce già presente sugli scaffali.
    _caricaCitta();
  }

  // --------------------------------------------------------------------------
  // Caricamento iniziale dal database
  //
  // Unisce due fonti di città:
  //   1. Città salvate dall'utente nel database SQLite (vengono prima)
  //   2. Città predefinite di cities.dart (vengono dopo, senza duplicati)
  //
  // Analogia: combina due mazzi di carte scartando i doppioni.
  // --------------------------------------------------------------------------

  Future<void> _caricaCitta() async {
    try {
      // legge le righe dal database — ogni riga è una Map<String, dynamic>
      final righe = await _dbHelper.getTutteCitta();

      // converte ogni Map (come un dizionario: {'name': 'Roma', ...})
      // in un oggetto City che il resto dell'app sa usare.
      // Analogia: traduce le schede dell'archivio nel formato che capiamo noi.
      final cittaDaDb = righe
          .map(
            (map) => City(
              id: map['id'] as String,
              name: map['name'] as String,
              country: map['country'] as String,
              isVisited: (map['is_visited'] as int) == 1,
              imageName: map['image_name'] as String?,
              note: map['note'] as String?,
            ),
          )
          .toList();

      // raccoglie gli id già nel database per evitare duplicati
      final idGiaPresenti = cittaDaDb.map((c) => c.id).toSet();

      // aggiunge le città predefinite di cities.dart solo se non
      // sono già nel database (confronta per id)
      final cittePredefinite = cities
          .where((c) => !idGiaPresenti.contains(c.id))
          .toList();

      setState(() {
        // le città del db (personalizzate dall'utente) vengono prima,
        // quelle predefinite in fondo
        allCities = [...cittaDaDb, ...cittePredefinite];
        _loading = false;
      });
    } catch (e) {
      print('ERRORE _caricaCitta: $e');
      // in caso di errore mostra almeno le città predefinite
      setState(() {
        allCities = List.from(cities);
        _loading = false;
      });
    }
  }

  // --------------------------------------------------------------------------
  // Gestione filtri
  // --------------------------------------------------------------------------

  // aggiorna il filtro per categoria (es. da "Tutte" a "Visitate")
  void filterCities(CityFilter filtro) {
    setState(() {
      filtroAttivo = filtro;
    });
  }

  // aggiorna il filtro testuale ad ogni lettera digitata dall'utente.
  // Chiamata da CityTextFilter tramite callback.
  void filtraCittaPerNome(String testo) {
    setState(() {
      filtroNomeCitta = testo;
    });
  }

  // --------------------------------------------------------------------------
  // CRUD città
  // --------------------------------------------------------------------------

  // aggiunge una nuova città, la salva nel database e la mette in cima alla lista.
  // Analogia: aggiungi una nuova scheda e la metti sopra le altre nello schedario.
  Future<void> addCity(City nuovaCitta) async {
    try {
      // salva nel database SQLite per la persistenza tra sessioni
      await _dbHelper.salvacitta(
        id: nuovaCitta.id,
        name: nuovaCitta.name,
        country: nuovaCitta.country,
        isVisited: nuovaCitta.isVisited,
        imageName: nuovaCitta.imageName,
        note: nuovaCitta.note,
      );

      // aggiorna la lista in memoria mettendo la nuova città in cima.
      // Lo spread operator (...) crea una nuova lista senza modificare quella vecchia.
      setState(() {
        allCities = [nuovaCitta, ...allCities];
      });
    } catch (e) {
      print('ERRORE addCity: $e');
      _mostraErrore('Errore durante il salvataggio della città');
    }
  }

  // rimuove una città dalla lista e dal database.
  // Le città predefinite di cities.dart non sono nel DB, quindi
  // eliminaCitta non fa nulla se l'id non esiste lì — nessun problema.
  // Analogia: strappa la scheda dallo schedario e la butta.
  Future<void> deleteCity(String idCitta) async {
    try {
      await _dbHelper.eliminaCitta(idCitta);

      // aggiorna la lista in memoria tenendo solo le città con id diverso
      setState(() {
        allCities = allCities.where((c) => c.id != idCitta).toList();
      });
    } catch (e) {
      print('ERRORE deleteCity: $e');
      _mostraErrore('Errore durante l\'eliminazione della città');
    }
  }

  // aggiorna lo stato isVisited di una città nel database e nella lista.
  // Chiamata da CityCard quando l'utente preme il bottone visitata/non visitata.
  Future<void> aggiornaIsVisited(String cityId, bool isVisited) async {
    try {
      await _dbHelper.salvaIsVisited(cityId, isVisited);

      // aggiorna l'oggetto City nella lista in memoria
      setState(() {
        final index = allCities.indexWhere((c) => c.id == cityId);
        if (index != -1) {
          allCities[index] = City(
            id: allCities[index].id,
            name: allCities[index].name,
            country: allCities[index].country,
            isVisited: isVisited,
            imageName: allCities[index].imageName,
            note: allCities[index].note,
          );
        }
      });
    } catch (e) {
      print('ERRORE aggiornaIsVisited: $e');
    }
  }

  // --------------------------------------------------------------------------
  // UI helpers
  // --------------------------------------------------------------------------

  // apre la modale per aggiungere una nuova città.
  // showModalBottomSheet mostra un pannello dal basso senza navigare in una
  // nuova schermata — mantiene il contesto della pagina corrente.
  void showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // permette al foglio di espandersi con la tastiera
      builder: (ctx) => AddCity(aggiungiCitta: addCity),
    );
  }

  void _mostraErrore(String messaggio) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messaggio), backgroundColor: Colors.red),
    );
  }

  // --------------------------------------------------------------------------
  // Build
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // mostra uno spinner mentre carichiamo i dati dal database.
    // Analogia: la schermata "in caricamento" è come la porta del negozio
    // ancora chiusa mentre il commesso prepara tutto dentro.
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // applica i filtri in sequenza sulla lista completa.
    // Analogia: filtrare le schede è come usare due setacci in serie —
    // prima per categoria, poi per nome — rimane solo ciò che passa entrambi.

    // primo setaccio: categoria (visitata / non visitata / tutte)
    List<City> cittaFiltrate = switch (filtroAttivo) {
      CityFilter.visited => allCities.where((c) => c.isVisited).toList(),
      CityFilter.notVisited => allCities.where((c) => !c.isVisited).toList(),
      CityFilter.all => List.from(allCities),
    };

    // secondo setaccio: testo digitato nel campo di ricerca.
    // toLowerCase rende il confronto case-insensitive ("roma" trova "Roma")
    if (filtroNomeCitta.isNotEmpty) {
      final query = filtroNomeCitta.toLowerCase();
      cittaFiltrate = cittaFiltrate
          .where((c) => c.name.toLowerCase().contains(query))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Viaggi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            // copyWith aggiorna solo il font e la dimensione mantenendo
            // il resto dello stile definito nel tema globale dell'app
            fontFamily: GoogleFonts.playfairDisplay().fontFamily,
            fontSize: 24,
          ),
        ),
        actions: [
          // bottone + in alto a destra per aprire la modale di aggiunta città
          IconButton(
            onPressed: () => showModal(context),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Aggiungi città',
          ),
        ],
      ),

      body: Column(
        children: [
          // campo di ricerca testuale — chiama filtraCittaPerNome ad ogni lettera
          CityTextFilter(aggiornaFiltro: filtraCittaPerNome),

          // bottoni filtro per categoria: Tutte / Visitate / Non visitate
          CityCategoryFilters(
            filtraCitta: filterCities,
            filtroAttivo: filtroAttivo,
          ),

          // contatore risultati (utile quando il filtro riduce la lista)
          if (filtroNomeCitta.isNotEmpty || filtroAttivo != CityFilter.all)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${cittaFiltrate.length} città trovate',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ),

          // lista delle città filtrate — occupa tutto lo spazio rimanente.
          // Expanded fa sì che CityList si allarghi fino al bordo inferiore
          // dello schermo senza overflow.
          Expanded(
            child: cittaFiltrate.isEmpty
                ? _buildStatoVuoto()
                : CityList(
                    filteredCities: cittaFiltrate,
                    rimuoviCitta: deleteCity,
                  ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Widget: stato vuoto (nessuna città corrisponde ai filtri)
  // --------------------------------------------------------------------------

  Widget _buildStatoVuoto() {
    final haFiltriAttivi =
        filtroNomeCitta.isNotEmpty || filtroAttivo != CityFilter.all;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            haFiltriAttivi ? Icons.search_off : Icons.location_city_outlined,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            haFiltriAttivi
                ? 'Nessuna città corrisponde ai filtri'
                : 'Nessuna città ancora',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          if (!haFiltriAttivi) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => showModal(context),
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi la prima città'),
            ),
          ],
        ],
      ),
    );
  }
}
