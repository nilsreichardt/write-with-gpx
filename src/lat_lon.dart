class LatLon {
  final double lat;
  final double lon;

  const LatLon({
    required this.lat,
    required this.lon,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LatLon && other.lat == lat && other.lon == lon;
  }

  @override
  int get hashCode => lat.hashCode ^ lon.hashCode;

  @override
  String toString() => 'LatLog(lat: $lat, lon: $lon)';
}
