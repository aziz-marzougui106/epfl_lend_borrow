import 'package:epfl_lend_borrow/services/api_service.dart';
import 'package:epfl_lend_borrow/services/auth_service.dart';
import 'package:flutter/material.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _formIsValid =>
      _nameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _passwordController.text.length >= 8 &&
      _passwordController.text == _confirmPasswordController.text;

  void _onRegisterPressed() async {
    if (!_formIsValid) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: call ApiService.register(...)
      final token = await ApiService.register(_nameController.text,_emailController.text, _passwordController.text);
      await AuthService.saveToken(token);
      await Future.delayed(const Duration(seconds: 1)); // placeholder

      if (!mounted) return;
      // Go back to login after successful registration
      Navigator.pop(context);
    } catch (e) {
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Header ──────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/epfl.png',
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'LendNBorrow',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE2001A),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              const Text(
                'Create account',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Join the EPFL student marketplace',
                style: TextStyle(fontSize: 13, color: Colors.black45),
              ),
              const SizedBox(height: 28),

              // ── Full name ────────────────────────────────────
              _buildTextField(
                controller: _nameController,
                hint: 'Full name',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 16),

              // ── Email ────────────────────────────────────────
              _buildTextField(
                controller: _emailController,
                hint: 'firstname.lastname@epfl.ch',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // ── Password ─────────────────────────────────────
              _buildTextField(
                controller: _passwordController,
                hint: 'Password (min. 8 characters)',
                icon: Icons.lock_outline,
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.black38,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 16),

              // ── Confirm password ─────────────────────────────
              _buildTextField(
                controller: _confirmPasswordController,
                hint: 'Confirm password',
                icon: Icons.lock_outline,
                obscure: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.black38,
                    size: 20,
                  ),
                  onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),

              // Password mismatch hint
              if (_confirmPasswordController.text.isNotEmpty &&
                  _passwordController.text != _confirmPasswordController.text) ...[
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.error_outline, color: Color(0xFFE2001A), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Passwords do not match',
                      style: TextStyle(color: Color(0xFFE2001A), fontSize: 12),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // ── Register button ──────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _formIsValid && !_isLoading ? _onRegisterPressed : null,
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
                          'Create account',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              // ── Error message ────────────────────────────────
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFE2001A), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                            color: Color(0xFFE2001A), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // ── Back to login ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.black45, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Color(0xFFE2001A),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.black38, size: 20),
        suffixIcon: suffixIcon,
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
}