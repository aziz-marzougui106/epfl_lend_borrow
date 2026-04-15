import 'package:flutter/material.dart';
import '../models/item.dart';
import '../widgets/item_card.dart';
import '../widgets/category_selector.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = ['All', 'Electronics', 'Books', 'Furniture', 'Clothing'];
  String selectedCategory = 'All';

  final List<Item> allItems = [
    Item(
      id: '1',
      title: 'MacBook Pro 16"',
      description: 'Barely used MacBook Pro 16-inch. M1 Max, 32GB RAM, 1TB SSD. Perfect for coding and design.',
      price: 1899.00,
      imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&q=80&w=800',
      category: 'Electronics',
    ),
    Item(
      id: '2',
      title: 'Calculus Early Transcendentals',
      description: 'Used textbook for math 101. Some highlighting but overall good condition.',
      price: 45.00,
      imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=800',
      category: 'Books',
    ),
    Item(
      id: '3',
      title: 'Ergonomic Desk Chair',
      description: 'Herman Miller Aeron chair, size B. Great for long study sessions.',
      price: 450.00,
      imageUrl: 'https://images.unsplash.com/photo-1505843490538-5133c6c7d0e1?auto=format&fit=crop&q=80&w=800',
      category: 'Furniture',
    ),
    Item(
      id: '4',
      title: 'EPFL Hoodie',
      description: 'Size M. Very warm and comfortable. Worn a few times.',
      price: 30.00,
      imageUrl: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?auto=format&fit=crop&q=80&w=800',
      category: 'Clothing',
    ),
    Item(
      id: '5',
      title: 'Sony WH-1000XM4',
      description: 'Noise cancelling headphones playing perfect audio. Box included.',
      price: 200.00,
      imageUrl: 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&q=80&w=800',
      category: 'Electronics',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredItems = selectedCategory == 'All'
        ? allItems
        : allItems.where((item) => item.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Marketplace', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          CategorySelector(
            categories: categories,
            onCategorySelected: (category) {
              setState(() {
                selectedCategory = category;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: filteredItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  return ItemCard(
                    item: filteredItems[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailScreen(item: filteredItems[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
