import 'package:flutter/material.dart';

class AddNote extends StatelessWidget {
  const AddNote({super.key, required this.onSave, this.initialNote});

  final Function(String) onSave; //
  final String? initialNote; //

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: initialNote ?? '', //
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            maxLines: null,
            minLines: 4,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              label: Text('Note'),
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text); //
              Navigator.pop(context); //
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }
}
