import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../app/main_screen.dart';
import 'auth_widgets.dart';
import 'name_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _ageCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ageCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    if (_ageCtrl.text.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NameScreen(age: _ageCtrl.text.trim()),
      ),
    );
  }

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    final result = await AuthService().signInWithGoogle();
    if (mounted) {
      setState(() => _loading = false);
      if (result.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(
              progress: result.user!.toUserProgress(),
              uid: result.user!.uid,
            ),
          ),
          (_) => false,
        );
      } else {
        _showError(result.error!);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AuthTopBar(
                progress: 0.20,
                onBack: () => Navigator.pop(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    const Text('crée ton compte avec',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    AuthInput(
                      controller: _ageCtrl,
                      hint: 'Âge',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _loading
                        ? const CircularProgressIndicator(
                            color: AppTheme.primary)
                        : GoogleButton(onTap: _googleSignIn),
                    const SizedBox(height: 12),
                    OrangeButton(
                        label: 'CONTINUE', onTap: _continue),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}