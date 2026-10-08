final class GeoPoint {
  const GeoPoint(this.latitude, this.longitude)
    : assert(latitude >= -90 && latitude <= 90),
      assert(longitude >= -180 && longitude <= 180);

  final double latitude;
  final double longitude;

  Map<String, double> toJson() => {'lat': latitude, 'lng': longitude};
}
