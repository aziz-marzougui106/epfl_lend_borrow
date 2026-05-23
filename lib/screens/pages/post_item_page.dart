import 'package:flutter/material.dart';
import '../../models/item.dart';
import '../../services/api_service.dart';

// ── Message model ──────────────────────────────────────────────
class _Message {
  final String text;
  final bool isUser;
  _Message({required this.text, required this.isUser});
}

// ── Post Item Page (parent) ────────────────────────────────────
class PostItemPage extends StatefulWidget {
  const PostItemPage({super.key});
  @override
  State<PostItemPage> createState() => _PostItemPageState();
}

class _PostItemPageState extends State<PostItemPage> {
  bool _inChatPhase = false;

  final _priceController = TextEditingController();
  ItemCategory? _selectedCategory;
  ItemBrand? _selectedBrand;
  ItemCondition? _selectedCondition;
  ItemType? _selectedType;

  final List<_Message> _messages = [];
  final _chatController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isTyping = false;
  bool _isDone = false;
  String _finalDescription = '';

  @override
  void dispose() {
    _priceController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _formIsValid =>
      _priceController.text.isNotEmpty &&
      _selectedCategory != null &&
      _selectedBrand != null &&
      _selectedCondition != null &&
      _selectedType != null;

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSend({bool isFirst = false}) async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _isLoading = true;
      _isTyping = false;
      _chatController.clear();
    });
    _scrollToBottom();

    try {
      final result = await ApiService.postMessage(
        message: text,
        isFirstMessage: isFirst,
        category: _selectedCategory!.name,
        brand: _selectedBrand!.name,
        condition: _selectedCondition!.name,
        type: _selectedType!.name,
        price: double.parse(_priceController.text),
      );

      final reply = result['reply'] as String;
      final done = result['done'] as bool;

      setState(() {
        _messages.add(_Message(text: reply, isUser: false));
        _isLoading = false;
        if (done) {
          _isDone = true;
          _finalDescription = reply;
        }
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(_Message(
          text: 'Something went wrong. Please try again.',
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  void _onFirstMessage() {
    if (!_formIsValid || _chatController.text.trim().isEmpty) return;
    setState(() => _inChatPhase = true);
    _onSend(isFirst: true);
  }

  void _showConfirmDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.check_circle_outline, color: Color(0xFFE2001A), size: 48),
            const SizedBox(height: 12),
            const Text('Ready to post!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Your item description is complete. Post it to the marketplace?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2001A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitItem,
                child: const Text('Post item',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.black45, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitItem() async {
    try {
      await ApiService.createItem(
        title: '${_selectedBrand!.name} item',
        description: _finalDescription,
        price: double.parse(_priceController.text),
        category: _selectedCategory!.name,
        type: _selectedType!.name,
        brand: _selectedBrand!.name,
      );
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item posted successfully!'),
          backgroundColor: Color(0xFFE2001A),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _inChatPhase ? 'Describe your item' : 'Post an item',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: _inChatPhase
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed: () => setState(() {
                  _inChatPhase = false;
                  _messages.clear();
                  _isDone = false;
                }),
              )
            : null,
      ),
      body: _inChatPhase ? _buildChatPhase() : _buildFormPhase(),
    );
  }

  Widget _buildFormPhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fill in the fixed details, then describe your item to our AI.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),

          _buildLabel('Category'),
          const SizedBox(height: 8),
          _buildDropdown<ItemCategory>(
            value: _selectedCategory,
            hint: 'Select a category',
            items: ItemCategory.values,
            onChanged: (v) => setState(() => _selectedCategory = v),
            itemLabel: (cat) => switch(cat) {
                        ItemCategory.electronics => 'Electronics',
                        ItemCategory.books => 'Books',
                        ItemCategory.sports => 'Sports',
                        ItemCategory.clothing => 'Clothing',
                        ItemCategory.tools => 'Tools',
                        ItemCategory.furniture => 'Furniture',
                        ItemCategory.kitchen => 'Kitchen',
                        ItemCategory.other => 'Other',
                      },
          ),

          const SizedBox(height: 20),
          _buildLabel('Brand'),
          const SizedBox(height: 8),
          _buildDropdown<ItemBrand>(
            value: _selectedBrand,
            hint: 'Select a brand',
            items: ItemBrand.values,
            onChanged: (v) => setState(() => _selectedBrand = v),
            itemLabel: (cat) => cat.name[0].toUpperCase() + cat.name.substring(1),
          ),

          const SizedBox(height: 20),
          _buildLabel('Condition'),
          const SizedBox(height: 8),
          _buildDropdown<ItemCondition>(
            value: _selectedCondition,
            hint: 'Select condition',
            items: ItemCondition.values,
            onChanged: (v) => setState(() => _selectedCondition = v),
            itemLabel: (cat) => cat.name[0].toUpperCase() + cat.name.substring(1),
          ),

          const SizedBox(height: 20),
          _buildLabel('Listing type'),
          const SizedBox(height: 8),
          Row(
            children: [
              _TypeChip(
                label: 'Sell',
                selected: _selectedType == ItemType.sell,
                color: Colors.green,
                onTap: () => setState(() => _selectedType = ItemType.sell),
              ),
              const SizedBox(width: 12),
              _TypeChip(
                label: 'Lend',
                selected: _selectedType == ItemType.lend,
                color: Colors.blue,
                onTap: () => setState(() => _selectedType = ItemType.lend),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _buildLabel(
            _selectedType == ItemType.lend ? 'Price (CHF/day)' : 'Price (CHF)',
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _priceController,
            hint: '0.00',
            icon: Icons.attach_money,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),

          if (_formIsValid) ...[
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Now describe your item to get started',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              'The AI will guide you from here.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _chatController,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'e.g. I have a Sony WH-1000XM4, barely used...',
                hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2001A), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _chatController.text.trim().isNotEmpty ? _onFirstMessage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2001A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade200,
                  disabledForegroundColor: Colors.grey.shade400,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continue with AI',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildChatPhase() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Answer the AI\'s questions to build your listing.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) return _TypingBubble();
              return _MessageBubble(message: _messages[index]);
            },
          ),
        ),
        if (_isDone)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: _showConfirmDialog,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Create post',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2001A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.12))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isTyping
                          ? const Color(0xFFE2001A).withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: TextField(
                    controller: _chatController,
                    enabled: !_isLoading && !_isDone,
                    maxLines: null,
                    style: const TextStyle(fontSize: 14),
                    onChanged: (val) => setState(() => _isTyping = val.trim().isNotEmpty),
                    onSubmitted: (_) => _onSend(),
                    decoration: const InputDecoration(
                      hintText: 'Type your reply...',
                      hintStyle: TextStyle(fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _isTyping && !_isLoading && !_isDone
                      ? const Color(0xFFE2001A)
                      : Colors.grey.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_upward_rounded),
                  color: _isTyping && !_isLoading && !_isDone ? Colors.white : Colors.grey,
                  onPressed: _isTyping && !_isLoading && !_isDone ? _onSend : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87));

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.black38, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2001A), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      hint: Text(hint),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2001A), width: 1.5),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabel(item)
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeChip({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.5) : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? color : Colors.black45)),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFFE2001A)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(message.text,
            style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isUser ? Colors.white : Theme.of(context).colorScheme.onSurface)),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(
                      alpha: i == 0
                          ? _animation.value
                          : i == 1
                              ? (_animation.value + 0.3).clamp(0.3, 1.0)
                              : (_animation.value + 0.6).clamp(0.3, 1.0),
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import '../../models/item.dart';
// import '../../services/api_service.dart';

// class PostItemPage extends StatefulWidget {
//   const PostItemPage({super.key});

//   @override
//   State<PostItemPage> createState() => _PostItemPageState();
// }

// class _PostItemPageState extends State<PostItemPage> {
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _priceController = TextEditingController();

//   ItemCategory? _selectedCategory;
//   ItemType? _selectedType;
//   bool _isLoading = false;
//   String? _errorMessage;

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _priceController.dispose();
//     super.dispose();
//   }

//   bool get _formIsValid =>
//       _titleController.text.isNotEmpty &&
//       _descriptionController.text.isNotEmpty &&
//       _priceController.text.isNotEmpty &&
//       _selectedCategory != null &&
//       _selectedType != null;

//   void _onPostPressed() {
//     if (!_formIsValid) return;
//     _showConfirmDialog();
//   }

//   void _showConfirmDialog() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.surface,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.withValues(alpha: 0.3),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Icon(Icons.check_circle_outline, color: Color(0xFFE2001A), size: 48),
//             const SizedBox(height: 12),
//             const Text(
//               'Ready to post!',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Post "${_titleController.text}" for CHF ${_priceController.text}?',
//               style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _submitItem,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE2001A),
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: _isLoading
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : const Text(
//                         'Post item',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                       ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text(
//                   'Cancel',
//                   style: TextStyle(color: Colors.black45, fontSize: 15),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _submitItem() async {
//     setState(() => _isLoading = true);

//     try {
//       await ApiService.createItem(
//         title: _titleController.text.trim(),
//         description: _descriptionController.text.trim(),
//         brand:'sony',
//         price: double.parse(_priceController.text),
//         category: _selectedCategory!.name,
//         type: _selectedType!.name,
//       );

//       if (!mounted) return;
//       Navigator.pop(context); // close bottom sheet

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Item posted successfully!'),
//           backgroundColor: Color(0xFFE2001A),
//         ),
//       );

//       // Clear form
//       setState(() {
//         _titleController.clear();
//         _descriptionController.clear();
//         _priceController.clear();
//         _selectedCategory = null;
//         _selectedType = null;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       Navigator.pop(context); // close bottom sheet
//       setState(() {
//         _errorMessage = e.toString().replaceFirst('Exception: ', '');
//       });
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Post an item',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.photo_camera_outlined),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Photo upload coming soon!')),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Fill in the details below to list your item.',
//               style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
//             ),

