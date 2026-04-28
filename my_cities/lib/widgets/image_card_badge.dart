import 'package:flutter/material.dart';

// widget riutilizzabile per i badge sovrapposti all'immagine della griglia.
// usato per GPS, zona, tipo e qualsiasi altra etichetta sull'immagine
class ImageCardBadge extends StatelessWidget {
  const ImageCardBadge({
    super.key,
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
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icona, size: 12, color: colore),
          const SizedBox(width: 2),
          Text(testo, style: TextStyle(color: colore, fontSize: 10)),
        ],
      ),
    );
  }
}
