import 'package:epfl_lend_borrow/screens/pages/login/create_user.dart';
import 'package:epfl_lend_borrow/screens/pages/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'main_page.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage; // shown below the button on failure

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null; // clear any previous error
    });

    try {
      // 1. Call FastAPI — get the JWT token back
      final token = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // 2. Save the token in SharedPreferences
      await AuthService.saveToken(token);

      // 3. Navigate to the main app
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScaffold()),
      );
    } catch (e) {
      // Show the error message under the button
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // ── Header ──────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/epfl.png',
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'LendNBorrow',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE2001A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'The EPFL student marketplace',
                      style: TextStyle(fontSize: 14, color: Colors.black45),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 52),

              // ── Form ─────────────────────────────────────────
              const Text(
                'Sign in',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Use your EPFL email to continue',
                style: TextStyle(fontSize: 13, color: Colors.black45),
              ),
              const SizedBox(height: 28),

              // Email field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'firstname.lastname@epfl.ch',
                  hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
                  prefixIcon: const Icon(Icons.mail_outline, color: Colors.black38, size: 20),
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
              ),

              const SizedBox(height: 16),

              // Password field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.black38, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.black38,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
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
              ),

              const SizedBox(height: 12),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFE2001A),
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Forgot password?', style: TextStyle(fontSize: 13)),
                ),
              ),

              const SizedBox(height: 28),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _emailController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty &&
                          !_isLoading
                      ? _onLoginPressed
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2001A),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey.shade400,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Sign in',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              // ── Error message ─────────────────────────────────
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFE2001A), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFE2001A),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('New here?',
                        style: TextStyle(color: Colors.black38, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                ],
              ),

              const SizedBox(height: 20),

              // Register button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: navigate to register page
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateAccountPage()));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE2001A),
                    side: const BorderSide(color: Color(0xFFE2001A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create an account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}