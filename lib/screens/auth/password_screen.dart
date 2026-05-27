import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../app/main_screen.dart';
import 'auth_widgets.dart';
import 'time_screen.dart';

class PasswordScreen extends StatefulWidget {
  final String age;
  final String nom;
  final String prenom;
  final String email;

  const PasswordScreen({
    super.key,
    required this.age,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    if (_passCtrl.text.isEmpty || _confirmCtrl.text.isEmpty) return;
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(
          () => _error = 'Les mots de passe ne correspondent pas.');
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() =>
          _error = 'Le mot de passe doit avoir au moins 6 caractères.');
      return;
    }
    setState(() => _error = null);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TimeScreen(
          age: widget.age,
          nom: widget.nom,
          prenom: widget.prenom,
          email: widget.email,
          password: _passCtrl.text,
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
                progress: 0.70,
                onBack: () => Navigator.pop(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    const Text('Crée ton mot de passe',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    Text('Minimum 6 caractères',
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13)),
                    const SizedBox(height: 28),
                    AuthInput(
                      controller: _passCtrl,
                      hint: 'Mot de passe',
                      obscure: _obscure1,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure1
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscure1 = !_obscure1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AuthInput(
                      controller: _confirmCtrl,
                      hint: 'Confirmer le mot de passe',
                      obscure: _obscure2,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure2
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscure2 = !_obscure2),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _error!,
                        style: const TextStyle(
                            color: AppTheme.danger, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _loading
                        ? const CircularProgressIndicator(
                            color: AppTheme.primary)
                        : OrangeButton(
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