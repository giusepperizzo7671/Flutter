import 'package:flutter/material.dart';
import 'package:my_cities/city_list.dart';
import 'package:my_cities/random_city.dart';
import 'package:my_cities/titolo.dart';

var schemaColore = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 36, 4, 242),
); //colore di base per tutta l'app

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  void showModal() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData().copyWith(
        colorScheme:
            schemaColore, // applica le grasdazioni colore su colore definito nella variabile , giallo in questo caso
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(backgroundColor: Colors.red),
        ),
        textTheme: ThemeData().textTheme.copyWith(
          titleLarge: TextStyle(fontSize: 16),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 15, 17, 8),
          title: Titolo('Elenco città', dimensione: 25),
          //title: Text('Elenco città'),
          //foregroundColor: const Color.fromARGB(255, 37, 38, 38),
          actions: [
            IconButton(
              onPressed: showModal,
              icon: Icon(Icons.add_circle_outline, color: Colors.blue),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 10, 10, 10),
        //body: RandomCity(),
        body: CityList(),
      ),
    );
  }
}
