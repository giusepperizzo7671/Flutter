import 'package:flutter/material.dart';
import 'package:my_cities/models/city.dart';
import 'package:uuid/uuid.dart';

// uuid è una libreria che permette di generare identificatori univoci, utili per assegnare un id unico a ogni città aggiunta dall'utente, in modo da poterle distinguere facilmente anche se hanno lo stesso nome o paese.
var uuid = Uuid();

class AddCity extends StatefulWidget {
  const AddCity({super.key, required this.aggiungiCitta});

  final void Function(City) aggiungiCitta;

  @override
  State<AddCity> createState() => _AddCityState();
}

class _AddCityState extends State<AddCity> {
  // creo due controller per leggere il valore degli input di testo
  final cityNameController = TextEditingController();
  final countryNameController = TextEditingController();
  String erroreNomeCitta = '';
  String erroreNomePaese = '';

  void submitCity() {
    // con il metodo .text leggo il testo che l'utente ha inserito nell'input
    final cityName = cityNameController.text;
    final countryName = countryNameController.text;

    // logica per controllare che i campi non siano vuoti
    // se il campo city name o country name è vuoto, blocca la funzione (return).
    if (cityName.trim().isEmpty || countryName.trim().isEmpty) {
      // mostro un avviso per dire che sono campi obbligatori
      setState(() {
        erroreNomeCitta = "Inserisci il nome della città";
        erroreNomePaese = "Inserisci il nome del paese";
      });
      return;
    }

    // creo nuova città da inserire nell'elenco, prendendo i testi inseriti dall'utente
    City newCity = City(
      name: cityName.trim(),
      country: countryName.trim(),
      isVisited: false,
      id: uuid.v4(),
    );

    // chiamo la funzione per aggiungere la nuova città
    widget.aggiungiCitta(newCity);

    // chiudo la finestra
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    // è importante chiamare dispose sui controller quando il widget viene distrutto (cioè quando non è più visibile), per liberare le risorse e evitare problemi di memoria.
    cityNameController.dispose();
    countryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap è un widget che permette di avvolgere i suoi figli su più righe.
    // Lo uso per avvolgere il contenuto della modale, in modo che si adatti quando la tastiera è aperta.
    return Wrap(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 32.0,
            right: 32.0,
            top: 24,
            // calcolo il padding bottom in modo dinamico, prendendo in considerazione la presenza della tastiera virtuale (viewInsets.bottom) e aggiungendo un margine extra di 48 pixel per evitare che i contenuti siano troppo vicini alla tastiera.
            bottom: MediaQuery.of(context).viewInsets.bottom + 48.0,
          ),
          child: Column(
            spacing: 12,
            children: [
              Text(
                'Add city',
                // theme.of(context) è un modo per accedere al tema dell'applicazione, e quindi ai colori, ai font, etc. definiti nel tema. In questo caso, prendo lo stile titleLarge del tema, e lo modifico con copyWith per cambiare solo il colore, mantenendo tutte le altre proprietà dello stile originale. In questo modo, si può avere uno stile coerente per tutti i titoli dell'applicazione, e modificarlo facilmente in un unico posto, cambiando il tema dell'applicazione.
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  // per il colore uso il colore primary del colorScheme, che è il colore principale del tema, e che si adatta bene per i titoli.
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              TextField(
                // assegno il controller all'input di testo per poter leggere il contenuto digitato dall'utente
                controller: cityNameController,
                decoration: InputDecoration(
                  label: Text('City name'),
                  border: OutlineInputBorder(),
                ),
              ),
              erroreNomeCitta.isNotEmpty
                  ? Text(
                      erroreNomeCitta,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  : SizedBox.shrink(), // se non c'è errore, mostro un widget vuoto che non occupa spazio
              TextField(
                controller: countryNameController,
                // keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  label: Text('Country name'),
                  border: OutlineInputBorder(),
                  // con errorText posso mostrare un messaggio di errore sotto l'input, che appare solo se c'è un errore (cioè se erroreNomePaese è diverso da stringa vuota).
                  // L'utente ha un feedback visivo chiaro su cosa deve correggere.
                  errorText: erroreNomePaese.isNotEmpty
                      ? erroreNomePaese
                      : null,
                ),
              ),
              // SizedBox(height: 24),
              ElevatedButton(
                onPressed: submitCity,
                child: Text('Add new city'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
