import 'package:my_cities/models/city.dart';
import 'package:my_cities/add_note.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CityCard extends StatelessWidget {
  const CityCard({super.key, required this.city});
  final City city;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: city.isVisited
            ? const Color.fromARGB(255, 205, 214, 208)
            : const Color.fromARGB(255, 245, 196, 158),
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: city.imageName != null
                ? Image(
                    fit: BoxFit.cover,
                    image: AssetImage('Assets/images/${city.imageName}'),
                  )
                : Container(
                    height: 200,
                    width: 250,
                    color: Colors.grey,
                    child: const Center(
                      child: Text(
                        'Ops, no image!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                city.isVisited ? Icons.check_circle : Icons.cancel,
                color: city.isVisited
                    ? Colors.green
                    : const Color.fromARGB(255, 126, 123, 123),
              ),
              Text(
                '${city.name}, ${city.country}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.note_add, color: Colors.blueGrey),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => const AddNote(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
