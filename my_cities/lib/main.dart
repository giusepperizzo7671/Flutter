import 'package:flutter/material.dart';
import 'package:my_cities/screens/splash_screen.dart';
import 'package:my_cities/screens/city_screen.dart';
import 'package:my_cities/screens/grid_screen.dart';
import 'package:my_cities/screens/random_city.dart';

var temaChiaro = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 10, 39, 84),
);
var temaScuro = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 3, 3, 3),
);

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        colorScheme: temaScuro,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 10, 10, 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          ),
        ),
        textTheme: ThemeData().textTheme.copyWith(
          titleLarge: const TextStyle(fontSize: 24),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(colorScheme: temaScuro),

      // all'avvio mostra la splash screen.
      // Da lì l'utente viene reindirizzato a HomeScreen con pushReplacement
      home: const SplashScreen(),
    );
  }
}

// HomeScreen è il contenitore principale con la bottom navigation bar.
// Viene mostrata dopo la splash screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // indice della tab attualmente selezionata
  int _tabSelezionata = 0;

  // lista delle schermate corrispondenti alle tab
  final List<Widget> _schermate = [
    const CityScreen(),
    const SplashScreen(),
    const GridScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body mostra la schermata corrispondente alla tab selezionata
      body: _schermate[_tabSelezionata],

      // bottomNavigationBar è la barra in fondo con le tre tab
      bottomNavigationBar: BottomNavigationBar(
        // currentIndex tiene traccia di quale tab è selezionata
        currentIndex: _tabSelezionata,

        // onTap viene chiamato quando l'utente clicca su una tab,
        // e aggiorna l'indice della tab selezionata con setState
        onTap: (index) {
          setState(() {
            _tabSelezionata = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Città'),
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_on), label: 'Griglia'),
        ],
      ),
    );
  }
}
