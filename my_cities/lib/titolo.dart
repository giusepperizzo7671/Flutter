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
        color: const Color.fromARGB(255, 21, 21, 22),
        //backgroundColor: const Color.fromARGB(255, 31, 31, 30),
        fontSize: dimensione ?? 30,
      ),
    );
  }
}
