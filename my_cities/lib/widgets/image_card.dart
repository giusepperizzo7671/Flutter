import 'package:flutter/material.dart';
import 'package:my_cities/db_helper.dart';
import 'package:my_cities/widgets/image_card_badge.dart';
import 'package:my_cities/widgets/image_card_modal.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// ImageCard mostra una singola immagine nella griglia con badge e bottone nota.
// è StatefulWidget perché la nota e l'immagine possono essere modificate
class ImageCard extends StatefulWidget {
  const ImageCard({
    super.key,
    required this.imageName,
    this.cityId,
    this.datiIniziali,
  });

  // nome del file immagine oppure percorso assoluto se importata dalla galleria.
  // se inizia con '/' è un file locale, altrimenti è un asset dell'app
  final String imageName;

  // id della città di appartenenza, null se si è nella galleria generale
  final String? cityId;

  // dati già caricati dal db passati da GridScreen per evitare query duplicate
  final Map<String, dynamic>? datiIniziali;

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  // tutti i campi del file CSV salvati come stato locale
  String? _note;
  String? _percorso;
  double? _latitudine;
  double? _longitudine;
  String? _tipo;
  String? _destinazione;
  String? _orari;
  String? _ticket;
  String? _hh;
  String? _zona;
  String? _gg;
  String? _metroBus;

  final DbHelper _dbHelper = DbHelper();
  final ImagePicker _picker = ImagePicker();

  // helper sicuro per leggere una stringa dalla mappa del database.
  // SQLite può restituire qualsiasi tipo — toString() gestisce tutto
  // senza mai usare cast diretti o l'operatore !
  String? _leggiStringa(Map<String, dynamic> d, String campo) {
    final v = d[campo];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  // helper sicuro per leggere un double dalla mappa del database.
  // SQLite può restituire int o double — gestisce entrambi i casi
  double? _leggiDouble(Map<String, dynamic> d, String campo) {
    final v = d[campo];
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  @override
  void initState() {
    super.initState();
    // inizializza tutti i campi dai datiIniziali passati da GridScreen,
    // usando gli helper sicuri invece di cast diretti
    if (widget.datiIniziali != null) {
      final d = widget.datiIniziali!;
      _note = _leggiStringa(d, 'note');
      _percorso = _leggiStringa(d, 'percorso');
      _latitudine = _leggiDouble(d, 'latitudine');
      _longitudine = _leggiDouble(d, 'longitudine');
      _tipo = _leggiStringa(d, 'tipo');
      _destinazione = _leggiStringa(d, 'destinazione');
      _orari = _leggiStringa(d, 'orari');
      _ticket = _leggiStringa(d, 'ticket');
      _hh = _leggiStringa(d, 'hh');
      _zona = _leggiStringa(d, 'zona');
      _gg = _leggiStringa(d, 'gg');
      _metroBus = _leggiStringa(d, 'metro_bus');
    }
  }

  // apre la galleria del telefono per selezionare un'immagine
  // da associare a questa specifica scheda.
  // salva il percorso nel database aggiornando la colonna percorso
  Future<void> _selezionaImmagineScheda() async {
    try {
      final XFile? immagine = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (immagine == null) return;

      // aggiorna il percorso nel database per questa specifica immagine
      if (widget.cityId != null) {
        await _dbHelper.aggiornaPercorsoImmagine(
          widget.cityId!,
          widget.imageName,
          immagine.path,
        );
      }

      // aggiorna lo stato locale per mostrare subito la nuova immagine
      setState(() {
        _percorso = immagine.path;
      });
    } catch (e) {
      print('ERRORE selezione immagine scheda: $e');
    }
  }

  // apre la modale con tutti i dettagli dell'immagine e il campo nota
  void _apriModale() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ImageCardModal(
        imageName: widget.imageName,
        cityId: widget.cityId,
        dati: {
          'note': _note,
          'percorso': _percorso,
          'latitudine': _latitudine,
          'longitudine': _longitudine,
          'tipo': _tipo,
          'destinazione': _destinazione,
          'orari': _orari,
          'ticket': _ticket,
          'hh': _hh,
          'zona': _zona,
          'gg': _gg,
          'metro_bus': _metroBus,
        },
        onNotaSalvata: (testo) {
          setState(() => _note = testo);
        },
      ),
    );
  }

