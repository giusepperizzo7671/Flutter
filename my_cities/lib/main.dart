import 'package:flutter/material.dart';
import 'package:my_cities/models/city.dart';
import 'package:my_cities/screens/city_screen.dart';
import 'package:my_cities/screens/grid_screen.dart';
import 'package:my_cities/screens/random_city.dart';

// colorscheme è un modo per definire i colori principali dell'app, e poi usarli in tutto il resto dell'applicazione, in modo da avere un tema coerente e facile da modificare
// seedcolor è il colore principale da cui vengono generati tutti gli altri colori del tema, come primary, secondary, background, etc. In questo modo, cambiando il seed color, si cambia tutto il tema dell'applicazione in modo coerente e armonioso
var temaChiaro = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 10, 39, 84),
);
var temaScuro = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 3, 3, 3),
);

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // copyWith è un metodo che permette di creare una nuova istanza di un oggetto, copiando tutte le proprietà dell'oggetto originale e sovrascrivendo solo quelle specificate. In questo modo, si può modificare solo una parte del tema senza dover ridefinire tutto da capo
      theme: ThemeData.dark().copyWith(
        colorScheme: temaScuro,
        textButtonTheme: TextButtonThemeData(
          // styleFrom funziona come copyWith, ma per i bottoni. Permette di definire alcune proprietà del bottone, come backgroundColor, foregroundColor, padding, etc. In questo modo, si può avere uno stile coerente per tutti i bottoni dell'applicazione, e modificarlo facilmente in un unico posto
          style: TextButton.styleFrom(
            // primary è il colore principale del tema, e si adatta bene per i bottoni, perché è un colore che spicca e attira l'attenzione. primaryContainer è un colore più chiaro e meno intenso del primary, che si adatta bene per il testo dei bottoni, perché è più leggibile e meno aggressivo. In questo modo, si ha un contrasto sufficiente tra il colore di sfondo del bottone e il colore del testo, rendendo il bottone facile da leggere e da usare.
            // altri colori utili in colorScheme: secondary, che è un colore secondario del tema, e che si adatta bene per i bottoni secondari o per gli elementi di supporto. background, che è il colore di sfondo dell'applicazione, e che si adatta bene per il corpo dell'applicazione. surface, che è un colore di sfondo più chiaro del background, e che si adatta bene per card o menu.
            // onprimary è un colore che si adatta bene per il testo o gli elementi che vengono mostrati sopra al primary, come il testo dei bottoni o le icone.  In questo modo, si ha un contrasto sufficiente tra il colore di sfondo del bottone e il colore del testo, rendendo il bottone facile da leggere e da usare.
            // puoi provare altre combinazioni, come ad esempio usare primaryContainer come backgroundColor, e onPrimaryContainer come foregroundColor. Oppure usare secondary come backgroundColor, e onSecondary come foregroundColor, per avere un effetto più vivace e colorato. L'importante è mantenere un buon contrasto tra i colori, per garantire la leggibilità e l'usabilità dell'interfaccia.
            //backgroundColor: temaScuro.primaryContainer,
            //foregroundColor: temaScuro.onPrimaryContainer,
            backgroundColor: const Color.fromARGB(255, 10, 10, 10),
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          ),
        ),
        textTheme: ThemeData().textTheme.copyWith(
          // titleLarge è uno dei tanti stili di testo predefiniti in Flutter, che si possono usare per dare un aspetto coerente e professionale all'applicazione. titleLarge è uno stile adatto per i titoli principali, con una dimensione più grande e un peso più alto rispetto agli altri stili. bodymedium è uno stile adatto per il testo normale, con una dimensione media e un peso normale. Si possono usare questi stili in tutta l'applicazione, e modificarli facilmente in un unico posto, cambiando il tema dell'applicazione
          titleLarge: TextStyle(fontSize: 24),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(colorScheme: temaScuro),
      // DefaultTabController è un widget che fornisce un controller per gestire le tab.
      // In questo modo, si può creare un'interfaccia a schede semplice e veloce, senza dover gestire manualmente lo stato delle tab o il cambio di contenuto.
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          // bottomNavigationBar è una proprietà del scaffold che permette di inserire un widget in fondo alla schermata, come ad esempio un menu di navigazione o una barra di tab.
          // In questo caso, uso TabBar per creare una barra di tab con tre tab, ognuna con un testo e un'icona.
          // Quando l'utente clicca su una tab, viene mostrato il contenuto corrispondente nella TabBarView.
          // altre posizioni: appBar, body, floatingActionButton, drawer, endDrawer, bottomNavigationBar, persistentFooterButtons, etc.
          bottomNavigationBar: TabBar(
            // elenco delle tab, con testo e icona. Si ha un'interfaccia a schede chiara e intuitiva, che permette di navigare facilmente tra i diversi contenuti dell'applicazione.
            tabs: [
              Tab(text: 'Elenco città', icon: Icon(Icons.list)),
              Tab(text: 'Città random', icon: Icon(Icons.casino)),
              Tab(text: 'Griglia città', icon: Icon(Icons.grid_on)),
            ],
          ),
          // TabBarView è un widget che mostra il contenuto corrispondente alla tab selezionata.
          body: TabBarView(
            children: [CityScreen(), RandomCity(), GridScreen()],
          ),
        ),
      ),
    );
  }
}
