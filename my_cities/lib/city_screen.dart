import 'package:flutter/material.dart';
import 'package:my_cities/city_list.dart';
import 'package:my_cities/add_city.dart';
import 'package:my_cities/data/cities.dart';
import 'package:my_cities/models/city.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  // qui devo gestire lo stato delle città.
  // mi serve: lista delle città, città filtrate, nome del filtro attivo
  var filteredCities = cities;
  // funzione per filtrare città: visitate, non visitate, tutte
  void filterCities(CityFilter filter) {
    setState(() {
      if (filter == CityFilter.visited) {
        filteredCities = cities.where((city) => city.isVisited).toList();
      } else if (filter == CityFilter.notVisited) {
        filteredCities = cities.where((city) => !city.isVisited).toList();
      } else if (filter == CityFilter.all) {
        filteredCities = cities;
      }
    });
  }

  void addCity(City nuovaCitta) {
    // logica per aggiungere la nuova città all'elenco
    setState(() {
      // quando aggiorno lo stato, sostituisco l'elenco precedente con un nuovo elenco
      filteredCities = [nuovaCitta, ...filteredCities];
    });
    // print(nuovaCitta.name);
  }

  void deleteCity(String idCitta) {
    // logica per rimuovere una città dalla lista
    setState(() {
      // filtro l'array rimuovendo l'id della città da eliminare
      filteredCities = filteredCities
          .where((citta) => citta.id != idCitta)
          .toList();
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
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: const Color.fromARGB(255, 183, 157, 224),
        title: Text('Viaggi'),
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
      body: CityList(filteredCities: filteredCities, rimuoviCitta: deleteCity),
    );
  }
}
