class Shop {
  final String id;
  final String name;
  final String imageUrl;

  Shop({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
        id: json['id'],
        name: json['name'],
        imageUrl: json['imageUrl'],
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };
  }
}
