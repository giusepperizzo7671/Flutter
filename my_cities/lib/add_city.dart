import 'package:flutter/material.dart';
import 'package:my_cities/models/city.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

var uuid = Uuid();

class AddCity extends StatefulWidget {
  const AddCity({super.key, required this.aggiungiCitta});

  final void Function(City) aggiungiCitta;

  @override
  State<AddCity> createState() => _AddCityState();
}

class _AddCityState extends State<AddCity> {
  final cityNameController = TextEditingController();
  final countryNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String erroreNomeCitta = '';
  String erroreNomePaese = '';

  // percorso locale dell'immagine di copertina selezionata dalla galleria.
  // null se l'utente non ha ancora selezionato nessuna immagine
  String? _percorsoImmagine;

  // apre la galleria del telefono per selezionare l'immagine di copertina.
  // pickImage permette di selezionare una sola immagine
  Future<void> _selezionaImmagine() async {
    try {
      final XFile? immagine = await _picker.pickImage(
        source: ImageSource.gallery,
        // riduce la qualità per non occupare troppa memoria
        imageQuality: 85,
      );
      if (immagine != null) {
        setState(() {
          _percorsoImmagine = immagine.path;
        });
      }
    } catch (e) {
      print('ERRORE selezione immagine: $e');
    }
  }

  void submitCity() {
    final cityName = cityNameController.text;
    final countryName = countryNameController.text;

    // controlla che i campi obbligatori non siano vuoti
    if (cityName.trim().isEmpty || countryName.trim().isEmpty) {
      setState(() {
        erroreNomeCitta = cityName.trim().isEmpty
            ? 'Inserisci il nome della città'
            : '';
        erroreNomePaese = countryName.trim().isEmpty
            ? 'Inserisci il nome del paese'
            : '';
      });
      return;
    }

    // crea la nuova città con il percorso dell'immagine se selezionata.
    // imageName contiene il percorso assoluto se è un'immagine dalla galleria,
    // altrimenti rimane null e la card mostrerà il placeholder grigio
    City newCity = City(
      name: cityName.trim(),
      country: countryName.trim(),
      isVisited: false,
      id: uuid.v4(),
      imageName: _percorsoImmagine, // 👈 percorso locale o null
    );

    widget.aggiungiCitta(newCity);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    cityNameController.dispose();
    countryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 32.0,
            right: 32.0,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 48.0,
          ),
          child: Column(
            spacing: 12,
            children: [
              Text(
                'Aggiungi città',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              // anteprima immagine di copertina selezionata.
              // se non è stata selezionata nessuna immagine mostra
              // un placeholder con il bottone per aprire la galleria
              GestureDetector(
                onTap: _selezionaImmagine,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: _percorsoImmagine != null
                      // mostra l'anteprima dell'immagine selezionata
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_percorsoImmagine!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      // placeholder con icona e testo se nessuna immagine
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Colors.white38,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tocca per aggiungere copertina',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // bottone per cambiare immagine se già selezionata
              if (_percorsoImmagine != null)
                TextButton.icon(
                  onPressed: _selezionaImmagine,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Cambia immagine'),
                ),

              // campo nome città
              TextField(
                controller: cityNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  label: const Text('Nome città'),
                  border: const OutlineInputBorder(),
                  errorText: erroreNomeCitta.isNotEmpty
                      ? erroreNomeCitta
                      : null,
                ),
              ),

              // campo nome paese
              TextField(
                controller: countryNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  label: const Text('Nome paese'),
                  border: const OutlineInputBorder(),
                  errorText: erroreNomePaese.isNotEmpty
                      ? erroreNomePaese
                      : null,
                ),
              ),

              // bottone per salvare la nuova città
              ElevatedButton(
                onPressed: submitCity,
                child: const Text('Aggiungi città'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
