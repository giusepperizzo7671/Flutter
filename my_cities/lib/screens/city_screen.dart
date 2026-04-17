import 'package:flutter/material.dart';
import 'package:my_cities/city_category_filters.dart';
import 'package:my_cities/city_list.dart';
import 'package:my_cities/add_city.dart';
import 'package:my_cities/city_text_filter.dart';
import 'package:my_cities/data/cities.dart';
import 'package:my_cities/models/city.dart';
import 'package:google_fonts/google_fonts.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  // lista di tutte le città, inizializzata con i dati del file cities.dart
  var allCities = cities;

  // filtro attivo per categoria (visitata, non visitata, tutte)
  CityFilter filtroAttivo = CityFilter.all;

  // testo digitato dall'utente per filtrare le città per nome
  String filtroNomeCitta = '';

  // funzione per aggiornare il filtro per categoria
  void filterCities(CityFilter filtro) {
    setState(() {
      filtroAttivo = filtro;
    });
  }

  // funzione per aggiornare il filtro per nome, chiamata dal widget CityTextFilter
  // ogni volta che l'utente digita qualcosa nel campo di ricerca
  void filtraCittaPerNome(String testo) {
    setState(() {
      filtroNomeCitta = testo;
    });
  }

  // funzione per aggiungere una nuova città alla lista.
  // usa lo spread operator (...) per creare un nuovo array con la città nuova in cima
  void addCity(City nuovaCitta) {
    setState(() {
      allCities = [nuovaCitta, ...allCities];
    });
  }

  // funzione per rimuovere una città dalla lista in base al suo id univoco.
  // where filtra l'array tenendo solo le città con id diverso da quello da eliminare
  void deleteCity(String idCitta) {
    setState(() {
      allCities = allCities.where((citta) => citta.id != idCitta).toList();
    });
  }

  // funzione che apre la modale per aggiungere una nuova città.
  // showModalBottomSheet mostra un pannello dal basso senza navigare in una nuova pagina,
  // in modo da mantenere il contesto della pagina principale
  void showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => AddCity(aggiungiCitta: addCity),
    );
  }

  @override
  Widget build(BuildContext context) {
    // parto dalla lista completa e applico i filtri in sequenza
    List<City> cittaFiltrate = allCities;

    // primo filtro: categoria (visitata, non visitata, tutte)
    if (filtroAttivo == CityFilter.visited) {
      cittaFiltrate = allCities.where((city) => city.isVisited).toList();
    } else if (filtroAttivo == CityFilter.notVisited) {
      cittaFiltrate = allCities.where((city) => !city.isVisited).toList();
    } else if (filtroAttivo == CityFilter.all) {
      cittaFiltrate = allCities;
    }

    // secondo filtro: testo digitato dall'utente nel campo di ricerca.
    // toLowerCase rende il filtro case-insensitive, così "roma" trova anche "Roma"
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
            // copyWith sovrascrive solo il font e la dimensione,
            // mantenendo il resto dello stile dal tema
            fontFamily: GoogleFonts.playfairDisplay().fontFamily,
            fontSize: 24,
          ),
        ),
        // actions mostra widget alla destra dell'appbar.
        // In questo caso un bottone per aprire la modale di aggiunta città
        actions: [
          IconButton(
            onPressed: () => showModal(context),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          // widget per filtrare le città per nome.
          // aggiornaFiltro è la callback chiamata ogni volta che l'utente digita
          CityTextFilter(aggiornaFiltro: filtraCittaPerNome),

          // widget per i filtri per categoria (visitata, non visitata, tutte).
          // filtroAttivo serve a CityCategoryFilters per evidenziare il bottone attivo
          CityCategoryFilters(
            filtraCitta: filterCities,
            filtroAttivo: filtroAttivo,
          ),

          // Expanded fa sì che CityList occupi tutto lo spazio rimanente nella colonna.
          // filteredCities riceve la lista già filtrata dai due filtri sopra
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
