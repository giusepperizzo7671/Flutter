// widget per mostrare una card per ogni città
import 'package:my_cities/models/city.dart';
import 'package:flutter/material.dart';

class CityCard extends StatelessWidget {
  // accetto una città come prop, per mostrare i suoi dettagli nella card
  const CityCard({super.key, required this.city});
  // uso City come tipo per la prop, così so esattamente quali campi ha e posso usarli direttamente.
  final City city;

  //alternativa con props separate:
  // const CityCard({super.key, required this.name, required this.country, required this.isVisited, this.imageName});
  // final String name;
  // final String country;
  // final bool isVisited;
  // final String? imageName;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: city.isVisited
            ? const Color.fromARGB(255, 205, 214, 208)
            : const Color.fromARGB(255, 245, 196, 158),
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          city.imageName != null
              ? Image(
                  height: 100,
                  width: 125,
                  image: AssetImage('Assets/images/${city.imageName}'),
                )
              : Container(
                  height: 100,
                  width: 125,
                  color: Colors.grey,
                  child: const Center(
                    child: Text(
                      'Ops, no image!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${city.name}, ${city.country}',
                style: TextStyle(fontSize: 16), //fontWeight: FontWeight.bold),
              ),
              Icon(
                city.isVisited ? Icons.check_circle : Icons.cancel,
                color: city.isVisited
                    ? Colors.green
                    : const Color.fromARGB(255, 126, 123, 123),
              ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
