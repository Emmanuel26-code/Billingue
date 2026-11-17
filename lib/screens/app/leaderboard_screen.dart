import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../models/lesson_model.dart';

class LeaderboardScreen extends StatefulWidget {
  final UserProgress progress;
  final String uid;

  const LeaderboardScreen({
    super.key,
    required this.progress,
    required this.uid,
  });

  @override
  State<LeaderboardScreen> createState() =>
      _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600));
    _fade =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.primary,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20, 14, 20, 28),
                    child: Column(
                      children: [
                        const Text('🏆 Classement',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            )),
                        const SizedBox(height: 6),
                        Text('Top apprenants Baoulé 🇨🇮',
                            style: TextStyle(
                              color:
                                  Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                            )),
                        const SizedBox(height: 20),
                        // Ton rang
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                ClipOval(
                                  child: Image.asset(
                                    widget.progress.avatar,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  widget.progress.nom,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ]),
                              Text(
                                '${widget.progress.xp} XP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Liste classement
            SliverToBoxAdapter(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('xp', descending: true)
                    .limit(50)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primary),
                      ),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text('Aucun apprenant trouvé'),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: List.generate(docs.length, (i) {
                        final data = docs[i].data()
                            as Map<String, dynamic>;
                        final isMe =
                            docs[i].id == widget.uid;
                        final rank = i + 1;
                        final nom =
                            '${data['prenom'] ?? ''} ${data['nom'] ?? ''}'
                                .trim();
                        final xp = data['xp'] ?? 0;
                        final avatar = data['avatar'] ??
                            'assets/avatars/avatar.png';
                        final streak = data['streak'] ?? 0;

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(
                              milliseconds: 300 + i * 60),
                          curve: Curves.easeOut,
                          builder: (_, v, child) => Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - v)),
                              child: child,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(
                                bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? AppTheme.primary
                                      .withValues(alpha: 0.08)
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(16),
                              border: Border.all(
                                color: isMe
                                    ? AppTheme.primary
                                    : AppTheme.border,
                                width: isMe ? 2 : 1,
                              ),
                            ),
                            child: Row(children: [
                              // Rang
                              SizedBox(
                                width: 36,
                                child: Text(
                                  _rankEmoji(rank),
                                  style: TextStyle(
                                    fontSize: rank <= 3
                                        ? 24
                                        : 16,
                                    fontWeight:
                                        FontWeight.w800,
                                    color: rank <= 3
                                        ? null
                                        : AppTheme.textGrey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Avatar
                              ClipOval(
                                child: Image.asset(
                                  avatar,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(
                                    width: 44,
                                    height: 44,
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.1),
                                    child: const Icon(
                                        Icons.person,
                                        color: AppTheme.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Infos
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Text(
                                        nom.isEmpty
                                            ? 'Apprenant'
                                            : nom,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight.w700,
                                          color: isMe
                                              ? AppTheme.primary
                                              : AppTheme.textDark,
                                        ),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 6,
                                              vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                          ),
                                          child: const Text('Toi',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight
                                                          .w800)),
                                        ),
                                      ],
                                    ]),
                                    const SizedBox(height: 3),
                                    Text(
                                      '🔥 $streak jours de série',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textGrey),
                                    ),
                                  ],
                                ),
                              ),

                              // XP
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$xp XP',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: isMe
                                          ? AppTheme.primary
                                          : AppTheme.textDark,
                                    ),
                                  ),
                                  Text('⚡',
                                      style: const TextStyle(
                                          fontSize: 12)),
                                ],
                              ),
                            ]),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _rankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }
}