//             const SizedBox(height: 24),

//             // ── Title ────────────────────────────────────────
//             _buildLabel('Title'),
//             const SizedBox(height: 8),
//             _buildTextField(
//               controller: _titleController,
//               hint: 'e.g. MacBook Pro 16", TI-84 Calculator',
//               icon: Icons.title,
//             ),

//             const SizedBox(height: 20),

//             // ── Description ──────────────────────────────────
//             _buildLabel('Description'),
//             const SizedBox(height: 8),
//             _buildTextField(
//               controller: _descriptionController,
//               hint: 'Describe the condition, what\'s included, etc.',
//               icon: Icons.notes,
//               maxLines: 4,
//             ),

//             const SizedBox(height: 20),

//             // ── Category ─────────────────────────────────────
//             _buildLabel('Category'),
//             const SizedBox(height: 8),
//             DropdownButtonFormField<ItemCategory>(
//               initialValue: _selectedCategory,
//               hint: const Text('Select a category'),
//               decoration: _dropdownDecoration(),
//               items: ItemCategory.values
//                   .map((cat) => DropdownMenuItem(
//                         value: cat,
//                         child: Text(cat.name[0].toUpperCase() + cat.name.substring(1)),
//                       ))
//                   .toList(),
//               onChanged: (val) => setState(() => _selectedCategory = val),
//             ),

