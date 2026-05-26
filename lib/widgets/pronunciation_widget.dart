import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';

enum PronunciationState {
  idle,
  listening,
  success,
  failure,
  retry,
}

class PronunciationWidget extends StatefulWidget {
  final String wordToSay;
  final String translation;
  final VoidCallback onSuccess;
  final VoidCallback onSkip;

  const PronunciationWidget({
    super.key,
    required this.wordToSay,
    required this.translation,
    required this.onSuccess,
    required this.onSkip,
  });

  @override
  State<PronunciationWidget> createState() => _PronunciationWidgetState();
}

class _PronunciationWidgetState extends State<PronunciationWidget>
    with TickerProviderStateMixin {
  final SpeechService _speech = SpeechService();
  final TtsService _tts = TtsService();

  PronunciationState _state = PronunciationState.idle;
  String _spokenText = '';
  int _attempts = 0;
  static const int _maxAttempts = 3;

  // Animations
  late AnimationController _pulseCtrl;
  late AnimationController _shakeCtrl;
  late Animation<double> _pulse;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _tts.init();
    _speech.init();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _shake = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _shakeCtrl.dispose();
    _speech.dispose();
    _tts.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    setState(() {
      _state = PronunciationState.listening;
      _spokenText = '';
    });
    _pulseCtrl.repeat(reverse: true);

    final spoken = await _speech.listen();

    _pulseCtrl.stop();
    _pulseCtrl.reset();

    if (spoken.isEmpty) {
      setState(() => _state = PronunciationState.retry);
      return;
    }

    setState(() => _spokenText = spoken);

    final correct =
        _speech.checkPronunciation(spoken, widget.wordToSay);

    if (correct) {
      setState(() => _state = PronunciationState.success);
      await Future.delayed(const Duration(milliseconds: 800));
      widget.onSuccess();
    } else {
      _attempts++;
      _shakeCtrl.forward(from: 0);
      setState(() => _state = PronunciationState.failure);
    }
  }

  Future<void> _listenExample() async {
    await _tts.speakBaoule(widget.wordToSay);
  }

  void _retry() {
    setState(() {
      _state = PronunciationState.idle;
      _spokenText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruction
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎤', style: TextStyle(fontSize: 14)),
              SizedBox(width: 6),
              Text(
                'Prononce ce mot en Baoulé',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Carte du mot
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _borderColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _borderColor.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Mot à prononcer
              AnimatedBuilder(
                animation: _shake,
                builder: (_, child) {
                  final dx = _state == PronunciationState.failure
                      ? 8 *
                          (_shake.value < 0.5
                              ? -(_shake.value * 2)
                              : (_shake.value - 0.5) * 2) *
                          (1 - _shake.value)
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: child,
                  );
                },
                child: Text(
                  widget.wordToSay,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: _textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.translation,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Bouton écouter l'exemple
              GestureDetector(
                onTap: _listenExample,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_up_rounded,
                          color: AppTheme.primary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Écouter la prononciation',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Ce que l'utilisateur a dit
        if (_spokenText.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _state == PronunciationState.success
                  ? AppTheme.secondary.withOpacity(0.08)
                  : AppTheme.danger.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _state == PronunciationState.success
                    ? AppTheme.secondary
                    : AppTheme.danger,
              ),
            ),
            child: Row(
              children: [
                Text(
                  _state == PronunciationState.success ? '✅' : '❌',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _state == PronunciationState.success
                            ? 'Bonne prononciation !'
                            : 'Tu as dit : "$_spokenText"',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _state == PronunciationState.success
                              ? AppTheme.secondaryDark
                              : AppTheme.danger,
                        ),
                      ),
                      if (_state == PronunciationState.failure) ...[
                        const SizedBox(height: 3),
                        Text(
                          'On attendait : "${widget.wordToSay}"',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Tentatives restantes
        if (_state == PronunciationState.failure &&
            _attempts < _maxAttempts) ...[
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Tentative $_attempts/$_maxAttempts',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Boutons
        if (_state == PronunciationState.idle ||
            _state == PronunciationState.retry)
          _buildMicButton()
        else if (_state == PronunciationState.listening)
          _buildListeningButton()
        else if (_state == PronunciationState.failure)
          _buildFailureButtons()
        else if (_state == PronunciationState.success)
          _buildSuccessButton(),
      ],
    );
  }

  // ── Boutons ───────────────────────────────────────────────────────────────

  Widget _buildMicButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startListening,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.mic_rounded, size: 22),
                SizedBox(width: 10),
                Text(
                  'Appuie pour parler',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Passer si trop difficile
        TextButton(
          onPressed: widget.onSkip,
          child: Text(
            'Passer cette question',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListeningButton() {
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.mic_rounded, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text(
              'Écoute en cours...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailureButtons() {
    return Column(
      children: [
        if (_attempts < _maxAttempts)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _retry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.refresh_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Réessayer',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          )
        else
          // Max tentatives atteint → passer automatiquement
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.onSkip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
              ),
              child: const Text(
                'Continuer quand même →',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: widget.onSkip,
          child: Text(
            'Passer cette question',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle, color: Colors.white, size: 22),
          SizedBox(width: 8),
          Text(
            'Parfait ! Continuer →',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ── Couleurs selon état ───────────────────────────────────────────────────

  Color get _borderColor {
    switch (_state) {
      case PronunciationState.listening:
        return Colors.purple;
      case PronunciationState.success:
        return AppTheme.secondary;
      case PronunciationState.failure:
        return AppTheme.danger;
      default:
        return AppTheme.border;
    }
  }

  Color get _textColor {
    switch (_state) {
      case PronunciationState.success:
        return AppTheme.secondaryDark;
      case PronunciationState.failure:
        return AppTheme.danger;
      case PronunciationState.listening:
        return Colors.purple;
      default:
        return AppTheme.textDark;
    }
  }
}