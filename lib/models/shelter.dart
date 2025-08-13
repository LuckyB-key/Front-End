class Shelter {
  final String id;
  final String name;
  final String address;
  final String openingDays;
  final int maxCapacity;
  final String congestion;
  final List<String> facilities;
  final double rating;
  final int likes;
  final String imageUrl;
  final double latitude;
  final double longitude;

  Shelter({
    required this.id,
    required this.name,
    required this.address,
    required this.openingDays,
    required this.maxCapacity,
    required this.congestion,
    required this.facilities,
    required this.rating,
    required this.likes,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      openingDays: json['openingDays'],
      maxCapacity: json['maxCapacity'],
      congestion: json['congestion'],
      facilities: List<String>.from(json['facilities']),
      rating: json['rating'].toDouble(),
      likes: json['likes'],
      imageUrl: json['imageUrl'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'openingDays': openingDays,
      'maxCapacity': maxCapacity,
      'congestion': congestion,
      'facilities': facilities,
      'rating': rating,
      'likes': likes,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
