class CatalogDetail {
  const CatalogDetail({
    required this.id,
    required this.name,
    required this.facts,
    required this.highlights,
  });

  final String id;
  final String name;
  final Map<String, String> facts;
  final List<String> highlights;
}
