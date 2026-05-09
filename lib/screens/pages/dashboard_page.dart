import 'package:flutter/material.dart';

// ── Item model ─────────────────────────────────────────────────
class Item {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final ItemType type;
  final String? imageUrl;
  final String ownerName;
  final DateTime postedAt;

  const Item({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.type,
    this.imageUrl,
    required this.ownerName,
    required this.postedAt,
  });
}

enum ItemType { sell, lend }

// ── Mock data ──────────────────────────────────────────────────
final List<Item> mockItems = [
  Item(
    id: '1',
    title: 'MacBook Pro 16"',
    description:
        'Barely used MacBook Pro 16-inch. M1 Max, 32GB RAM, 1TB SSD. Perfect for coding and design projects. Comes with original charger and box.',
    price: 1899.00,
    category: 'Electronics',
    type: ItemType.sell,
    imageUrl:
        'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&q=80&w=800',
    ownerName: 'Ahmed K.',
    postedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Item(
    id: '2',
    title: 'Calculus Early Transcendentals',
    description:
        'Textbook for MATH-101. Some highlighting in chapters 3-5 but overall great condition. Edition 8. Very useful for the exam.',
    price: 45.00,
    category: 'Books',
    type: ItemType.sell,
    ownerName: 'Sara M.',
    postedAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  Item(
    id: '3',
    title: 'Ergonomic Desk Chair',
    description:
        'Herman Miller Aeron chair, size B. Excellent for long study sessions. Adjustable lumbar support. Available for lending by the semester.',
    price: 30.00,
    category: 'Furniture',
    type: ItemType.lend,
    imageUrl:
        'https://images.unsplash.com/photo-1505843490538-5133c6c7d0e1?auto=format&fit=crop&q=80&w=800',
    ownerName: 'Lucas B.',
    postedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Item(
    id: '4',
    title: 'Sony WH-1000XM4',
    description:
        'Noise cancelling headphones in perfect condition. Great for studying in the library or on the metro. Box and all accessories included.',
    price: 15.00,
    category: 'Electronics',
    type: ItemType.lend,
    imageUrl:
        'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&q=80&w=800',
    ownerName: 'Julie P.',
    postedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Item(
    id: '5',
    title: 'EPFL Hoodie',
    description:
        'Size M. Official EPFL merchandise. Very warm and comfortable. Worn only a few times. Perfect condition, no stains or damage.',
    price: 30.00,
    category: 'Clothing',
    type: ItemType.sell,
    imageUrl:
        'https://images.unsplash.com/photo-1556821840-3a63f95609a7?auto=format&fit=crop&q=80&w=800',
    ownerName: 'Marc D.',
    postedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Item(
    id: '6',
    title: 'Scientific Calculator TI-84',
    description:
        'Texas Instruments TI-84 Plus. Required for several EPFL courses. Works perfectly, battery recently replaced. Available to lend for the semester.',
    price: 5.00,
    category: 'Electronics',
    type: ItemType.lend,
    ownerName: 'Yuki T.',
    postedAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
];

// ── Dashboard page ─────────────────────────────────────────────
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: mockItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        final item = mockItems[index];
        return _ItemCard(item: item, timeAgo: _timeAgo(item.postedAt));
      },
    );
  }
}

// ── Item card ──────────────────────────────────────────────────
class _ItemCard extends StatelessWidget {
  final Item item;
  final String timeAgo;

  const _ItemCard({required this.item, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    final isLend = item.type == ItemType.lend;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        // TODO: navigate to item detail
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Optional image ───────────────────────────
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  item.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 160,
                      color: Colors.grey.withValues(alpha: 0.08),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFE2001A),
                        ),
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row: title + badge ─────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Sell / Lend badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isLend
                              ? Colors.blue.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isLend
                                ? Colors.blue.withValues(alpha: 0.3)
                                : Colors.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          isLend ? 'Lend' : 'Sell',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isLend ? Colors.blue : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ── Category chip ──────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2001A).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFE2001A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Description ────────────────────────
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // ── Bottom row: price + owner + time ───
                  Row(
                    children: [
                      // Price
                      Text(
                        isLend
                            ? 'CHF ${item.price.toStringAsFixed(2)}/day'
                            : 'CHF ${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE2001A),
                        ),
                      ),

                      const Spacer(),

                      // Owner avatar
                      CircleAvatar(
                        radius: 10,
                        backgroundColor:
                            const Color(0xFFE2001A).withValues(alpha: 0.15),
                        child: Text(
                          item.ownerName[0],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFE2001A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),

                      // Owner name
                      Text(
                        item.ownerName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Time ago
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}