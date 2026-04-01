import 'package:flutter/material.dart';
import 'package:my_cities/city_card.dart';
import 'package:my_cities/data/cities.dart';
import 'package:my_cities/models/city.dart';

enum Filtrocitta { visitate, nonVisitate, tutte }

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
      } else if (filter == Filtrocitta.nonVisitate) {
        filteredCities = cities.where((city) => !city.isVisited).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => filterCities(Filtrocitta.visitate),
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 16, 17, 16),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  side: BorderSide(color: Colors.lightGreenAccent, width: 2),
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
                  backgroundColor: const Color.fromARGB(255, 11, 11, 11),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  side: BorderSide(
                    color: const Color.fromARGB(255, 63, 3, 244),
                    width: 2,
                  ),
                ),
                child: Text('tutte'),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  filterCities(Filtrocitta.nonVisitate);
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 5, 5, 5),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  side: BorderSide(
                    color: const Color.fromARGB(255, 249, 2, 11),
                    width: 2,
                  ),
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
              return CityCard(city: city);
            },
          ),
        ),
      ],
    );
  }
}
