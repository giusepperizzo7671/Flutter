import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_cities/db_helper.dart';
import 'package:my_cities/screens/grid_screen.dart';

// ===========================================================================
// ImageCardModal — pannello dal basso con tutti i dettagli di una scheda
// e il campo nota modificabile.
// ===========================================================================

class ImageCardModal extends StatefulWidget {
  const ImageCardModal({
    super.key,
    required this.scheda,
    required this.onNotaSalvata,
  });

  final ImmagineGriglia scheda;
  final void Function(String nota) onNotaSalvata;

  @override
  State<ImageCardModal> createState() => _ImageCardModalState();
}

class _ImageCardModalState extends State<ImageCardModal> {
  late final TextEditingController _notaController;
  bool _salvataggio = false;

  bool get _notaModificata =>
      _notaController.text.trim() != (widget.scheda.note ?? '').trim();

  final DbHelper _dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    _notaController = TextEditingController(text: widget.scheda.note ?? '');
  }

  @override
  void dispose() {
    _notaController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Salvataggio nota
  // --------------------------------------------------------------------------
  Future<void> _salvaNota() async {
    if (widget.scheda.id == null) return;
    if (!_notaModificata) {
      Navigator.pop(context);
      return;
    }

    setState(() => _salvataggio = true);
    try {
      final testo = _notaController.text.trim();
      await _dbHelper.aggiornaImmagineGriglia(
        id: widget.scheda.id!,
        note: testo,
      );
      widget.onNotaSalvata(testo);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      print('ERRORE _salvaNota: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore durante il salvataggio della nota'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _salvataggio = false);
    }
  }

  // --------------------------------------------------------------------------
  // Apre Google Maps alle coordinate della scheda
  // --------------------------------------------------------------------------
  Future<void> _apriMappa() async {
    final lat = widget.scheda.latitudine;
    final lng = widget.scheda.longitudine;
    if (lat == null || lng == null) return;

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
  // Build
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // legge colori dal tema attivo per garantire leggibilità sia in dark che light mode
    final colorScheme = Theme.of(context).colorScheme;
    final testoColore = colorScheme.onSurface;
    final labelColore = colorScheme.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.60,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // maniglia
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // intestazione
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.scheda.destinazione ?? widget.scheda.immagine,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: testoColore,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _salvataggio
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : TextButton(
                          onPressed: _notaModificata ? _salvaNota : null,
                          child: const Text('Salva'),
                        ),
                ],
              ),
            ),

            Divider(height: 1, color: colorScheme.outlineVariant),

            // corpo scrollabile
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                children: [
                  _buildSezioneMetadati(testoColore, labelColore),
                  const SizedBox(height: 24),
                  _buildSezioneNota(testoColore),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Sezione metadati
  // --------------------------------------------------------------------------
  Widget _buildSezioneMetadati(Color testoColore, Color labelColore) {
    final lat = widget.scheda.latitudine;
    final lng = widget.scheda.longitudine;
    final haCoord = lat != null && lng != null;

    final campi = <_Campo>[
      if (_v(widget.scheda.tipo))
        _Campo(Icons.category_outlined, 'Tipo', widget.scheda.tipo!),
      if (_v(widget.scheda.zona))
        _Campo(Icons.map_outlined, 'Zona', widget.scheda.zona!),
      if (_v(widget.scheda.destinazione))
        _Campo(
          Icons.place_outlined,
          'Destinazione',
          widget.scheda.destinazione!,
        ),
      if (_v(widget.scheda.orari))
        _Campo(Icons.access_time, 'Orari', widget.scheda.orari!),
      if (_v(widget.scheda.ticket))
        _Campo(
          Icons.confirmation_number_outlined,
          'Ticket',
          widget.scheda.ticket!,
        ),
      if (_v(widget.scheda.hh))
        _Campo(Icons.timer_outlined, 'Durata (HH)', widget.scheda.hh!),
      if (_v(widget.scheda.gg))
        _Campo(Icons.calendar_today_outlined, 'Giorni (GG)', widget.scheda.gg!),
      if (_v(widget.scheda.metroBus))
        _Campo(
          Icons.directions_bus_outlined,
          'Metro/Bus',
          widget.scheda.metroBus!,
        ),
    ];

    if (campi.isEmpty && !haCoord) {
      return Text(
        'Nessun metadato disponibile per questa scheda.',
        style: TextStyle(color: testoColore.withOpacity(0.5), fontSize: 13),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dettagli',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: labelColore,
          ),
        ),
        const SizedBox(height: 10),

        // riga coordinate con bottone apri mappa
        if (haCoord) _buildRigaCoordinate(lat!, lng!, testoColore),

        ...campi.map((c) => _buildRiga(c, testoColore)),
      ],
    );
  }

  // riga speciale per le coordinate con bottone "Apri Mappa"
  Widget _buildRigaCoordinate(double lat, double lng, Color testoColore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.location_on_outlined, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              'Coordinate',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.blue,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
              style: TextStyle(fontSize: 12, color: testoColore),
            ),
          ),
          // bottone che apre Google Maps
          InkWell(
            onTap: _apriMappa,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map, color: Colors.white, size: 13),
                  SizedBox(width: 4),
                  Text(
                    'Mappa',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // riga metadato standard: icona | label | valore
  Widget _buildRiga(_Campo campo, Color testoColore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(campo.icona, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              campo.label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              campo.valore,
              // colore esplicito dal tema — risolve il bug "testo invisibile"
              style: TextStyle(fontSize: 13, color: testoColore),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Sezione nota
  // --------------------------------------------------------------------------
  Widget _buildSezioneNota(Color testoColore) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _notaController,
          maxLines: 5,
          minLines: 3,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(fontSize: 14, color: testoColore),
          decoration: InputDecoration(
            hintText: 'Scrivi una nota per questa scheda...',
            hintStyle: TextStyle(color: testoColore.withOpacity(0.4)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _notaModificata && !_salvataggio ? _salvaNota : null,
            child: _salvataggio
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Salva nota'),
          ),
        ),
      ],
    );
  }

  bool _v(String? s) => s != null && s.isNotEmpty;
}

class _Campo {
  const _Campo(this.icona, this.label, this.valore);
  final IconData icona;
  final String label;
  final String valore;
}
