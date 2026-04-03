import 'package:flutter/material.dart';
import 'package:my_cities/models/city.dart';
import 'package:uuid/uuid.dart';

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

  void submitCity() {
    // con il metodo .text leggo il testo che l'utente ha inserito nell'input
    final cityName = cityNameController.text;
    final countryName = countryNameController.text;

    // creo nuova città da inserire nell'elenco, prendendo i testi inseriti dall'utente
    City newCity = City(
      name: cityName,
      country: countryName,
      isVisited: false,
      id: uuid.v4(),
    );

    // chiamo la funzione per aggiungere la nuova città
    widget.aggiungiCitta(newCity);

    // chiudo la finestra
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return (Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Add city',
            // theme.of(context) è un modo per accedere al tema dell'applicazione, e quindi ai colori, ai font, etc. definiti nel tema. In questo caso, prendo lo stile titleLarge del tema, e lo modifico con copyWith per cambiare solo il colore, mantenendo tutte le altre proprietà dello stile originale. In questo modo, si può avere uno stile coerente per tutti i titoli dell'applicazione, e modificarlo facilmente in un unico posto, cambiando il tema dell'applicazione.
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              // per il colore uso il colore primary del colorScheme, che è il colore principale del tema, e che si adatta bene per i titoli.
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 24),
          TextField(
            // assegno il controller all'input di testo per poter leggere il contenuto digitato dall'utente
            controller: cityNameController,
            decoration: InputDecoration(
              label: Text('City name'),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 24),
          TextField(
            controller: countryNameController,
            // keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              label: Text('Country name'),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(onPressed: submitCity, child: Text('Add new city')),
        ],
      ),
    ));
  }
}