  // costruisce il widget immagine in base al tipo di percorso.
  // priorità: percorso locale (_percorso) > nome asset (widget.imageName).
  // se il percorso inizia con '/' è un file locale dalla galleria,
  // altrimenti è un asset dell'app nella cartella Assets/images/
  Widget _buildImmagine() {
    final path = (_percorso != null && _percorso!.isNotEmpty)
        ? _percorso!
        : widget.imageName;

    // se non c'è nessun percorso valido, mostra il placeholder
    if (path.isEmpty) return _buildPlaceholder();

    if (path.startsWith('/')) {
      // immagine locale importata dalla galleria del telefono
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stack) => _buildPlaceholder(),
      );
    }

    // immagine asset dell'app nella cartella Assets/images/
    return Image(
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      image: AssetImage('Assets/images/$path'),
      errorBuilder: (context, error, stack) => _buildPlaceholder(),
    );
  }

  // placeholder mostrato quando non c'è nessuna immagine disponibile.
  // mostra un bottone per selezionare un'immagine dalla galleria
  Widget _buildPlaceholder() {
    return GestureDetector(
      onTap: _selezionaImmagineScheda,
      child: Container(
        color: Colors.grey.shade900,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate, color: Colors.white38, size: 40),
              SizedBox(height: 8),
              Text(
                'Tocca per aggiungere\nuna foto',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // indica se la scheda ha un'immagine reale o solo il placeholder
  bool get _haImmagine =>
      _percorso != null ||
      (widget.imageName.isNotEmpty && widget.imageName != '');

  @override
  Widget build(BuildContext context) {
    // Stack permette di sovrapporre badge e bottoni sopra l'immagine
    return Stack(
      children: [
        // immagine con angoli arrotondati che occupa tutta la cella
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImmagine(),
        ),

        // badge GPS in alto a sinistra
        if (_latitudine != null && _longitudine != null)
          Positioned(
            top: 8,
            left: 8,
            child: ImageCardBadge(
              icona: Icons.location_on,
              testo: 'GPS',
              colore: Colors.blue,
            ),
          ),

        // badge zona in alto a destra
        if (_zona != null && _zona!.isNotEmpty)
          Positioned(
            top: 8,
            right: 8,
            child: ImageCardBadge(
              icona: Icons.map,
              testo: _zona!,
              colore: Colors.orange,
            ),
          ),

        // badge tipo in basso a sinistra
        if (_tipo != null && _tipo!.isNotEmpty)
          Positioned(
            bottom: 40,
            left: 8,
            child: ImageCardBadge(
              icona: Icons.category,
              testo: _tipo!,
              colore: Colors.purple,
            ),
          ),

        // bottone per cambiare immagine in alto a destra,
        // visibile solo se c'è già un'immagine (altrimenti si usa il placeholder)
        if (_haImmagine)
          Positioned(
            top: _latitudine != null ? 36 : 8,
            right: 8,
            child: GestureDetector(
              onTap: _selezionaImmagineScheda,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.white70),
              ),
            ),
          ),

        // bottone nota in basso a destra.
        // cambia colore e testo in base alla presenza di una nota salvata
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: _apriModale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _note != null && _note!.isNotEmpty
                      ? Colors.green
                      : Colors.white54,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.note,
                    size: 14,
                    color: _note != null && _note!.isNotEmpty
                        ? Colors.green
                        : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _note != null && _note!.isNotEmpty
                        ? 'Modifica nota'
                        : 'Aggiungi nota',
                    style: TextStyle(
                      fontSize: 11,
                      color: _note != null && _note!.isNotEmpty
                          ? Colors.green
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
