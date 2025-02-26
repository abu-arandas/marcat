class Store {
  String id, name, description, image;
  LatLong location;

  Store({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.location,
  });

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        image: json['image'] as String,
        location: LatLong.fromJson(json['location']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
        'location': location.toJson(),
      };
}

class LatLong {
  double lat, lot;

  LatLong({
    required this.lat,
    required this.lot,
  });

  factory LatLong.fromJson(Map<String, dynamic> json) => LatLong(
        lat: json['lat'],
        lot: json['lot'],
      );

  Map<String, dynamic> toJson() => {'lat': lat, 'lot': lot};
}
