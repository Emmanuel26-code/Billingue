import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
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
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await AuthService().login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

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
        setState(() => _error = result.error);
      }
    }
  }

  Future<void> _googleLogin() async {
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
        setState(() => _error = result.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AuthTopBar(
                progress: 0.0,
                onBack: () => Navigator.pop(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    const Text('Connexion',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('Bon retour parmi nous !',
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14)),
                    const SizedBox(height: 32),
                    AuthInput(
                      controller: _emailCtrl,
                      hint: 'E-mail',
                      keyboardType: TextInputType.emailAddress,
                    ),
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
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!,
                          style: const TextStyle(
                              color: AppTheme.danger,
                              fontSize: 13)),
                    ],
                    const SizedBox(height: 20),
                    _loading
                        ? const CircularProgressIndicator(
                            color: AppTheme.primary)
                        : Column(children: [
                            OrangeButton(
                                label: 'SE CONNECTER',
                                onTap: _login),
                            const SizedBox(height: 12),
                            GoogleButton(onTap: _googleLogin),
                          ]),
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