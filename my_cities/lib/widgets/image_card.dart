import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_cities/db_helper.dart';
import 'package:my_cities/screens/grid_screen.dart';
import 'package:my_cities/widgets/image_card_modal.dart';

// ===========================================================================
// ImageCard — singola scheda nella griglia di GridScreen.
//
// Struttura (Stack sovrapposto):
//   ├── Opacity  (semitrasparente se visitata)
//   │   └── immagine (ClipRRect)
//   ├── badge GPS        → tap apre Google Maps
//   ├── badge zona
//   ├── badge tipo
//   ├── bottone nota     (basso destra) → tap apre modale dettagli
//   ├── bottone visitata (basso sinistra) → tap toglia visitata/non visitata
//   └── bottone cestino  (alto destra)  → tap elimina scheda
// ===========================================================================

class ImageCard extends StatefulWidget {
  const ImageCard({
    super.key,
    required this.scheda,
    required this.onElimina,
    required this.onToggleVisitata,
    this.onNotaAggiornata,
  });

  final ImmagineGriglia scheda;
  final VoidCallback onElimina;
  final VoidCallback onToggleVisitata;
  final void Function(String nota)? onNotaAggiornata;

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  late String? _nota;
  late String? _percorso;

  final DbHelper _dbHelper = DbHelper();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nota = widget.scheda.note;
    _percorso = widget.scheda.percorso;
  }

  // --------------------------------------------------------------------------
  // Apre Google Maps alle coordinate della scheda.
  // Analogia: è come fare clic sul puntino sulla mappa cartacea e aprire il
  // navigatore — passiamo le coordinate e Google Maps fa il resto.
  // --------------------------------------------------------------------------
  Future<void> _apriMappa() async {
    final lat = widget.scheda.latitudine;
    final lng = widget.scheda.longitudine;
    if (lat == null || lng == null) return;

    // apre Google Maps nel browser esterno — funziona su Android e iOS
    // senza configurazioni aggiuntive
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('ERRORE apertura mappa: $e');
    }
  }

  // --------------------------------------------------------------------------
  // Apre la modale con tutti i dettagli e il campo nota
  // --------------------------------------------------------------------------
  void _apriModale() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ImageCardModal(
        scheda: widget.scheda.copyWith(note: _nota, percorso: _percorso),
        onNotaSalvata: (nuovaNota) {
          setState(() => _nota = nuovaNota);
          widget.onNotaAggiornata?.call(nuovaNota);
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Seleziona una foto dalla galleria e la associa alla scheda
  // --------------------------------------------------------------------------
  Future<void> _selezionaImmagine() async {
    final foto = await _picker.pickImage(source: ImageSource.gallery);
    if (foto == null || widget.scheda.id == null) return;

    try {
      await _dbHelper.aggiornaImmagineGriglia(
        id: widget.scheda.id!,
        percorso: foto.path,
      );
      setState(() => _percorso = foto.path);
    } catch (e) {
      print('ERRORE _selezionaImmagine: $e');
    }
  }

  // --------------------------------------------------------------------------
  // Build
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final visitata = widget.scheda.isVisitata;

    return GestureDetector(
      onTap: _apriModale,
      child: Stack(
        children: [
          // ---------- immagine (semitrasparente se visitata) ----------
          // Opacity è come mettere un foglio di carta velina sopra la scheda:
          // si vede ancora tutto ma è chiaro che è già stata "usata".
          Opacity(
            opacity: visitata ? 0.4 : 1.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImmagine(),
            ),
          ),

          // ---------- overlay "VISITATO" al centro se visitata ----------
          if (visitata)
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'VISITATO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),

          // ---------- badge GPS (alto sinistra) — tap apre Maps ----------
          if (widget.scheda.latitudine != null &&
              widget.scheda.longitudine != null)
            Positioned(
              top: 6,
              left: 6,
              child: GestureDetector(
                onTap: _apriMappa,
                child: _Badge(
                  icona: Icons.location_on,
                  testo: 'GPS',
                  colore: Colors.blue,
                ),
              ),
            ),

          // ---------- badge zona (sotto GPS) ----------
          if (widget.scheda.zona != null && widget.scheda.zona!.isNotEmpty)
            Positioned(
              top: widget.scheda.latitudine != null ? 34 : 6,
              left: 6,
              child: _Badge(
                icona: Icons.map_outlined,
                testo: widget.scheda.zona!,
                colore: Colors.orange,
              ),
            ),

          // ---------- badge tipo (sotto zona) ----------
          if (widget.scheda.tipo != null && widget.scheda.tipo!.isNotEmpty)
            Positioned(
              top: () {
                int offset = 6;
                if (widget.scheda.latitudine != null) offset += 28;
                if (widget.scheda.zona != null &&
                    widget.scheda.zona!.isNotEmpty)
                  offset += 28;
                return offset.toDouble();
              }(),
              left: 6,
              child: _Badge(
                icona: Icons.category_outlined,
                testo: widget.scheda.tipo!,
                colore: Colors.purple,
              ),
            ),

          // ---------- bottone visitata/non visitata (basso sinistra) ----------
          // Analogia: il timbro "già visto" che apponi sulla scheda.
          Positioned(
            bottom: 6,
            left: 6,
            child: GestureDetector(
              onTap: widget.onToggleVisitata,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: visitata
                      ? Colors.green.withOpacity(0.85)
                      : Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  visitata ? Icons.check_circle : Icons.check_circle_outline,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // ---------- bottone nota (basso destra) ----------
          Positioned(
            bottom: 6,
            right: 6,
            child: GestureDetector(
              onTap: _apriModale,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _nota != null && _nota!.isNotEmpty
                      ? Icons.sticky_note_2
                      : Icons.sticky_note_2_outlined,
                  size: 16,
                  color: _nota != null && _nota!.isNotEmpty
                      ? Colors.greenAccent
                      : Colors.white54,
                ),
              ),
            ),
          ),

          // ---------- bottone cestino (alto destra) ----------
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: widget.onElimina,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Immagine: percorso locale → asset → placeholder
  // --------------------------------------------------------------------------
  Widget _buildImmagine() {
    final percorsoEff = _percorso ?? widget.scheda.percorso;
    if (percorsoEff != null && File(percorsoEff).existsSync()) {
      return Image.file(
        File(percorsoEff),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _errorBox(),
      );
    }

    if (widget.scheda.immagine.isNotEmpty) {
      return Image(
        image: AssetImage('Assets/images/${widget.scheda.immagine}'),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _errorBox() => Container(
    color: Colors.grey.shade900,
    child: const Center(
      child: Icon(Icons.broken_image, color: Colors.white38, size: 36),
    ),
  );

  Widget _placeholder() => GestureDetector(
    onTap: _selezionaImmagine,
    child: Container(
      color: Colors.grey.shade900,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, color: Colors.white38, size: 36),
            SizedBox(height: 6),
            Text(
              'Tocca per\naggiungere foto',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}

// ===========================================================================
// _Badge — chip colorato con icona e testo
// ===========================================================================
class _Badge extends StatelessWidget {
  const _Badge({
    required this.icona,
    required this.testo,
    required this.colore,
  });

  final IconData icona;
  final String testo;
  final Color colore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: colore.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icona, color: Colors.white, size: 11),
          const SizedBox(width: 3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 80),
            child: Text(
              testo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
