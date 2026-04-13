import 'package:flutter/material.dart';

class CityTextFilter extends StatefulWidget {
  const CityTextFilter({super.key, required this.aggiornaFiltro});

  final void Function(String) aggiornaFiltro;

  @override
  State<CityTextFilter> createState() => _CityTextFilter();
}

class _CityTextFilter extends State<CityTextFilter> {
  // questa stringa serve come esempio per mostrare il testo digitato.
  // String testoDigitato = '';

  // Quando utente digita qualcosa, questa funzione viene chiamata con il testo digitato come argomento.
  void leggiTestoDigitato(String testoInput) {
    // A questo punto, posso aggiornare lo stato del filtro nella pagina principale, chiamando la funzione aggiornaFiltro che ho ricevuto come prop da CityScreen, e passando il testo digitato come argomento.
    // In questo modo, la pagina principale può filtrare le città in base al testo digitato, e mostrare solo quelle che corrispondono al filtro.
    widget.aggiornaFiltro(testoInput);

    // esempio per mostrare il testo digitato
    // setState(() {
    //   testoDigitato = testoInput;
    // });
    // print(testoDigitato);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      // uso un colore predefinito per lo sfondo: si adatta al tema dell'applicazione e cambia con modalitá light/dark
      // color: Theme.of(context).colorScheme.inversePrimary,
      child: Row(
        spacing: 12,
        children: [
          Text('Filtra:'),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                // posso usare un operatore ternario per scegliere un colore diverso in base alla modalitá light/dark, in modo da avere sempre un buon contrasto tra il testo e lo sfondo dell'input.
                fillColor: Theme.of(context).colorScheme.onPrimary,
                border: OutlineInputBorder(),
                // hintText è un testo che appare all'interno dell'input quando è vuoto, per dare un suggerimento all'utente su cosa digitare.
                hintText: 'Digita il nome di una città',
                // suffixIcon è un'icona che appare alla fine dell'input, dopo il testo digitato. Posso usasre prefixIcon per farla apparire all'inizio dell'input, prima del testo digitato.
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: leggiTestoDigitato,
            ),
          ),
          // esempio per mostrare il testo digitato
          // Text('Digitato: $testoDigitato'),
        ],
      ),
    );
  }
}
