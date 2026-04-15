import 'package:flutter/material.dart';
import 'package:my_cities/models/city.dart';
import 'package:my_cities/data/cities.dart';

class GridScreen extends StatelessWidget {
  const GridScreen({super.key, this.city});

  // city è nullable: se null mostra tutte le immagini, altrimenti solo quelle della città
  final City? city;

  @override
  Widget build(BuildContext context) {
    // uso late per dichiarare images senza inizializzarla subito,
    // e poi la inizializzo nel blocco if/else per evitare problemi di inferenza del tipo
    late final List<String> images;

    if (city != null) {
      // se la città ha una lista di immagini, la uso direttamente
      if (city!.images.isNotEmpty) {
        images = city!.images;
        // altrimenti uso l'immagine principale della card come fallback
      } else if (city!.imageName != null) {
        images = [city!.imageName!];
        // se non ha nessuna immagine, lista vuota
      } else {
        images = [];
      }
    } else {
      // se non è stata passata nessuna città, raccoglie tutte le immagini
      // di tutte le città usando expand, che "appiattisce" le liste in una sola
      images = cities
          .expand<String>(
            (c) => c.images.isNotEmpty
                ? c.images
                : (c.imageName != null ? [c.imageName!] : <String>[]),
          )
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        // titolo dinamico: nome della città se aperto da una card, altrimenti "Galleria"
        title: Text(city != null ? 'Foto di ${city!.name}' : 'Galleria'),
      ),
      body: images.isEmpty
          // se non ci sono immagini mostra un messaggio al centro
          ? const Center(child: Text('Nessuna immagine disponibile'))
          // GridView.builder costruisce la griglia in modo lazy,
          // cioè crea solo i widget visibili sullo schermo
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 colonne
                crossAxisSpacing: 8, // spazio orizzontale tra le immagini
                mainAxisSpacing: 8, // spazio verticale tra le immagini
              ),
              itemCount: images.length,
              itemBuilder: (context, i) {
                // ClipRRect arrotonda gli angoli di ogni immagine
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                    fit: BoxFit
                        .cover, // riempie la cella ritagliando l'immagine se necessario
                    image: AssetImage('Assets/images/${images[i]}'),
                  ),
                );
              },
            ),
    );
  }
}
