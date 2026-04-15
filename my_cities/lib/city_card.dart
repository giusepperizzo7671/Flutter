import 'package:my_cities/city_detail_screen.dart';
import 'package:my_cities/add_note.dart';
import 'package:my_cities/models/city.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_cities/screens/grid_screen.dart';

class CityCard extends StatelessWidget {
  // accetto una città come prop, per mostrare i suoi dettagli nella card
  const CityCard({super.key, required this.city});

  // uso City come tipo per la prop, così so esattamente quali campi ha
  // e posso usarli direttamente senza props separate
  final City city;

  @override
  Widget build(BuildContext context) {
    // InkWell aggiunge un effetto visivo (ripple) quando si clicca sulla card,
    // e gestisce l'evento onTap per navigare alla schermata di dettaglio.
    // In questo modo tutta la card è cliccabile, non solo un bottone.
    return InkWell(
      onTap: () {
        // Navigator.push aggiunge una nuova schermata sopra quella corrente,
        // come impilare un foglio sopra un altro.
        // MaterialPageRoute definisce la schermata da mostrare e l'animazione di transizione.
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CityDetailScreen(city: city)),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),

        decoration: BoxDecoration(
          // colore diverso in base allo stato isVisited:
          // verde chiaro se visitata, rosso chiaro se non visitata
          color: city.isVisited
              ? const Color.fromARGB(255, 213, 246, 176)
              : const Color.fromARGB(255, 252, 184, 184),
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // SizedBox con altezza fissa per contenere l'immagine della città.
            // width: double.infinity fa sì che l'immagine occupi tutta la larghezza della card.
            SizedBox(
              height: 150,
              width: double.infinity,
              // operatore ternario: se imageName non è null mostra l'immagine,
              // altrimenti mostra un container grigio con un messaggio di errore
              child: city.imageName != null
                  ? Image(
                      fit: BoxFit
                          .cover, // riempie il SizedBox ritagliando l'immagine se necessario
                      image: AssetImage('Assets/images/${city.imageName}'),
                    )
                  : Container(
                      height: 150,
                      width: 200,
                      color: Colors.grey,
                      child: const Center(
                        child: Text(
                          "Ops, manca l'immagine!",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 1),

            // Row principale con i tre elementi distribuiti su tutta la larghezza
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // icona che indica se la città è stata visitata o meno
                Icon(
                  city.isVisited ? Icons.check_circle : Icons.cancel,
                  color: city.isVisited ? Colors.green : Colors.red,
                ),
                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.blueGrey),
                  onPressed: () {
                    // Navigator.push apre GridScreen passando la città corrente
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GridScreen(city: city),
                      ),
                    );
                  },
                ),

                // nome e paese della città con font Playfair Display
                Text(
                  '${city.name}, ${city.country}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    // copyWith sovrascrive solo i campi specificati,
                    // mantenendo il resto dello stile dal tema
                    fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                    color: Colors.black,
                  ),
                ),

                // bottone per aggiungere una nota alla città.
                // showModalBottomSheet apre un pannello dal basso
                // senza navigare in una nuova schermata
                IconButton(
                  icon: const Icon(Icons.note_add, color: Colors.blueGrey),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => AddNote(onSave: (String p1) {}),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
