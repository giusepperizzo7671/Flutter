class City {
  City({
    required this.name,
    required this.country,
    required this.isVisited,
    required this.id,
    this.imageName,
    this.note,
    this.images = const [],
  });

  final String name;
  final String country;
  bool isVisited;
  final String id;
  final String? imageName;
  String? note;
  final List<String> images;
}
