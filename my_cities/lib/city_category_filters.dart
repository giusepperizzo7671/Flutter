import 'package:flutter/material.dart';

enum CityFilter { visited, notVisited, all }

// in questo widget metto i pulsanti per filtrare le città per categoria (visitata, non visitata, tutte).
class CityCategoryFilters extends StatelessWidget {
  const CityCategoryFilters({
    super.key,
    // mi serve una funzione per filtrare le città, che passo come prop da CityScreen.
    required this.filtraCitta,
  });

  // devo definire il tipo della funzione che passo come prop, così so esattamente quali argomenti accetta e posso usarla direttamente nel widget.
  final void Function(CityFilter) filtraCitta;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        TextButton(
          onPressed: () {
            filtraCitta(CityFilter.visited);
          },
          // style: TextButton.styleFrom(
          //   backgroundColor: Colors.green,
          //   foregroundColor: Colors.white,
          //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          // ),
          child: Text('Città visitate'),
        ),
        TextButton(
          onPressed: () {
            filtraCitta(CityFilter.notVisited);
          },
          style: TextButton.styleFrom(
            // backgroundColor: Colors.blue,
            // foregroundColor: Colors.white,
            // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          child: Text('Città non visitate'),
        ),
        TextButton(
          onPressed: () {
            filtraCitta(CityFilter.all);
          },
          style: TextButton.styleFrom(
            // backgroundColor: Colors.blue,
            // foregroundColor: Colors.white,
            // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          child: Text('Tutte'),
        ),
      ],
    );
  }
}
