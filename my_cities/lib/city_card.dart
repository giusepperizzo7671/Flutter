// widget per mostrare una card per ogni città
import 'package:my_cities/city_detail_screen.dart';
import 'package:my_cities/models/city.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    // Inkwell è un widget che permette di aggiungere un effetto visivo quando si clicca su un elemento, come una card.
    // In questo caso, avvolgo la card con un InkWell, e definisco l'evento onTap per navigare alla schermata di dettaglio della città quando la card viene cliccata.
    // In questo modo, l'utente può cliccare su qualsiasi parte della card per vedere i dettagli della città, e ha anche un feedback visivo che indica che la card è cliccabile.
    return InkWell(
      onTap: () {
        // Naviga alla schermata di dettaglio della città quando la card viene cliccata
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CityDetailScreen(city: city)),
        );
      },

      child: Container(
        margin: const EdgeInsets.all(8),
        // margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: city.isVisited
              ? const Color.fromARGB(255, 158, 198, 111)
              : const Color.fromARGB(255, 238, 169, 169),
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: city.imageName != null
                  ? Image(
                      // height: 200,
                      // width: 250,
                      fit: BoxFit.cover,
                      // alignment: Alignment.bottomLeft,
                      image: AssetImage('assets/images/${city.imageName}'),
                    )
                  : Container(
                      height: 200,
                      width: 250,
                      color: Colors.grey,
                      child: Center(
                        child: Text(
                          'Ops, no image!',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${city.name}, ${city.country}',
                  // style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // style: GoogleFonts.pacifico(fontSize: 20),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: GoogleFonts.pacifico().fontFamily,
                  ),
                ),
                Icon(
                  city.isVisited ? Icons.check_circle : Icons.cancel,
                  color: city.isVisited ? Colors.green : Colors.red,
                ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
