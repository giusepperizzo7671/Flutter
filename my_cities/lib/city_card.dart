import 'package:my_cities/city_detail_screen.dart';
import 'package:my_cities/add_note.dart';
import 'package:my_cities/models/city.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_cities/screens/grid_screen.dart';
import 'package:my_cities/db_helper.dart';
import 'dart:io';

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
  // nota salvata per questa città, null se non ancora caricata dal db
  String? _nota;

  // istanza del database helper per leggere e scrivere le note e lo stato
  final DbHelper _dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    // carica la nota e lo stato isVisited dal database quando il widget
    // viene creato, usando l'id della città come chiave univoca
    _caricaNota();
    _caricaIsVisited();
  }

  // legge la nota dal database SQLite usando l'id della città come chiave
  Future<void> _caricaNota() async {
    final nota = await _dbHelper.leggiNota(widget.city.id);
    setState(() {
      _nota = nota;
      widget.city.note = nota;
    });
  }

  // salva la nota nel database SQLite e aggiorna lo stato del widget
  Future<void> _salvaNota(String testo) async {
    await _dbHelper.salvaNota(widget.city.id, testo);
    setState(() {
      _nota = testo;
      widget.city.note = testo;
    });
  }

  // carica lo stato isVisited dal database.
  // se non è mai stato salvato, mantiene il valore iniziale del modello
  Future<void> _caricaIsVisited() async {
    final isVisited = await _dbHelper.leggiIsVisited(widget.city.id);
    if (isVisited != null) {
      setState(() {
        widget.city.isVisited = isVisited;
      });
    }
  }

  // salva lo stato isVisited nel database SQLite e aggiorna l'UI.
  // SQLite non ha boolean: usa 1 per true e 0 per false internamente
  Future<void> _salvaIsVisited(bool valore) async {
    await _dbHelper.salvaIsVisited(widget.city.id, valore);
    setState(() {
      widget.city.isVisited = valore;
    });
  }

  // costruisce il widget immagine in base al tipo di percorso.
  // se il percorso inizia con '/' è un file locale importato dalla galleria,
  // altrimenti è un asset dell'app nella cartella Assets/images/
  Widget _buildImmagineCard() {
    final path = widget.city.imageName;

    // nessuna immagine: mostra placeholder con icona fotocamera
    if (path == null) {
      return Container(
        height: 150,
        width: double.infinity,
        color: Colors.grey.shade900,
        child: const Center(
          child: Icon(Icons.photo_camera, color: Colors.white38, size: 48),
        ),
      );
    }

    // immagine locale importata dalla galleria del telefono.
    // Image.file legge il file dal percorso assoluto sul dispositivo
    if (path.startsWith('/')) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 150,
        // errorBuilder mostra un placeholder se il file non esiste più
        errorBuilder: (context, error, stack) => Container(
          height: 150,
          color: Colors.grey.shade900,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white38, size: 40),
          ),
        ),
      );
    }

    // immagine asset dell'app nella cartella Assets/images/
    return Image(
      fit: BoxFit.cover,
      width: double.infinity,
      height: 150,
      image: AssetImage('Assets/images/$path'),
      errorBuilder: (context, error, stack) => Container(
        height: 150,
        color: Colors.grey.shade900,
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white38, size: 40),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // InkWell aggiunge un effetto visivo (ripple) quando si clicca sulla card,
    // e gestisce l'evento onTap per navigare alla schermata di dettaglio.
    // In questo modo tutta la card è cliccabile, non solo un bottone.
    return InkWell(
      onTap: () {
        // Navigator.push aggiunge una nuova schermata sopra quella corrente,
        // come impilare un foglio sopra un altro.
        // MaterialPageRoute definisce la schermata da mostrare
        // e l'animazione di transizione.
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
          color: Colors.black,
          border: Border.all(
            // bordo blu se visitata, verde se non visitata
            color: widget.city.isVisited ? Colors.blue : Colors.green,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // SizedBox con altezza fissa per contenere l'immagine della città.
            // _buildImmagineCard sceglie automaticamente il tipo corretto
            // di Image widget in base al percorso
            SizedBox(
              height: 150,
              width: double.infinity,
              child: _buildImmagineCard(),
            ),

            const SizedBox(height: 8),

            // Row principale con gli elementi distribuiti su tutta la larghezza
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // bottone switch per cambiare lo stato visitata/non visitata.
                // GestureDetector intercetta il tap senza effetto ripple,
                // così non interferisce con il tap dell'InkWell della card.
                // salva il nuovo stato nel database ad ogni tap
                GestureDetector(
                  onTap: () async {
                    await _salvaIsVisited(!widget.city.isVisited);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      // colore del bottone diverso in base allo stato
                      color: widget.city.isVisited
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        // bordo blu se visitata, verde se non visitata
                        color: widget.city.isVisited
                            ? Colors.blue
                            : Colors.green,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          // icona diversa in base allo stato
                          widget.city.isVisited
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: widget.city.isVisited
                              ? Colors.blue
                              : Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        // testo diverso in base allo stato
                        Text(
                          widget.city.isVisited ? 'Visitata' : 'Non visitata',
                          style: TextStyle(
                            color: widget.city.isVisited
                                ? Colors.blue
                                : Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // nome e paese della città con font Playfair Display.
                // copyWith sovrascrive solo i campi specificati,
                // mantenendo il resto dello stile dal tema
                Text(
                  '${widget.city.name}, ${widget.city.country}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

                    // bottone per aggiungere o modificare la nota della città.
                    // cambia colore in base alla presenza di una nota salvata:
                    // verde se esiste già una nota, grigio se non c'è.
                    // showModalBottomSheet apre un pannello dal basso
                    // senza navigare in una nuova schermata
                    IconButton(
                      icon: Icon(
                        Icons.note_add,
                        // verde se c'è già una nota salvata, grigio se non c'è
                        color: _nota != null && _nota!.isNotEmpty
                            ? Colors.green
                            : Colors.blueGrey,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => AddNote(
                            // passa la nota già salvata così l'utente
                            // può modificarla invece di riscriverla
                            initialNote: _nota,
                            onSave: (text) async {
                              // salva la nota nel database SQLite
                              await _salvaNota(text);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            // il solo feedback visivo per nota e isVisited è il cambio di
            // colore delle rispettive icone — nessuna anteprima testo sulla card
          ],
        ),
      ),
    );
  }
}
