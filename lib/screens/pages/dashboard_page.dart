import 'package:epfl_lend_borrow/screens/pages/filters/brand_filter.dart';
import 'package:epfl_lend_borrow/screens/pages/filters/type_filter.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/item.dart';
import 'filters/price_filter.dart';
import 'filters/category_filter.dart';
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<Item>> _itemsFuture;
  late Map<ItemCategory,bool> _selectedCategories={};
  late Map<ItemBrand,bool> _selectedBrands={};
  late Map<ItemType,bool> _selectedTypes={};

  @override
  void initState() {
    super.initState();
    _selectedCategories.clear();
    _itemsFuture = ApiService.getItems(); // kick off the API call immediately
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Item>>(
      future: _itemsFuture,
      builder: (context, snapshot) {

        // ── Loading ──────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE2001A)),
          );
        }

        // ── Error ────────────────────────────────────────────
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.black26),
                const SizedBox(height: 12),
                Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  style: const TextStyle(color: Colors.black45, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() {
                    _itemsFuture = ApiService.getItems(); // retry
                  }),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Color(0xFFE2001A)),
                  ),
                ),
              ],
            ),
          );
        }

        // ── Empty ────────────────────────────────────────────
        final items = snapshot.data!;
        if (items.isEmpty) {
          return const Center(
            child: Text(
              'No items yet. Be the first to post!',
              style: TextStyle(color: Colors.black45),
            ),
          );
        }

        // ── List ─────────────────────────────────────────────
        return RefreshIndicator(
          color: const Color(0xFFE2001A),
          onRefresh: () async {
            setState(() {
              _itemsFuture = ApiService.getItems(); // pull-to-refresh
            });
          },
          child: Column(
            children: [
              Row(children: [
                ElevatedButton(onPressed: ()async{final result = await showModalBottomSheet(context: context,isScrollControlled: true,builder: (context) => CategoryPage(chosenCat: Map.from(_selectedCategories)),);if(result!=null){setState((){_selectedCategories=Map.from(result);});}},child: Text('category')),
                ElevatedButton(onPressed: ()async{final result = await showModalBottomSheet(context: context,isScrollControlled: true,builder: (context) => BrandPage(chosenBrand: _selectedBrands),);if (result != null) {setState(() {_selectedBrands = result;});}},child: Text('brand')),
                ElevatedButton(onPressed: ()async{final result = await showModalBottomSheet(context: context,isScrollControlled: true,builder: (context) => TypePage(chosenType: _selectedTypes),);if (result != null) {setState(() {_selectedTypes = result;});}},child: Text('type')),
              ],),
              ElevatedButton(onPressed: ()async{setState((){_itemsFuture = ApiService.getItemsAlongFilter(_selectedCategories,Map<ItemType, dynamic>.from(_selectedTypes),Map<ItemBrand, dynamic>.from(_selectedBrands));});}, child: Text('apply filter(s)')),//needs to be fixed

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 0),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _ItemCard(item: item);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Item card ──────────────────────────────────────────────────
class _ItemCard extends StatelessWidget {
  final Item item;

  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isLend = item.type == ItemType.lend;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        // TODO: navigate to item detail
      },
      behavior: HitTestBehavior.opaque, 
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Optional image ───────────────────────────
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

                  // ── Bottom row: price + owner ──────────
                  Row(
                    children: [
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
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: const Color(0xFFE2001A).withValues(alpha: 0.15),
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
                      Text(
                        item.ownerName,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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