class City {
  const City({
    required this.name,
    required this.country,
    required this.isVisited,
    required this.id,
    this.imageName,
  });

  final String name;
  final String country;
  final bool isVisited;
  final String id;
  final String? imageName;
}
