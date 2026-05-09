import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isProcessing = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isProcessing = true);
    _fadeController.forward();

    // Simulate AI processing — replace with real FastAPI call later
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      _fadeController.reverse();
      setState(() {
        _isProcessing = false;
        _controller.clear();
        _isTyping = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // ── Top label ──────────────────────────────────
              const Text(
                'LendNBorrow',
                style: TextStyle(
                  color: Color(0xFFE2001A),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'What do you need today?',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 40),

              // ── Animation area ─────────────────────────────
              Expanded(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    // Idle — nothing typed yet
                    if (!_isTyping && !_isProcessing) {
                      return const _IdlePrompt();
                    }
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Circles — typing state
                        Opacity(
                          opacity: 1 - _fadeAnimation.value,
                          child: Lottie.asset(
                            'assets/lotties/ai_listening.json',
                            width: 200,
                            height: 200,
                          ),
                        ),

                        // Scope — processing state
                        if (_isProcessing)
                          Opacity(
                            opacity: _fadeAnimation.value,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  'assets/lotties/ai_searching.json',
                                  width: 200,
                                  height: 200,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Finding the best match for you...',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              // ── Input area ─────────────────────────────────
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isTyping
                        ? const Color(0xFFE2001A).withValues(alpha: 0.6)
                        : Colors.white12,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !_isProcessing,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        maxLines: null,
                        onChanged: (val) {
                          setState(() => _isTyping = val.trim().isNotEmpty);
                        },
                        onSubmitted: (_) => _onSubmit(),
                        decoration: const InputDecoration(
                          hintText: 'e.g. I need a calculator for my exam...',
                          hintStyle: TextStyle(
                            color: Colors.white24,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    // Send button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isTyping && !_isProcessing
                            ? const Color(0xFFE2001A)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white38,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.arrow_upward_rounded),
                        color: _isTyping ? Colors.white : Colors.white24,
                        onPressed:
                            _isTyping && !_isProcessing ? _onSubmit : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Idle state ─────────────────────────────────────────────────
class _IdlePrompt extends StatelessWidget {
  const _IdlePrompt();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.auto_awesome,
          color: Color(0xFFE2001A),
          size: 48,
        ),
        const SizedBox(height: 20),
        const Text(
          'Tell the AI what you need',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'It will search, match, and contact\nthe right people for you.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white38,
            fontSize: 13,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}