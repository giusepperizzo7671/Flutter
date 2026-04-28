import 'package:flutter/material.dart';
import 'package:my_cities/city_category_filters.dart';
import 'package:my_cities/city_list.dart';
import 'package:my_cities/add_city.dart';
import 'package:my_cities/city_text_filter.dart';
import 'package:my_cities/data/cities.dart';
import 'package:my_cities/models/city.dart';
import 'package:my_cities/db_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  // lista di tutte le città, inizializzata con i dati del file cities.dart
  // e poi integrata con le città salvate nel database
  List<City> allCities = [];

  // filtro attivo per categoria (visitata, non visitata, tutte)
  CityFilter filtroAttivo = CityFilter.all;

  // testo digitato dall'utente per filtrare le città per nome
  String filtroNomeCitta = '';

  // istanza del database helper per salvare e caricare le città
  final DbHelper _dbHelper = DbHelper();

  // indica se stiamo caricando i dati dal database
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // carica le città dal database all'avvio
    _caricaCitta();
  }

  // carica le città salvate nel database e le unisce a quelle di cities.dart.
  // le città del db vengono messe in cima, quelle di cities.dart in fondo
  Future<void> _caricaCitta() async {
    final cittaDaDb = await _dbHelper.leggiCitta();

    // converte le Map del database in oggetti City
    final cittaSalvate = cittaDaDb
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

    // unisce le città salvate nel db con quelle predefinite di cities.dart,
    // evitando duplicati controllando gli id
    final idSalvati = cittaSalvate.map((c) => c.id).toSet();
    final cittePredefinite = cities
        .where((c) => !idSalvati.contains(c.id))
        .toList();

    setState(() {
      allCities = [...cittaSalvate, ...cittePredefinite];
      _loading = false;
    });
  }

  // aggiorna il filtro per categoria
  void filterCities(CityFilter filtro) {
    setState(() {
      filtroAttivo = filtro;
    });
  }

  // aggiorna il filtro per nome, chiamata dal widget CityTextFilter
  void filtraCittaPerNome(String testo) {
    setState(() {
      filtroNomeCitta = testo;
    });
  }

  // aggiunge una nuova città alla lista e la salva nel database.
  // usa lo spread operator (...) per creare un nuovo array con la città in cima
  Future<void> addCity(City nuovaCitta) async {
    // salva la città nel database SQLite per la persistenza
    await _dbHelper.salvaCitta(
      id: nuovaCitta.id,
      name: nuovaCitta.name,
      country: nuovaCitta.country,
      isVisited: nuovaCitta.isVisited,
      imageName: nuovaCitta.imageName,
      note: nuovaCitta.note,
    );

    setState(() {
      allCities = [nuovaCitta, ...allCities];
    });
  }

  // rimuove una città dalla lista e dal database in base al suo id univoco
  Future<void> deleteCity(String idCitta) async {
    // elimina dal database solo le città aggiunte dall'utente.
    // le città predefinite di cities.dart non sono nel db, quindi
    // eliminaCitta non fa nulla se l'id non esiste
    await _dbHelper.eliminaCitta(idCitta);

    setState(() {
      allCities = allCities.where((c) => c.id != idCitta).toList();
    });
  }

  // apre la modale per aggiungere una nuova città.
  // showModalBottomSheet mostra un pannello dal basso senza navigare
  void showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => AddCity(aggiungiCitta: addCity),
    );
  }

  @override
  Widget build(BuildContext context) {
    // mostra un indicatore di caricamento mentre si leggono i dati dal db
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // applica i filtri in sequenza sulla lista completa
    List<City> cittaFiltrate = allCities;

    // primo filtro: categoria (visitata, non visitata, tutte)
    if (filtroAttivo == CityFilter.visited) {
      cittaFiltrate = allCities.where((city) => city.isVisited).toList();
    } else if (filtroAttivo == CityFilter.notVisited) {
      cittaFiltrate = allCities.where((city) => !city.isVisited).toList();
    }

    // secondo filtro: testo digitato nel campo di ricerca.
    // toLowerCase rende il filtro case-insensitive
    cittaFiltrate = cittaFiltrate
        .where(
          (city) =>
              city.name.toLowerCase().contains(filtroNomeCitta.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Viaggi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: GoogleFonts.playfairDisplay().fontFamily,
            fontSize: 24,
          ),
        ),
        // bottone per aprire la modale di aggiunta città
        actions: [
          IconButton(
            onPressed: () => showModal(context),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          // widget per filtrare le città per nome
          CityTextFilter(aggiornaFiltro: filtraCittaPerNome),

          // widget per i filtri per categoria
          CityCategoryFilters(
            filtraCitta: filterCities,
            filtroAttivo: filtroAttivo,
          ),

          // lista delle città filtrate, occupa tutto lo spazio rimanente
          Expanded(
            child: CityList(
              filteredCities: cittaFiltrate,
              rimuoviCitta: deleteCity,
            ),
          ),
        ],
      ),
    );
  }
}
