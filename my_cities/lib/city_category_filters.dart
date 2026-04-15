import 'package:flutter/material.dart';

enum CityFilter { visited, notVisited, all }

// in questo widget metto i pulsanti per filtrare le città per categoria (visitata, non visitata, tutte).
class CityCategoryFilters extends StatelessWidget {
  const CityCategoryFilters({
    super.key,
    // mi serve una funzione per filtrare le città, che passo come prop da CityScreen.
    required this.filtraCitta,
    required this.filtroAttivo, // ← AGGIUNTO: serve per sapere quale bottone è attivo
  });

  // devo definire il tipo della funzione che passo come prop, così so esattamente quali argomenti accetta e posso usarla direttamente nel widget.
  final void Function(CityFilter) filtraCitta;
  final CityFilter
  filtroAttivo; // ← AGGIUNTO: il filtro attualmente selezionato

  // restituisce il bordo giusto in base al filtro attivo
  BorderSide _getBordo(CityFilter filtro) {
    if (filtro == CityFilter.all) {
      return const BorderSide(color: Colors.red, width: 2);
    } else if (filtro == CityFilter.visited) {
      return const BorderSide(color: Colors.blue, width: 2);
    } else {
      return const BorderSide(color: Colors.green, width: 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              filtraCitta(CityFilter.visited);
            },
            style: TextButton.styleFrom(
              // style viene applicato solo se il filtro attivo è "visited",
              // altrimenti il bottone usa lo stile di default del tema
              side: filtroAttivo == CityFilter.visited
                  ? _getBordo(CityFilter.visited)
                  : null,
            ),
            // style: TextButton.styleFrom(
            //   backgroundColor: Colors.green,
            //   foregroundColor: Colors.white,
            //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            // ),
            child: Text('Visitate'),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () {
              filtraCitta(CityFilter.notVisited);
            },
            style: TextButton.styleFrom(
              // style viene applicato solo se il filtro attivo è "notVisited"
              side: filtroAttivo == CityFilter.notVisited
                  ? _getBordo(CityFilter.notVisited)
                  : null,
              // backgroundColor: Colors.blue,
              // foregroundColor: Colors.white,
              // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
            child: Text('Non visitate'),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () {
              filtraCitta(CityFilter.all);
            },
            style: TextButton.styleFrom(
              // style viene applicato solo se il filtro attivo è "all"
              side: filtroAttivo == CityFilter.all
                  ? _getBordo(CityFilter.all)
                  : null,
              // backgroundColor: Colors.blue,
              // foregroundColor: Colors.white,
              // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
            child: Text('Tutte'),
          ),
        ),
      ],
    );
  }
}
