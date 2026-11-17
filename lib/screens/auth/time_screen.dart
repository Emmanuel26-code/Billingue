import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import 'auth_widgets.dart';
import 'congrats_screen.dart';

class TimeScreen extends StatefulWidget {
  final String age;
  final String nom;
  final String prenom;
  final String email;
  final String password;

  const TimeScreen({
    super.key,
    required this.age,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
  });

  @override
  State<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  int _selectedIndex = 1;
  bool _loading = false;

  final List<Map<String, String>> _goals = const [
    {'label': 'Moyens', 'duration': '5 min / jour'},
    {'label': 'Regulier', 'duration': '10 min / jour'},
    {'label': 'Sérieux', 'duration': '15 min / jour'},
    {'label': 'Intense', 'duration': '20 min / jour'},
  ];

  Future<void> _continue() async {
    setState(() => _loading = true);

    final result = await AuthService().register(
      email: widget.email,
      password: widget.password,
      nom: widget.nom,
      prenom: widget.prenom,
      age: widget.age,
      objectif: _goals[_selectedIndex]['label']!,
      avatar: 'assets/avatars/avatar.png',
    );

    if (mounted) {
      setState(() => _loading = false);
      if (result.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CongratsScreen(
              prenom: widget.prenom,
              goal: _goals[_selectedIndex]['label']!,
              progress: result.user!.toUserProgress(),
              uid: result.user!.uid,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
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
                progress: 0.90,
                onBack: () => Navigator.pop(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    const Text('Quel est ton objectif ?',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Column(
                          children:
                              List.generate(_goals.length, (i) {
                            final selected = _selectedIndex == i;
                            final isLast = i == _goals.length - 1;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedIndex = i),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFFFFF3E8)
                                      : Colors.white,
                                  border: !isLast
                                      ? Border(
                                          bottom: BorderSide(
                                              color: Colors
                                                  .grey.shade200))
                                      : null,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 18),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_goals[i]['label']!,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: selected
                                                ? AppTheme.primary
                                                : Colors.black87)),
                                    Text(_goals[i]['duration']!,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: selected
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                            color: selected
                                                ? AppTheme.primary
                                                : Colors.grey)),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const Spacer(),
                    _loading
                        ? const CircularProgressIndicator(
                            color: AppTheme.primary)
                        : OrangeButton(
                            label: 'CONTINUE', onTap: _continue),
                    const SizedBox(height: 24),
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