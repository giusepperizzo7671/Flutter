import 'package:flutter/material.dart';
import 'package:my_cities/city_card.dart';
import 'package:my_cities/data/cities.dart';
import 'package:my_cities/models/city.dart';

// enum CityFilter { visited, notVisited, all }

class CityList extends StatefulWidget {
  const CityList({
    super.key,
    required this.filteredCities,
    required this.rimuoviCitta,
    // required this.filtraCitta,
  });

  final List<City> filteredCities;
  final void Function(String) rimuoviCitta;
  // final void Function(CityFilter) filtraCitta;

  @override
  State<CityList> createState() => _CityListState();
}

class _CityListState extends State<CityList> {
  @override
  Widget build(BuildContext context) {
    // elenco semplice con map
    // return (Column(children: cities.map((city) => Text(city.name)).toList()));
    // un elenco preso da una lista. con ListView.builder, che è più efficiente per liste lunghe
    // operatore ternario: condizione ? codice se condizione è vera : codice se condizione è falsa
    return widget.filteredCities.isEmpty
        ? Center(child: Text('Nessuna città'))
        : ListView.builder(
            itemCount: widget.filteredCities.length,
            itemBuilder: (context, i) {
              final city = widget.filteredCities[i];
              // Esempio di come mostrare ogni città in una riga semplice, con nome, immagine e paese.
              //     return Row(
              //       children: [
              //         Text(city.name),
              //         Image(
              //           image: AssetImage('assets/images/${city.imageName}'),
              //           width: 200,
              //         ),
              //         Text(city.country),
              //       ],
              //     );
              // uso il widget CityCard per mostrare ogni città in una card.
              // posso passare city come prop, oppure passare i singoli campi come props separate.
              return Dismissible(
                key: Key(city.id),
                // direzione in cui è possibile trascinare per eliminare
                direction: DismissDirection.endToStart,
                // azione da eseguire quando la card viene trascinata via
                onDismissed: (direction) {
                  widget.rimuoviCitta(city.id);
                },
                // posso personalizzare lo sfondo che appare quando trascino la card, ad esempio con un'icona di cancellazione e uno sfondo colorato
                // ClipRRect è un widget che permette di ritagliare il suo child con bordi arrotondati, in questo caso con un raggio di 8 pixel.
                // Lo sfondo rosso avrà bordi arrotondati, che si adattano meglio alla forma della card.
                background: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                ),
                child: CityCard(city: city),
              );
              // alternativa con props separate:
              // return CityCard(
              //   name: city.name,
              //   country: city.country,
              //   isVisited: city.isVisited,
              //   imageName: city.imageName,
              // );
            },
          );
  }
}
