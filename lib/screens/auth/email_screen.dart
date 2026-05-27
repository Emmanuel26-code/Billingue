import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'auth_widgets.dart';
import 'password_screen.dart';

class EmailScreen extends StatefulWidget {
  final String age;
  final String nom;
  final String prenom;

  const EmailScreen({
    super.key,
    required this.age,
    required this.nom,
    required this.prenom,
  });

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    if (_emailCtrl.text.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PasswordScreen(
          age: widget.age,
          nom: widget.nom,
          prenom: widget.prenom,
          email: _emailCtrl.text.trim(),
        ),
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
                progress: 0.60,
                onBack: () => Navigator.pop(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    const Text('Quelle est ton adresse e-mail ?',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    AuthInput(
                      controller: _emailCtrl,
                      hint: 'E-mail',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
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