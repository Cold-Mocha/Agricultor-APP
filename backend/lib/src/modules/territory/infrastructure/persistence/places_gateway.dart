final class PlaceSuggestion {
  const PlaceSuggestion({required this.id, required this.description});

  final String id;
  final String description;
}

abstract interface class PlacesGateway {
  Future<List<PlaceSuggestion>> search(String query);
}

final class DisabledPlacesGateway implements PlacesGateway {
  const DisabledPlacesGateway();

  @override
  Future<List<PlaceSuggestion>> search(String query) async => const [];
}
