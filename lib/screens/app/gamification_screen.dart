import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../models/lesson_model.dart';
import '../../models/gamification_model.dart';
import '../../services/gamification_service.dart';

class GamificationScreen extends StatefulWidget {
  final UserProgress progress;
  final String uid;

  const GamificationScreen({
    super.key,
    required this.progress,
    required this.uid,
  });

  @override
  State<GamificationScreen> createState() =>
      _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late Animation<double> _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700));
    _headerAnim = CurvedAnimation(
        parent: _headerCtrl, curve: Curves.easeOut);
    _headerCtrl.forward();
    widget.progress.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.progress.removeListener(_rebuild);
    _headerCtrl.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress;
    final level = progress.level;
    final league = progress.league;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [

          // ── Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _headerAnim,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary,
                      league.color,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20, 14, 20, 24),
                    child: Column(children: [
                      // Titre
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                Navigator.pop(context),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20),
                            ),
                          ),
                          const Text('Gamification 🎮',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.w900)),
                          const SizedBox(width: 38),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Niveau + Ligue
                      Row(children: [
                        Expanded(
                          child: _InfoCard(
                            emoji: level.emoji,
                            title: level.label,
                            subtitle: 'Niveau actuel',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            emoji: league.emoji,
                            title: league.label,
                            subtitle: 'Ligue actuelle',
                            color: league.color,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 14),

                      // XP et pièces
                      Row(children: [
                        _StatPill('⚡', '${progress.xp} XP'),
                        const SizedBox(width: 8),
                        _StatPill('🪙', '${progress.coins}'),
                        const SizedBox(width: 8),
                        _StatPill('🔥', '${progress.streak} jours'),
                        const SizedBox(width: 8),
                        _StatPill('❄️', '${progress.streakFreezes}'),
                      ]),
                      const SizedBox(height: 14),

                      // Barre de niveau
                      Column(children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(level.label,
                                style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.8),
                                    fontSize: 11)),
                            Text(
                              level == UserLevel.legende
                                  ? 'MAX'
                                  : '${progress.xp} / ${level.xpForNext} XP',
                              style: TextStyle(
                                  color: Colors.white
                                      .withValues(alpha: 0.8),
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(6),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(
                                begin: 0,
                                end: progress.levelProgress),
                            duration: const Duration(
                                milliseconds: 1000),
                            builder: (_, v, __) =>
                                LinearProgressIndicator(
                              value: v,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.3),
                              valueColor:
                                  const AlwaysStoppedAnimation
                                      <Color>(Colors.white),
                              minHeight: 10,
                            ),
                          ),
                        ),
                      ]),
                    ]),
                  ),
                ),
              ),
            ),
          ),

          // ── XP du jour ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _SectionTitle('⭐ XP aujourd\'hui'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(children: [
                  const Text('⚡',
                      style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.progress.xpToday} XP gagnés',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary),
                        ),
                        Text('Objectif : 50 XP par jour',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textGrey)),
                      ],
                    ),
                  ),
                  _buildXPDayProgress(),
                ]),
              ),
            ),
          ),

          // ── Défis quotidiens ─────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _SectionTitle('🎯 Défis du jour'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final challenge =
                    widget.progress.dailyChallenges[i];
                return _ChallengeCard(
                    challenge: challenge,
                    onClaim: challenge.completed
                        ? () => _claimChallenge(challenge)
                        : null);
              },
              childCount:
                  widget.progress.dailyChallenges.length,
            ),
          ),

          // ── Quêtes hebdomadaires ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child:
                  _SectionTitle('📈 Quêtes de la semaine'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final quest =
                    widget.progress.weeklyQuests[i];
                return _QuestCard(quest: quest);
              },
              childCount:
                  widget.progress.weeklyQuests.length,
            ),
          ),

          // ── Coffres ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _SectionTitle('🎁 Coffres'),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(
                    20, 10, 20, 0),
                children: GamificationService.generateChests()
                    .map((chest) => _ChestCard(
                          chest: chest,
                          onClaim: chest.isAvailable
                              ? () => _claimChest(chest)
                              : null,
                        ))
                    .toList(),
              ),
            ),
          ),

          // ── Achats avec pièces ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _SectionTitle('🪙 Boutique'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                _ShopItem(
                  emoji: '❄️',
                  title: 'Freeze de série',
                  description:
                      'Protège ta série pour 1 jour manqué',
                  cost: 50,
                  coins: widget.progress.coins,
                  onBuy: () {
                    final success = widget.progress
                        .buyStreakFreeze();
                    if (success) {
                      _showSuccess(
                          'Freeze acheté ! ❄️');
                    } else {
                      _showError(
                          'Pas assez de pièces 🪙');
                    }
                  },
                ),
                const SizedBox(height: 10),
                _ShopItem(
                  emoji: '🔧',
                  title: 'Réparer la série',
                  description:
                      'Restaure ta série après un jour manqué',
                  cost: 100,
                  coins: widget.progress.coins,
                  onBuy: () {
                    final success =
                        widget.progress.repairStreak();
                    if (success) {
                      _showSuccess('Série réparée ! 🔥');
                    } else {
                      _showError(
                          'Pas assez de pièces 🪙');
                    }
                  },
                ),
              ]),
            ),
          ),

          const SliverToBoxAdapter(
              child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildXPDayProgress() {
    final pct =
        (widget.progress.xpToday / 50).clamp(0.0, 1.0);
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: pct,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primary),
            strokeWidth: 5,
          ),
          Center(
            child: Text(
              '${(pct * 100).round()}%',
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  void _claimChallenge(DailyChallenge challenge) {
    HapticFeedback.mediumImpact();
    widget.progress.addXP(challenge.xpReward);
    widget.progress.coins += widget.progress.coins +
        challenge.coinsReward;
    _showSuccess(
        '+${challenge.xpReward} XP et +${challenge.coinsReward} 🪙 !');
  }

  void _claimChest(RewardChest chest) {
    HapticFeedback.heavyImpact();
    chest.claimed = true;
    widget.progress.addXP(chest.xpReward);
    widget.progress.coins =
        widget.progress.coins + chest.coinsReward;
    _showSuccess(
        '${chest.title} ouvert ! +${chest.xpReward} XP 🎉');
    setState(() {});
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: AppTheme.secondary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppTheme.danger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800));
  }
}

