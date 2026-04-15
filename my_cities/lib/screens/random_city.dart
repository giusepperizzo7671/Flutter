import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'city_screen.dart';
import 'dart:math';

import 'package:my_cities/titolo.dart';

var random = Random();
var randomcities = fotografie;
var fotografie = [
  'beijing',
  'berlin',
  'london',
  'Camaleonte',
  'mumbai',
  'new_york',
  'paris',
  'rio_de_janeiro',
  'singapore',
  'sydney',
  'tokyo',
];

class RandomCity extends StatefulWidget {
  const RandomCity({super.key});

  @override
  State<RandomCity> createState() => _RandomCityState();
}

class _RandomCityState extends State<RandomCity> {
  var city = randomcities[0];
  var immagineSelezionata = 'Lightpainting-2';
  var fotocitta = fotografie[0];
  void prova() {
    setState(() {
      //int randomNumber = random.nextInt(cities.length);
      int randomfoto = random.nextInt(fotografie.length);
      // city = cities[randomNumber];
      fotocitta = fotografie[randomfoto];
      city = fotocitta;
      //secondariga = 'dopo camaleonte';
      //immagineSelezionata = 'Camaleonte';
      //print(random.nextInt(5));
    });
    // print(saluto);
    // print(secondariga);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image(
          image: AssetImage('Assets/images/$fotocitta.jpg'),
          width: 500,
          height: 250,
        ),
        Titolo('primo titolo', dimensione: 30),
        Text(city),

        //  Image(image: AssetImage('Assets/images/Camaleonte.jpg')),
        // Text(secondariga),
        TextButton(
          onPressed: prova,
          child: Text(
            'Scegli una città',
            style: TextStyle(
              color: const Color.fromARGB(255, 3, 3, 3),
              fontWeight: FontWeight(100),
            ),
          ),
        ),
        //Column(children: randomcities.map((city) => Text(city)).toList()),
        Titolo('secondo titolo'),
        ElevatedButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => CityScreen()));
          },
          child: Text('City screen'),
        ),
      ],
    );
  }
}
