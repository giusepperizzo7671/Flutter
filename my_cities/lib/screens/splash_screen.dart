import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_cities/main.dart'; // 👈 importa HomeScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // AnimationController gestisce il tempo e il progresso dell'animazione
  late AnimationController _controller;

  // Animation<double> definisce i valori numerici dell'animazione (da 0.0 a 1.0)
  late Animation<double> _progressAnimation;

  // booleano che diventa true quando la barra di caricamento è completa
  bool _caricamentoCompletato = false;

  @override
  void initState() {
    super.initState();

    // AnimationController gestisce la durata dell'animazione.
    // vsync: this evita che l'animazione consumi risorse quando il widget non è visibile
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Tween definisce i valori di inizio (0) e fine (1) dell'animazione.
    // CurvedAnimation aggiunge una curva per rendere il movimento più naturale
    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // addStatusListener ascolta i cambiamenti di stato dell'animazione.
    // Quando l'animazione è completata, mostra il bottone "Esplora"
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _caricamentoCompletato = true;
        });
      }
    });

    // avvia l'animazione automaticamente all'apertura della splash screen
    _controller.forward();
  }

  @override
  void dispose() {
    // libera le risorse del controller quando il widget viene distrutto,
    // per evitare memory leak
    _controller.dispose();
    super.dispose();
  }

  void _apriApp() {
    // pushReplacement sostituisce la splash screen con HomeScreen,
    // così l'utente non può tornare indietro con il tasto back
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stack permette di sovrapporre i widget uno sopra l'altro,
      // come degli strati: prima l'immagine, poi l'overlay scuro, poi il testo
      body: Stack(
        children: [
          // immagine di sfondo a tutta schermata
          Positioned.fill(
            child: Image.asset(
              'Assets/images/splash.jpg',
              fit: BoxFit
                  .cover, // riempie tutto lo schermo ritagliando se necessario
            ),
          ),

          // overlay con gradiente scuro sopra l'immagine per migliorare la leggibilità
          // del testo e degli elementi in primo piano
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2), // più trasparente in alto
                    Colors.black.withOpacity(0.8), // più scuro in basso
                  ],
                ),
              ),
            ),
          ),

          // contenuto principale posizionato in basso:
          // titolo, sottotitolo, barra di caricamento e bottone
          Positioned(
            bottom: 80,
            left: 32,
            right: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // titolo principale dell'app
                Text(
                  'I nostri viaggi ...',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 8),

                // sottotitolo
                Text(
                  'Il mondo è tutto da esplorare',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    color: const Color.fromARGB(179, 241, 234, 234),
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 40),

                // AnimatedBuilder si aggiorna ad ogni frame dell'animazione,
                // ridisegnando la barra di progresso con il valore aggiornato
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Column(
                      children: [
                        // barra di caricamento con angoli arrotondati
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            // value va da 0.0 a 1.0, collegato all'animazione
                            value: _progressAnimation.value,
                            minHeight: 6,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // percentuale di caricamento in tempo reale
                        Text(
                          '${(_progressAnimation.value * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // AnimatedOpacity anima la comparsa del bottone:
                // invisibile durante il caricamento, visibile quando è completato
                AnimatedOpacity(
                  opacity: _caricamentoCompletato ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: ElevatedButton(
                    // il bottone è attivo solo quando il caricamento è completato
                    onPressed: _caricamentoCompletato ? _apriApp : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Buon viaggio...',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
