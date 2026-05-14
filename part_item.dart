class PartItem {
  final String id;
  final String shopId;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String category;

  PartItem({
    required this.id,
    required this.shopId,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
  });

  factory PartItem.fromJson(Map<String, dynamic> json) => PartItem(
        id: json['id'],
        shopId: json['shopId'] ?? json['restaurantId'],
        name: json['name'],
        price: (json['price'] as num).toDouble(),
        description: json['description'],
        imageUrl: json['imageUrl'],
        category: json['category'],
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}
