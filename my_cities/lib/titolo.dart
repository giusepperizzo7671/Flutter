import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Titolo extends StatelessWidget {
  const Titolo(this.testo, {this.dimensione, super.key});

  final String testo;
  final double? dimensione;

  @override
  Widget build(BuildContext context) {
    return Text(
      testo,
      style: TextStyle(
        color: const Color.fromARGB(255, 5, 35, 232),
        //fontSize: dimensione == null ? 20 : dimensione,
        fontSize: dimensione ?? 30,
      ),
    );
  }
}
