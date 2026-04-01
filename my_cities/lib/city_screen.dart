import 'package:flutter/material.dart';
import 'package:my_cities/city_list.dart';
import 'package:my_cities/add_city.dart';
import 'package:google_fonts/google_fonts.dart';

class CityScreen extends StatelessWidget {
  const CityScreen({super.key});

  // funzione chiamata quando si preme il bottone per aggiungere una nuova città
  void showModal(BuildContext context) {
    // showModalBottomSheet è una funzione che mostra una modale che si apre dal basso dello schermo, e che si chiude quando si clicca fuori dalla modale o quando si preme il bottone di chiusura. La modale ha bisogno di un contesto per essere mostrata, e un builder che restituisce il widget da mostrare nella modale. In questo caso, passo un nuovo widget AddCity, che contiene il form per aggiungere una nuova città.
    // le modali sono utili per mostrare contenuti temporanei o secondari, come form, menu, etc. senza dover navigare in una nuova pagina. In questo modo, si può mantenere il contesto della pagina principale, e mostrare solo il contenuto necessario per l'azione che si vuole compiere.
    showModalBottomSheet(context: context, builder: (context) => AddCity());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 25, 24),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 13, 14),
        foregroundColor: const Color.fromARGB(255, 106, 108, 243),
        centerTitle: true,
        title: Text(
          'Viaggi',
          style: GoogleFonts.ebGaramond(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 106, 243, 115),
          ),
        ),
        //get che vengono mostrati alla fine dell'appbar, e che possono essere usati per aggiungere bottoni o menu. In questo caso, aggiungo un IconButton con l'icona di aggiunta, che quando viene premuto chiama la funzione showModal per mostrare la modale di aggiunta città.
        // altre posizioni utili in appBar: leading, che mostra un widget all'inizio dell'appbar, solitamente usato per il menu di navigazione o per il bottone di ritorno indietro. bottom, che mostra un widget sotto l'appbar, solitamente usato per i tab o per i filtri.
        actions: [
          IconButton(
            onPressed: () => showModal(context),
            icon: Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      // body: RandomCity(),
      body: CityList(),
    );
  }
}
