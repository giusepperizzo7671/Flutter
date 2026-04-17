import 'package:my_cities/city_detail_screen.dart';
import 'package:my_cities/add_note.dart';
import 'package:my_cities/models/city.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_cities/screens/grid_screen.dart';

// StatefulWidget perché la card ha uno stato interno che può cambiare:
// isVisited quando l'utente preme il bottone switch, e la nota della città
class CityCard extends StatefulWidget {
  const CityCard({super.key, required this.city});

  // uso City come tipo per la prop, così so esattamente quali campi ha
  // e posso usarli direttamente senza props separate
  final City city;

  @override
  State<CityCard> createState() => _CityCardState();
}

class _CityCardState extends State<CityCard> {
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
          MaterialPageRoute(
            builder: (context) => CityDetailScreen(city: widget.city),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black, // 👈 sfondo nero
          border: Border.all(
            color: widget.city.isVisited
                ? Colors
                      .blue // 👈 blu se visitata
                : Colors.green, // 👈 verde se non visitata
            width: 2,
          ),
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
              child: widget.city.imageName != null
                  ? Image(
                      fit: BoxFit
                          .cover, // riempie il SizedBox ritagliando l'immagine se necessario
                      image: AssetImage(
                        'Assets/images/${widget.city.imageName}',
                      ),
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

            // Row principale con gli elementi distribuiti su tutta la larghezza
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // bottone switch per cambiare lo stato visitata/non visitata.
                // GestureDetector intercetta il tap senza effetto ripple,
                // così non interferisce con il tap dell'InkWell della card
                GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.city.isVisited = !widget.city.isVisited;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.city.isVisited
                          ? Colors.blue.withOpacity(0.2) // 👈 blu se visitata
                          : Colors.green.withOpacity(
                              0.2,
                            ), // 👈 verde se non visitata
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.city.isVisited
                            ? Colors
                                  .blue // 👈 blu se visitata
                            : Colors.green, // 👈 verde se non visitata
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.city.isVisited
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: widget.city.isVisited
                              ? Colors
                                    .blue // 👈 blu se visitata
                              : Colors.green, // 👈 verde se non visitata
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.city.isVisited ? 'Visitata' : 'Non visitata',
                          style: TextStyle(
                            color: widget.city.isVisited
                                ? Colors
                                      .blue // 👈 blu se visitata
                                : Colors.green, // 👈 verde se non visitata
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // nome e paese della città con font Playfair Display
                Text(
                  '${widget.city.name}, ${widget.city.country}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    // copyWith sovrascrive solo i campi specificati,
                    // mantenendo il resto dello stile dal tema
                    fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                    color: const Color.fromARGB(255, 245, 243, 243),
                    fontSize: 18,
                  ),
                ),

                // Row interna per raggruppare le icone a destra
                Row(
                  children: [
                    // bottone per aprire la galleria immagini della città.
                    // Navigator.push apre GridScreen passando la città corrente
                    IconButton(
                      icon: const Icon(
                        Icons.photo_library,
                        color: Colors.blueGrey,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GridScreen(city: widget.city),
                          ),
                        );
                      },
                    ),

                    // bottone per aggiungere una nota alla città.
                    // showModalBottomSheet apre un pannello dal basso
                    // senza navigare in una nuova schermata
                    IconButton(
                      icon: const Icon(Icons.note_add, color: Colors.blueGrey),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => AddNote(
                            // passa la nota già salvata così l'utente può modificarla
                            initialNote: widget.city.note,
                            onSave: (text) {
                              // setState aggiorna la UI dopo aver salvato la nota
                              setState(() {
                                widget.city.note = text;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            // mostra la nota sotto la card solo se esiste e non è vuota
            if (widget.city.note != null && widget.city.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  widget.city.note!,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
