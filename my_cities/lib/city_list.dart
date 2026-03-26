import 'package:flutter/material.dart';
import 'package:my_cities/city_card.dart';
import 'package:my_cities/data/cities.dart';
import 'package:my_cities/models/city.dart';

enum Filtrocitta { visitate, nonvisitate, tutte }

class CityList extends StatefulWidget {
  const CityList({super.key});
  @override
  _CityListState createState() => _CityListState();
}

class _CityListState extends State<CityList> {
  //filtercities nome inventato per filtrare citta visitate, non visitate e tutte
  var filteredCities = cities;
  // funzione per filtrare città: visitate, non visitate, tutte
  void filterCities(Filtrocitta filter) {
    setState(() {
      if (filter == Filtrocitta.visitate) {
        filteredCities = cities.where((city) => city.isVisited).toList();
      } else if (filter == Filtrocitta.tutte) {
        filteredCities = cities;
      } else if (filter == Filtrocitta.nonvisitate) {
        filteredCities = cities.where((city) => !city.isVisited).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // elenco semplice con map
    // return (Column(children: cities.map((city) => Text(city.name)).toList()));
    // un elenco preso da una lista. con ListView.builder, che è più efficiente per liste lunghe
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => filterCities(Filtrocitta.visitate),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
                child: Text('Città visitate'),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  filterCities(Filtrocitta.tutte);
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 92, 76, 175),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
                child: Text('tutte'),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  filterCities(Filtrocitta.nonvisitate);
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 175, 76, 84),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
                child: Text('Non visitate'),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredCities.length,
            itemBuilder: (context, i) {
              final city = filteredCities[i];
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
              return CityCard(city: city);
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
