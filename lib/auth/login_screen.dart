import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email and password are required')));
      return;
    }

    setState(() => _loading = true);
    try {
      await _authService.login(email, password);
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.pos);
      }
    } catch (e) {
      String message = 'Login failed. Check your credentials.';
      if (e is Exception) {
        message = e.toString();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Container(
            width: 430,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Manyam Mart POS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                const SizedBox(height: 6),
                const Text('Login to continue', style: TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 47,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: _loading ? null : _login,
                    child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
