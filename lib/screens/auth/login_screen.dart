import 'package:flutter/material.dart';
import '../../models/lesson_model.dart';
import '../app/main_screen.dart';
import 'auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (_) => MainScreen(progress: UserProgress(streak: 1))),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AuthTopBar(progress: 0.0, onBack: () => Navigator.pop(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    const Text('Connexion',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('Bon retour parmi nous !',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 14)),
                    const SizedBox(height: 32),
                    AuthInput(
                        controller: _emailCtrl,
                        hint: 'E-mail',
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    AuthInput(
                      controller: _passCtrl,
                      hint: 'Mot de passe',
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 20),
                    OrangeButton(label: 'SE CONNECTER', onTap: _login),
                    const SizedBox(height: 12),
                    GoogleButton(onTap: _login),
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