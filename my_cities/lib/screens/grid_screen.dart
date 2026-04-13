import 'package:flutter/material.dart';
import 'package:my_cities/data/cities.dart';

class GridScreen extends StatelessWidget {
  const GridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Griglia esempio')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 24,
          childAspectRatio: 16 / 9,
        ),
        itemCount: cities.length,
        itemBuilder: (context, i) {
          final city = cities[i];

          return Container(
            key: Key(city.id),
            child: Card(child: Center(child: Text(city.name))),
          );
        },
      ),
    );
  }
}
