class LocationOption {
  final String city;
  final String state;

  const LocationOption({
    required this.city,
    required this.state,
  });

  String get label => '$city, $state';
}
