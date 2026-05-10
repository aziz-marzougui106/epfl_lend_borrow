enum ItemType { sell, lend }

class Item {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final ItemType type;
  final String? imageUrl;
  final String ownerName;

  const Item({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.type,
    this.imageUrl,
    required this.ownerName,
  });

  // Parse a single item from the JSON the API returns
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(), //if i wrote as double casting 45 would fail
      category: json['category'] as String,
      type: json['type'] == 'sell' ? ItemType.sell : ItemType.lend,
      imageUrl: json['image_url'] as String?,
      ownerName: json['owner_name'] as String,
    );
  }
}