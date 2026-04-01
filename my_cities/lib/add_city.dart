import 'package:flutter/material.dart';

class AddCity extends StatefulWidget {
  const AddCity({super.key});

  @override
  State<AddCity> createState() => _AddCityState();
}

class _AddCityState extends State<AddCity> {
  @override
  Widget build(BuildContext context) {
    return (Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Nuova città',
            // theme.of(context) è un modo per accedere al tema dell'applicazione, e quindi ai colori, ai font, etc. definiti nel tema. In questo caso, prendo lo stile titleLarge del tema, e lo modifico con copyWith per cambiare solo il colore, mantenendo tutte le altre proprietà dello stile originale. In questo modo, si può avere uno stile coerente per tutti i titoli dell'applicazione, e modificarlo facilmente in un unico posto, cambiando il tema dell'applicazione.
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              // per il colore uso il colore primary del colorScheme, che è il colore principale del tema, e che si adatta bene per i titoli.
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              label: Text('Città'),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 24),
          TextField(
            // keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              label: Text('Paese'),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, child: Text('Aggiungi')),
        ],
      ),
    ));
  }
}
