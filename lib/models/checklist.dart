class Checklist {
  final String id;
  final String systemType;
  final List<String> steps;
  final DateTime lastUpdated;

  Checklist({
    required this.id,
    required this.systemType,
    required this.steps,
    required this.lastUpdated,
  });
}
