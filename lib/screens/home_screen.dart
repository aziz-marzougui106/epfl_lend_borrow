import 'package:flutter/material.dart';
import '../models/item.dart';
import '../widgets/item_card.dart';
import '../widgets/category_selector.dart';
import 'item_detail_screen.dart';

/// The main dashboard of the application.
///
/// This screen displays a list of available items and categories,
/// allowing the user to filter items by category and browse the marketplace.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State class for [HomeScreen] that manages the category selection
/// and holds the static list of all items.
class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> categories = ['All', 'Electronics', 'Books', 'Furniture', 'Clothing'];
  String selectedCategory = 'All';
  bool _isSearching = false;
  String _searchQuery = '';

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

  /// Builds the visual structure of the home screen, including
  /// an app bar, a category selector, and a grid of items.
  @override
  Widget build(BuildContext context) {
    final filteredItems = allItems.where((item) {
      final matchesCategory = selectedCategory == 'All' || item.category == selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
                            item.title.toLowerCase().contains(_searchQuery) ||
                            item.description.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      key:_scaffoldKey,
      appBar: AppBar(
        leadingWidth: 120,
        toolbarHeight: 40.0,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              

            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/images/epfl.png',fit: BoxFit.contain,),
            ),
          ],
        ),
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search items...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: const TextStyle(color: Colors.black87),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query.toLowerCase();
                  });
                },
              )
            : const Text('LendNBorrow', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black87),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
            onPressed: () {
              //buying functionality
            },
          ),
        ],
      ),
      drawer: Drawer(
        
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(child: Text('drawer'),),
              Tab(text:'Preferences'),
              Tab(text:'History'),
              Tab(text:'Bookmarks'),
              ListTile(title:Text('logout'),tileColor: const Color.fromARGB(255, 140, 241, 231),)
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
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
        ],
      ),
      floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: (){
                  print("hello");
                }
              ),
              SizedBox( height: 10.0,),
              FloatingActionButton(
                child: Icon(Icons.person),
                onPressed: (){
                  print("profile");
                }
              )
            ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations:[
          NavigationDestination(icon: Icon(Icons.home), label: 'home'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'settings')
        ],
        onDestinationSelected: (value) {
          print(value==0?'asba':'settings');
        },
        selectedIndex: 1,
      ),
    );
  }
}
