class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> availableTimes;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.availableTimes,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json, String id) {
    return ServiceModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      availableTimes: List<String>.from(json['availableTimes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'availableTimes': availableTimes,
    };
  }
}
