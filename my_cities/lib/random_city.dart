import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

var random = Random();
var cities = fotografie;
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
  var city = cities[0];
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
        Column(children: cities.map((city) => Text(city)).toList()),
      ],
    );
  }
}
