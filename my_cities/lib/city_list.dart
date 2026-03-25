import 'package:flutter/material.dart';
import 'package:my_cities/city_card.dart';
import 'package:my_cities/data/cities.dart';

class CityList extends StatelessWidget {
  const CityList({super.key});

  @override
  Widget build(BuildContext context) {
    // elenco semplice con map
    // return (Column(children: cities.map((city) => Text(city.name)).toList()));
    // un elenco preso da una lista. con ListView.builder, che è più efficiente per liste lunghe
    return ListView.builder(
      itemCount: cities.length,
      itemBuilder: (context, i) {
        final city = cities[i];
        // Esempio di come mostrare ogni città in una riga semplice, con nome, immagine e paese.
        //     return Row(
        //       children: [
        //         Text(city.name),
        //         Image(
        //           image: AssetImage('assets/images/${city.imageName}'),
        //           width: 200,
        //         ),
        //         Text(city.country),
        //       ],
        //     );
        // uso il widget CityCard per mostrare ogni città in una card.
        // posso passare city come prop, oppure passare i singoli campi come props separate.
        return CityCard(city: city);
        // alternativa con props separate:
        // return CityCard(
        //   name: city.name,
        //   country: city.country,
        //   isVisited: city.isVisited,
        //   imageName: city.imageName,
        // );
      },
    );
  }
}