class _StatPill extends StatelessWidget {
  final String icon;
  final String label;
  const _StatPill(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11)),
        ]),
      ]),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final DailyChallenge challenge;
  final VoidCallback? onClaim;

  const _ChallengeCard({required this.challenge, this.onClaim});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: challenge.completed
              ? AppTheme.secondary
              : AppTheme.border,
          width: challenge.completed ? 2 : 1,
        ),
      ),
      child: Column(children: [
        Row(children: [
          Text(challenge.emoji,
              style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(challenge.title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              Text(challenge.description,
                  style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textGrey)),
              const SizedBox(height: 2),
              Text(
                '+${challenge.xpReward} XP · +${challenge.coinsReward} 🪙',
                style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700),
              ),
            ]),
          ),
          if (challenge.completed && onClaim != null)
            GestureDetector(
              onTap: onClaim,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Réclamer',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            )
          else if (challenge.completed)
            const Icon(Icons.check_circle,
                color: AppTheme.secondary, size: 24),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: challenge.progress),
            duration: const Duration(milliseconds: 600),
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                challenge.completed
                    ? AppTheme.secondary
                    : AppTheme.primary,
              ),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${challenge.current}/${challenge.target}',
            style: TextStyle(
                fontSize: 10, color: AppTheme.textGrey),
          ),
        ),
      ]),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final WeeklyQuest quest;
  const _QuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: quest.completed
              ? const Color(0xFFB8860B)
              : AppTheme.border,
          width: quest.completed ? 2 : 1,
        ),
      ),
      child: Column(children: [
        Row(children: [
          Text(quest.emoji,
              style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(quest.title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              Text(quest.description,
                  style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textGrey)),
              const SizedBox(height: 2),
              Text(
                '+${quest.xpReward} XP · +${quest.coinsReward} 🪙',
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB8860B),
                    fontWeight: FontWeight.w700),
              ),
            ]),
          ),
          if (quest.completed)
            const Icon(Icons.check_circle,
                color: Color(0xFFB8860B), size: 24),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: quest.progress),
            duration: const Duration(milliseconds: 600),
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                quest.completed
                    ? const Color(0xFFB8860B)
                    : AppTheme.primary,
              ),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${quest.current}/${quest.target}',
            style: TextStyle(
                fontSize: 10, color: AppTheme.textGrey),
          ),
        ),
      ]),
    );
  }
}

class _ChestCard extends StatelessWidget {
  final RewardChest chest;
  final VoidCallback? onClaim;

  const _ChestCard({required this.chest, this.onClaim});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClaim,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: chest.isAvailable
              ? AppTheme.primary.withValues(alpha: 0.08)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: chest.isAvailable
                ? AppTheme.primary
                : Colors.grey.shade200,
            width: chest.isAvailable ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(chest.emoji,
                style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 6),
            Text(chest.title,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: chest.isAvailable
                        ? AppTheme.textDark
                        : Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              chest.claimed
                  ? 'Réclamé ✓'
                  : chest.isAvailable
                      ? 'Ouvrir !'
                      : 'Pas encore',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: chest.claimed
                      ? Colors.grey
                      : chest.isAvailable
                          ? AppTheme.primary
                          : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final int cost;
  final int coins;
  final VoidCallback onBuy;

  const _ShopItem({
    required this.emoji,
    required this.title,
    required this.description,
    required this.cost,
    required this.coins,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = coins >= cost;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700)),
            Text(description,
                style: TextStyle(
                    fontSize: 11, color: AppTheme.textGrey)),
          ]),
        ),
        GestureDetector(
          onTap: canAfford ? onBuy : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: canAfford
                  ? const Color(0xFFB8860B)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$cost 🪙',
              style: TextStyle(
                  color:
                      canAfford ? Colors.white : Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ]),
    );
  }
}