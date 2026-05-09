import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ── Message model ──────────────────────────────────────────────
class _Message {
  final String text;
  final bool isUser;
  final DateTime time;

  _Message({
    required this.text,
    required this.isUser,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

// ── Post Item Page ─────────────────────────────────────────────
class PostItemPage extends StatefulWidget {
  const PostItemPage({super.key});

  @override
  State<PostItemPage> createState() => _PostItemPageState();
}

class _PostItemPageState extends State<PostItemPage> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  final List<_Message> _messages = [];
  final List<Map<String, String>> _conversationHistory = [];
  bool _isLoading = false;
  bool _isTyping = false;

  // System prompt that tells Claude its role
  static const String _systemPrompt = '''
You are a helpful assistant for LendNBorrow, an EPFL student marketplace app.
Your job is to help students post items they want to sell or lend to other students.

Your conversation flow:
1. Greet warmly and ask what item they want to post
2. Based on their answer, ask relevant follow-up questions:
   - Electronics: brand, model, year, condition (1-10), accessories included
   - Books: title, author, edition, which EPFL course it's for
   - Clothing: brand, size, condition, how many times worn
   - Furniture: dimensions, material, condition
   - Other: relevant details that help buyers/borrowers
3. Ask if they want to sell or lend it
   - If sell: ask for price in CHF
   - If lend: ask for price per day in CHF
4. Ask if they want to add any additional details
5. Once you have enough info, say exactly "SUMMARY_READY" on its own line,
   then provide a clean structured summary like:
   ---
   Title: [item name]
   Type: [Sell/Lend]
   Price: CHF [amount]
   Category: [Electronics/Books/Clothing/Furniture/Other]
   Description: [full natural description of the item]
   ---

Keep responses SHORT — one or two questions max per message.
Be friendly and use casual language appropriate for students.
Never ask more than 2 questions at once.
''';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
    _startConversation();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  // Send first greeting from Claude
  void _startConversation() async {
    setState(() => _isLoading = true);
    final greeting = await _sendToClaudeApi(
      userMessage: 'Start the conversation',
      isFirstMessage: true,
    );
    setState(() {
      _messages.add(_Message(text: greeting, isUser: false));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  Future<String> _sendToClaudeApi({
    required String userMessage,
    bool isFirstMessage = false,
  }) async {
    // ──────────────────────────────────────────────────────────────
    // TODO: REAL API INTEGRATION
    // When FastAPI backend is ready, replace this entire method with:
    //
    // final response = await http.post(
    //   Uri.parse('https://your-fastapi-url.com/api/agent/ask'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({
    //     'message': userMessage,
    //     'history': _conversationHistory,
    //     'is_first_message': isFirstMessage,
    //   }),
    // );
    // return jsonDecode(response.body)['reply'];
    //
    // The FastAPI endpoint will handle the Anthropic API key securely.
    // Never call Anthropic directly from Flutter — key must stay on server.
    // ──────────────────────────────────────────────────────────────
    try {
      // Build messages list for API
      final List<Map<String, String>> messages = isFirstMessage
          ? [
              {
                'role': 'user',
                'content':
                    'Please greet me and ask what item I want to post. Be warm and brief.',
              }
            ]
          : [
              ..._conversationHistory,
              {'role': 'user', 'content': userMessage},
            ];

      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 1024,
          'system': _systemPrompt,
          'messages': messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['content'][0]['text'] as String;

        // Update conversation history
        if (!isFirstMessage) {
          _conversationHistory.add({
            'role': 'user',
            'content': userMessage,
          });
        }
        _conversationHistory.add({
          'role': 'assistant',
          'content': reply,
        });

        return reply;
      } else {
        return 'Sorry, something went wrong. Please try again.';
      }
    } catch (e) {
      return 'Connection error. Please check your internet.';
    }
  }

  void _onSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Add user message
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _isLoading = true;
      _isTyping = false;
      _controller.clear();
    });
    _scrollToBottom();

    // Check if summary is ready
    final reply = await _sendToClaudeApi(userMessage: text);
    final isSummaryReady = reply.contains('SUMMARY_READY');

    setState(() {
      _messages.add(_Message(
        text: reply.replaceAll('SUMMARY_READY', '').trim(),
        isUser: false,
      ));
      _isLoading = false;
    });
    _scrollToBottom();

    // Show confirm button if summary is ready
    if (isSummaryReady) {
      _showConfirmDialog();
    }
  }

  void _showConfirmDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.check_circle_outline,
              color: Color(0xFFE2001A),
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Ready to post!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your item has been described. Would you like to post it to the marketplace?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2001A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: send to FastAPI backend
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item posted successfully! 🎉'),
                      backgroundColor: Color(0xFFE2001A),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Post item',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE2001A),
                  side: const BorderSide(color: Color(0xFFE2001A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Keep editing',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post an item',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Optional photo button
          IconButton(
            icon: const Icon(Icons.photo_camera_outlined),
            onPressed: () {
              // TODO: image picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo upload coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Subtitle ────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Describe your item — the AI will guide you through the rest.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),

          // ── Messages list ────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading bubble
                if (index == _messages.length) {
                  return _TypingBubble();
                }
                final message = _messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),

          // ── Input area ───────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.12),
                ),
              ),
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
                      controller: _controller,
                      enabled: !_isLoading,
                      maxLines: null,
                      style: const TextStyle(fontSize: 14),
                      onChanged: (val) {
                        setState(() => _isTyping = val.trim().isNotEmpty);
                      },
                      onSubmitted: (_) => _onSend(),
                      decoration: const InputDecoration(
                        hintText: 'Type your reply...',
                        hintStyle: TextStyle(fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _isTyping && !_isLoading
                        ? const Color(0xFFE2001A)
                        : Colors.grey.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded),
                    color: _isTyping && !_isLoading
                        ? Colors.white
                        : Colors.grey,
                    onPressed: _isTyping && !_isLoading ? _onSend : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message bubble ─────────────────────────────────────────────
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
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
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: isUser
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// ── Typing indicator ───────────────────────────────────────────
class _TypingBubble extends StatefulWidget {
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
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
                      alpha: (i == 0
                              ? _animation.value
                              : i == 1
                                  ? (_animation.value + 0.3).clamp(0.3, 1.0)
                                  : (_animation.value + 0.6).clamp(0.3, 1.0)),
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