//             const SizedBox(height: 20),

//             // ── Type ─────────────────────────────────────────
//             _buildLabel('Listing type'),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 _TypeChip(
//                   label: 'Sell',
//                   selected: _selectedType == ItemType.sell,
//                   color: Colors.green,
//                   onTap: () => setState(() => _selectedType = ItemType.sell),
//                 ),
//                 const SizedBox(width: 12),
//                 _TypeChip(
//                   label: 'Lend',
//                   selected: _selectedType == ItemType.lend,
//                   color: Colors.blue,
//                   onTap: () => setState(() => _selectedType = ItemType.lend),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // ── Price ─────────────────────────────────────────
//             _buildLabel(
//               _selectedType == ItemType.lend ? 'Price (CHF/day)' : 'Price (CHF)',
//             ),
//             const SizedBox(height: 8),
//             _buildTextField(
//               controller: _priceController,
//               hint: '0.00',
//               icon: Icons.attach_money,
//               keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             ),

//             // ── Error ─────────────────────────────────────────
//             if (_errorMessage != null) ...[
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   const Icon(Icons.error_outline, color: Color(0xFFE2001A), size: 16),
//                   const SizedBox(width: 6),
//                   Expanded(
//                     child: Text(
//                       _errorMessage!,
//                       style: const TextStyle(color: Color(0xFFE2001A), fontSize: 13),
//                     ),
//                   ),
//                 ],
//               ),
//             ],

//             const SizedBox(height: 32),

//             // ── Post button ───────────────────────────────────
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton(
//                 onPressed: _formIsValid ? _onPostPressed : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE2001A),
//                   foregroundColor: Colors.white,
//                   disabledBackgroundColor: Colors.grey.shade200,
//                   disabledForegroundColor: Colors.grey.shade400,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Review & post',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 32),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLabel(String text) {
//     return Text(
//       text,
//       style: const TextStyle(
//         fontSize: 14,
//         fontWeight: FontWeight.w600,
//         color: Colors.black87,
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     int maxLines = 1,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return TextField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: keyboardType,
//       onChanged: (_) => setState(() {}),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
//         prefixIcon: maxLines == 1
//             ? Icon(icon, color: Colors.black38, size: 20)
//             : null,
//         filled: true,
//         fillColor: Colors.grey.shade50,
//         contentPadding: EdgeInsets.symmetric(
//           vertical: maxLines > 1 ? 14 : 16,
//           horizontal: maxLines > 1 ? 16 : 0,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade200),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade200),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFFE2001A), width: 1.5),
//         ),
//       ),
//     );
//   }

//   InputDecoration _dropdownDecoration() {
//     return InputDecoration(
//       filled: true,
//       fillColor: Colors.grey.shade50,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade200),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade200),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFE2001A), width: 1.5),
//       ),
//     );
//   }
// }

// // ── Type chip ──────────────────────────────────────────────────
// class _TypeChip extends StatelessWidget {
//   final String label;
//   final bool selected;
//   final Color color;
//   final VoidCallback onTap;

//   const _TypeChip({
//     required this.label,
//     required this.selected,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//         decoration: BoxDecoration(
//           color: selected ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: selected ? color.withValues(alpha: 0.5) : Colors.grey.shade200,
//             width: selected ? 1.5 : 1,
//           ),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: selected ? color : Colors.black45,
//           ),
//         ),
//       ),
//     );
//   }
// }