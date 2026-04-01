import 'package:flutter/material.dart';
import 'package:my_cities/city_screen.dart';

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
      home: CityScreen(),
    );
  }
}
