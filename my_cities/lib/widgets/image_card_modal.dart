import 'package:flutter/material.dart';
import 'package:my_cities/db_helper.dart';

// modale che mostra tutti i dati di un'immagine importati dall'Excel.
// permette anche di modificare la nota
class ImageCardModal extends StatelessWidget {
  const ImageCardModal({
    super.key,
    required this.imageName,
    required this.cityId,
    required this.dati,
    required this.onNotaSalvata,
  });

  final String imageName;
  final String? cityId;

  // mappa con tutti i campi: latitudine, longitudine, tipo, destinazione,
  // orari, ticket, hh, zona, gg, metro_bus, note
  final Map<String, dynamic> dati;

  // callback chiamata dopo il salvataggio della nota,
  // per aggiornare lo stato della ImageCard parent
  final void Function(String) onNotaSalvata;

  // helper sicuro per leggere un campo stringa dalla mappa.
  // non usa mai ! — restituisce null se il campo è assente o vuoto
  String? _leggi(String campo) {
    final v = dati[campo];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  // helper: controlla se un campo esiste e non è vuoto
  bool _haValore(String campo) => _leggi(campo) != null;

  // helper: riga con icona, etichetta e valore
  Widget _rigaInfo(IconData icona, String etichetta, String valore) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icona, size: 14, color: Colors.white54),
          const SizedBox(width: 6),
          Text(
            '$etichetta: ',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              valore,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(
      // leggi in modo sicuro la nota senza usare !
      text: _leggi('note') ?? '',
    );

    // leggi le coordinate in modo sicuro senza cast diretto
    final latRaw = dati['latitudine'];
    final lngRaw = dati['longitudine'];
    final double? latitudine = latRaw is double
        ? latRaw
        : double.tryParse(latRaw?.toString() ?? '');
    final double? longitudine = lngRaw is double
        ? lngRaw
        : double.tryParse(lngRaw?.toString() ?? '');

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        // aggiunge padding dinamico per la tastiera virtuale
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // titolo con nome file immagine
            Text(
              imageName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            // mostra tutti i campi disponibili importati dall'Excel.
            // _leggi restituisce sempre una stringa non nulla qui
            // perché _haValore ha già verificato che il campo esiste
            if (_haValore('tipo'))
              _rigaInfo(Icons.category, 'Tipo', _leggi('tipo')!),
            if (_haValore('destinazione'))
              _rigaInfo(Icons.place, 'Destinazione', _leggi('destinazione')!),
            if (latitudine != null && longitudine != null)
              _rigaInfo(
                Icons.location_on,
                'Coordinate',
                '${latitudine.toStringAsFixed(4)}, ${longitudine.toStringAsFixed(4)}',
              ),
            if (_haValore('zona'))
              _rigaInfo(Icons.map, 'Zona', _leggi('zona')!),
            if (_haValore('orari'))
              _rigaInfo(Icons.access_time, 'Orari', _leggi('orari')!),
            if (_haValore('ticket'))
              _rigaInfo(Icons.confirmation_number, 'Ticket', _leggi('ticket')!),
            if (_haValore('hh')) _rigaInfo(Icons.timer, 'HH', _leggi('hh')!),
            if (_haValore('gg'))
              _rigaInfo(Icons.calendar_today, 'GG', _leggi('gg')!),
            if (_haValore('metro_bus'))
              _rigaInfo(
                Icons.directions_bus,
                'Metro/Bus',
                _leggi('metro_bus')!,
              ),

            const Divider(color: Colors.white24, height: 24),

            // sezione nota modificabile
            const Text(
              'Note',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // campo testo multi-riga per la nota
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              maxLines: null,
              minLines: 3,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Scrivi una nota...',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 12),

            // bottone salva: aggiorna la nota nel database e chiude la modale
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final dbHelper = DbHelper();
                  // salva nel db usando il metodo appropriato in base
                  // alla presenza di cityId
                  if (cityId != null) {
                    await dbHelper.aggiornaNota(
                      cityId!,
                      imageName,
                      controller.text,
                    );
                  } else {
                    await dbHelper.salvaNota(imageName, controller.text);
                  }
                  // notifica il widget parent del nuovo testo salvato
                  onNotaSalvata(controller.text);
                  Navigator.pop(context);
                },
                child: const Text('Salva'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
