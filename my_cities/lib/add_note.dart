import 'package:flutter/material.dart';

class AddNote extends StatefulWidget {
  const AddNote({super.key});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  @override
  Widget build(BuildContext context) {
    return (Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Inserisci note',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              // per il colore uso il colore primary del colorScheme, che è il colore principale del tema, e che si adatta bene per i titoli.
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 24),
          TextField(
            maxLines: null,
            minLines: 4,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, child: Text('Aggiungi')),
        ],
      ),
    ));
  }
}
