import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/lesson_model.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'leaderboard_screen.dart';

class MainScreen extends StatefulWidget {
  final UserProgress progress;
  final String uid;

  const MainScreen({
    super.key,
    required this.progress,
    required this.uid,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Écoute les changements de progression pour rebuild auto
    widget.progress.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    widget.progress.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _onProgressChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        progress: widget.progress,
        uid: widget.uid,
      ),
      const ChatScreen(),
      LeaderboardScreen(
        progress: widget.progress,
        uid: widget.uid,
      ),
      ProfileScreen(
        progress: widget.progress,
        uid: widget.uid,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: '🏠',
                label: 'Accueil',
                index: 0,
                current: _index,
                onTap: (i) => setState(() => _index = i),
              ),
              _NavItem(
                icon: '🤖',
                label: 'Aya',
                index: 1,
                current: _index,
                onTap: (i) => setState(() => _index = i),
              ),
              _NavItem(
                icon: '🏆',
                label: 'Classement',
                index: 2,
                current: _index,
                onTap: (i) => setState(() => _index = i),
              ),
              _NavItem(
                icon: '👤',
                label: 'Profil',
                index: 3,
                current: _index,
                onTap: (i) => setState(() => _index = i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon,
                style: TextStyle(fontSize: active ? 24 : 22)),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: active
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color:
                        active ? AppTheme.primary : Colors.grey)),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? 18 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}