import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'email_screen.dart';

class NameScreen extends StatefulWidget {
  final String age;
  const NameScreen({super.key, required this.age});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    if (_nomCtrl.text.trim().isEmpty || _prenomCtrl.text.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmailScreen(
          age: widget.age,
          nom: _nomCtrl.text.trim(),
          prenom: _prenomCtrl.text.trim(),
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
            AuthTopBar(progress: 0.40, onBack: () => Navigator.pop(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    const Text('comment t\'appelles-tu ?',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    AuthInput(controller: _nomCtrl, hint: 'Nom'),
                    const SizedBox(height: 12),
                    AuthInput(controller: _prenomCtrl, hint: 'Prénom'),
                    const SizedBox(height: 20),
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