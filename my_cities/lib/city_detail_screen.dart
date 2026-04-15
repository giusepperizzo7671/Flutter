import 'package:flutter/material.dart';
import 'package:my_cities/models/city.dart';

// esempio di schermata di dettaglio di una città, che mostra il nome della città, se è stata visitata o meno, e l'id della città. Questa schermata viene mostrata quando si clicca su una città nella lista delle città.
class CityDetailScreen extends StatelessWidget {
  const CityDetailScreen({super.key, required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(city.name)),
      body: Center(
        child: Text(
          style: TextStyle(color: Colors.greenAccent),
          'Dettagli della città: ${city.name}, visitata: ${city.isVisited}, id: ${city.id}, note :${city.note}',
        ),
      ),
    );
  }
}
