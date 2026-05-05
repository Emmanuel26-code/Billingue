import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'name_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _ageCtrl = TextEditingController();

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
          builder: (_) => NameScreen(age: _ageCtrl.text.trim())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AuthTopBar(progress: 0.20, onBack: () => Navigator.pop(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    const Text('crée ton compte avec',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    AuthInput(
                        controller: _ageCtrl,
                        hint: 'Âge',
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    GoogleButton(onTap: _continue),
                    const SizedBox(height: 12),
                    OrangeButton(label: 'CONTINUE', onTap: _continue),
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