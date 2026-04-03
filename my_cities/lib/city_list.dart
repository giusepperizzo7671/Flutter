import 'package:flutter/material.dart';
import 'package:my_cities/city_card.dart';
import 'package:my_cities/data/cities.dart';
import 'package:my_cities/models/city.dart';

enum CityFilter { visited, notVisited, all }

class CityList extends StatefulWidget {
  const CityList({
    super.key,
    required this.filteredCities,
    required this.rimuoviCitta,
  });

  final List<City> filteredCities;
  final void Function(String) rimuoviCitta;

  @override
  State<CityList> createState() => _CityListState();
}

class _CityListState extends State<CityList> {
  @override
  Widget build(BuildContext context) {
    // elenco semplice con map
    // return (Column(children: cities.map((city) => Text(city.name)).toList()));
    // un elenco preso da una lista. con ListView.builder, che è più efficiente per liste lunghe
    return Column(
      children: [
        // Row(
        //   spacing: 8,
        //   children: [
        //     TextButton(
        //       onPressed: () {
        //         filterCities(CityFilter.visited);
        //       },
        //       // style: TextButton.styleFrom(
        //       //   backgroundColor: Colors.green,
        //       //   foregroundColor: Colors.white,
        //       //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        //       // ),
        //       child: Text('Città visitate'),
        //     ),
        //     TextButton(
        //       onPressed: () {
        //         filterCities(CityFilter.notVisited);
        //       },
        //       style: TextButton.styleFrom(
        //         // backgroundColor: Colors.blue,
        //         // foregroundColor: Colors.white,
        //         // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        //       ),
        //       child: Text('Città non visitate'),
        //     ),
        //     TextButton(
        //       onPressed: () {
        //         filterCities(CityFilter.all);
        //       },
        //       style: TextButton.styleFrom(
        //         // backgroundColor: Colors.blue,
        //         // foregroundColor: Colors.white,
        //         // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        //       ),
        //       child: Text('Tutte'),
        //     ),
        //   ],
        // ),
        // expanded serve per riempire lo spazio disponibile, altrimenti ListView.builder non sa quanto spazio ha a disposizione e dà errore.
        Expanded(
          child: ListView.builder(
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
                onDismissed: (direction) {
                  widget.rimuoviCitta(city.id);
                },
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
          ),
        ),
      ],
    );
  }
}
