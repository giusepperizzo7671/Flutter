import 'package:flutter/material.dart';
import 'package:my_cities/city_category_filters.dart';
import 'package:my_cities/city_list.dart';
import 'package:my_cities/add_city.dart';
import 'package:my_cities/city_text_filter.dart';
import 'package:my_cities/data/cities.dart';
import 'package:my_cities/models/city.dart';
import 'package:my_cities/random_city.dart';
import 'package:google_fonts/google_fonts.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  // qui devo gestire lo stato delle città.
  // mi serve: lista delle città, nome del filtro attivo, testo da filtrare
  var allCities = cities;
  CityFilter filtroAttivo = CityFilter.all;
  String filtroNomeCitta = '';

  // funzione per filtrare città: visitate, non visitate, tutte
  void filterCities(CityFilter filtro) {
    setState(() {
      filtroAttivo = filtro;
    });
  }

  // funzione per filtrare città in base al testo digitato dall'utente
  void filtraCittaPerNome(String testo) {
    setState(() {
      filtroNomeCitta = testo;
    });
  }

  // funzione per aggiungere la nuova città all'elenco
  void addCity(City nuovaCitta) {
    setState(() {
      // quando aggiorno lo stato, sostituisco l'elenco precedente con un nuovo elenco
      allCities = [nuovaCitta, ...allCities];
    });
  }

  // funzione per rimuovere una città dalla lista
  void deleteCity(String idCitta) {
    setState(() {
      // filtro l'array rimuovendo l'id della città da eliminare
      allCities = allCities.where((citta) => citta.id != idCitta).toList();
    });
  }

  // funzione chiamata quando si preme il bottone per aggiungere una nuova città
  void showModal(BuildContext context) {
    // showModalBottomSheet è una funzione che mostra una modale che si apre dal basso dello schermo, e che si chiude quando si clicca fuori dalla modale o quando si preme il bottone di chiusura. La modale ha bisogno di un contesto per essere mostrata, e un builder che restituisce il widget da mostrare nella modale. In questo caso, passo un nuovo widget AddCity, che contiene il form per aggiungere una nuova città.
    // le modali sono utili per mostrare contenuti temporanei o secondari, come form, menu, etc. senza dover navigare in una nuova pagina. In questo modo, si può mantenere il contesto della pagina principale, e mostrare solo il contenuto necessario per l'azione che si vuole compiere.
    showModalBottomSheet(
      context: context,
      builder: (context) => AddCity(aggiungiCitta: addCity),
    );
  }

  @override
  Widget build(BuildContext context) {
    // filtro le città in base al filtro attivo, e poi passo questa variabile alla CityList, così mostra solo le città filtrate.
    List<City> cittaFiltrate = allCities;

    // primo filtro: in base al filtro attivo (visitata, non visitata, tutte)
    if (filtroAttivo == CityFilter.visited) {
      cittaFiltrate = allCities.where((city) => city.isVisited).toList();
    } else if (filtroAttivo == CityFilter.notVisited) {
      cittaFiltrate = allCities.where((city) => !city.isVisited).toList();
    } else if (filtroAttivo == CityFilter.all) {
      cittaFiltrate = allCities;
    }

    // secondo filtro: in base al testo digitato dall'utente, filtro le città che contengono il testo digitato nel nome.
    // Uso toLowerCase per rendere il filtro case-insensitive, così non importa se l'utente digita in maiuscolo o minuscolo, il filtro funzionerà comunque.
    cittaFiltrate = cittaFiltrate
        .where(
          (city) =>
              city.name.toLowerCase().contains(filtroNomeCitta.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: const Color.fromARGB(255, 183, 157, 224),
        centerTitle: true,
        title: Text(
          'Viaggi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: GoogleFonts.playfairDisplay().fontFamily,
            fontSize: 24,
            // :Center(),
          ),
        ),
        // actions è una lista di widget che vengono mostrati alla fine dell'appbar, e che possono essere usati per aggiungere bottoni o menu. In questo caso, aggiungo un IconButton con l'icona di aggiunta, che quando viene premuto chiama la funzione showModal per mostrare la modale di aggiunta città.
        // altre posizioni utili in appBar: leading, che mostra un widget all'inizio dell'appbar, solitamente usato per il menu di navigazione o per il bottone di ritorno indietro. bottom, che mostra un widget sotto l'appbar, solitamente usato per i tab o per i filtri.
        actions: [
          IconButton(
            onPressed: () => showModal(context),
            icon: Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      // body: RandomCity(),
      body: Column(
        children: [
          // widget per filtrare le città in base al testo digitato dall'utente. Passo la funzione di aggiornamento del filtro come prop, così il widget può chiamarla quando l'utente digita qualcosa.
          CityTextFilter(aggiornaFiltro: filtraCittaPerNome),
          // uso un widget separato per i filtri, così è più facile da gestire e da modificare.
          // Passo la funzione di filtraggio come prop, così il widget dei filtri può chiamarla quando l'utente seleziona un filtro diverso e aggiornare la lista delle città filtrate di conseguenza.
          CityCategoryFilters(filtraCitta: filterCities),
          // Ora cityList contiene solo l'elenco delle città filtrate, e viene aggiornato ogni volta che l'utente cambia il filtro o digita un testo nel filtro di ricerca.
          Expanded(
            child: CityList(
              filteredCities: cittaFiltrate,
              rimuoviCitta: deleteCity,
            ),
          ),
          // faccio un pulsante di esempio per navigare alla schermata randomcity
          ElevatedButton(
            // l'evento onPressed è una funzione che viene chiamata quando si preme il bottone. In questo caso, uso Navigator.of(context).push per navigare a una nuova pagina, che è RandomCity.
            //MaterialPageRoute è un widget che crea una transizione tra le pagine, e builder è una funzione che restituisce il widget da mostrare nella nuova pagina. In questo caso, passo un nuovo widget RandomCity, che mostra una città casuale.
            // come argomento metto underscore (_) perché non mi serve alcun argomento, ma è comunque richiesto dal builder.
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => RandomCity()));
            },
            child: Text('Random city'),
          ),
        ],
      ),
    );
  }
}
