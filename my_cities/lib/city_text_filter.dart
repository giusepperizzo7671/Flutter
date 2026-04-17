import 'package:flutter/material.dart';

class CityTextFilter extends StatefulWidget {
  const CityTextFilter({super.key, required this.aggiornaFiltro});

  // callback che viene chiamata ogni volta che l'utente digita qualcosa,
  // e aggiorna il filtro nella pagina principale con il testo digitato
  final void Function(String) aggiornaFiltro;

  @override
  State<CityTextFilter> createState() => _CityTextFilter();
}

class _CityTextFilter extends State<CityTextFilter> {
  // quando l'utente digita qualcosa, questa funzione viene chiamata
  // con il testo digitato come argomento.
  // chiama aggiornaFiltro passando il testo a CityScreen,
  // che aggiorna la lista delle città filtrate di conseguenza
  void leggiTestoDigitato(String testoInput) {
    widget.aggiornaFiltro(testoInput);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        spacing: 12,
        children: [
          const Text('Filtra:'),

          Expanded(
            child: TextField(
              // style controlla il colore del testo digitato dall'utente
              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                filled: true,
                // sfondo scuro per garantire il contrasto con il testo bianco
                fillColor: Colors.black,
                border: const OutlineInputBorder(),
                // hintText appare quando il campo è vuoto,
                // per suggerire all'utente cosa digitare
                hintText: 'Digita il nome di una città',
                // hintStyle semi-trasparente per distinguerlo dal testo reale
                hintStyle: const TextStyle(color: Colors.white54),
                // suffixIcon è l'icona che appare alla fine del campo di testo.
                // prefixIcon la metterebbe all'inizio, prima del testo
                suffixIcon: const Icon(Icons.search, color: Colors.white),
              ),

              // onChanged viene chiamato ad ogni carattere digitato dall'utente,
              // e passa il testo aggiornato alla funzione leggiTestoDigitato
              onChanged: leggiTestoDigitato,
            ),
          ),
        ],
      ),
    );
  }
}
