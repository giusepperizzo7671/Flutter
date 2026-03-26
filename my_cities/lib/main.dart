import 'package:flutter/material.dart';
import 'package:my_cities/city_list.dart';
import 'package:my_cities/random_city.dart';
import 'package:my_cities/titolo.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 86, 78, 247),
          title: Titolo('Elenco città', dimensione: 25),
          //title: Text('Elenco città'),
          //foregroundColor: const Color.fromARGB(255, 37, 38, 38),
        ),
        backgroundColor: const Color.fromARGB(255, 11, 11, 11),
        //body: RandomCity(),
        body: CityList(),
      ),
    );
  }
}
