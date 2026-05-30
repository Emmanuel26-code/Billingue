import 'package:BillingueApp/services/tts_service.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/asr_service.dart';
import '../services/audio_service.dart';

enum PronunciationState {
  idle,
  listening,
  processing,
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
  State<PronunciationWidget> createState() =>
      _PronunciationWidgetState();
}

class _PronunciationWidgetState extends State<PronunciationWidget>
    with TickerProviderStateMixin {
  final AsrService _asr = AsrService();
  final TtsService _tts = TtsService();

  PronunciationState _state = PronunciationState.idle;
  String _spokenText = '';
  int _attempts = 0;
  static const int _maxAttempts = 3;

  late AnimationController _pulseCtrl;
  late AnimationController _shakeCtrl;
  late Animation<double> _pulse;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _shake = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _shakeCtrl, curve: Curves.elasticIn),
    );
    AsrService().warmUp();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    final hasPermission = await _asr.hasPermission();
    if (!hasPermission) {
      setState(() {
        _state = PronunciationState.retry;
        _spokenText = 'Permission microphone refusée';
      });
      return;
    }

    setState(() {
      _state = PronunciationState.listening;
      _spokenText = '';
    });
    _pulseCtrl.repeat(reverse: true);

    await _asr.startRecording();

    // Enregistre pendant 3 secondes
    await Future.delayed(const Duration(seconds: 3));

    setState(() => _state = PronunciationState.processing);
    _pulseCtrl.stop();
    _pulseCtrl.reset();

    // Envoie au modèle Hugging Face
    final spoken = await _asr.stopAndTranscribe();

    if (spoken == null || spoken.isEmpty) {
      setState(() {
        _state = PronunciationState.retry;
        _spokenText = 'Rien entendu, réessaie...';
      });
      return;
    }

    setState(() => _spokenText = spoken);

    final correct =
        _asr.checkPronunciation(spoken, widget.wordToSay);

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
    if (AudioService.hasAudio(widget.wordToSay)) {
      await AudioService().playWord(widget.wordToSay);
    } else {
      await _tts.speakBaoule(widget.wordToSay);
    }
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
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 7),
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
        const SizedBox(height: 20),

        // Carte du mot
        AnimatedBuilder(
          animation: _shake,
          builder: (_, child) {
            final dx =
                _state == PronunciationState.failure
                    ? 8 *
                        (_shake.value < 0.5
                            ? -(_shake.value * 2)
                            : (_shake.value - 0.5) * 2) *
                        (1 - _shake.value)
                    : 0.0;
            return Transform.translate(
                offset: Offset(dx, 0), child: child);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: _borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: _borderColor.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(children: [
              Text(
                widget.wordToSay,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: _textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(widget.translation,
                  style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textGrey)),
              const SizedBox(height: 16),

              // Bouton écouter le vrai audio
              GestureDetector(
                onTap: _listenExample,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.primary
                            .withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_up_rounded,
                          color: AppTheme.primary,
                          size: 16),
                      const SizedBox(width: 6),
                      Text(
                        AudioService.hasAudio(
                                widget.wordToSay)
                            ? 'Écouter (audio réel 🎙️)'
                            : 'Écouter (synthèse)',
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
            ]),
          ),
        ),
        const SizedBox(height: 16),

        // Résultat de la reconnaissance
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
            child: Row(children: [
              Text(
                _state == PronunciationState.success
                    ? '✅'
                    : '❌',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _state == PronunciationState.success
                          ? 'Bonne prononciation ! 🎉'
                          : 'Tu as dit : "$_spokenText"',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _state ==
                                PronunciationState.success
                            ? AppTheme.secondaryDark
                            : AppTheme.danger,
                      ),
                    ),
                    if (_state ==
                        PronunciationState.failure) ...[
                      const SizedBox(height: 3),
                      Text(
                        'On attendait : "${widget.wordToSay}"',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGrey),
                      ),
                    ],
                  ],
                ),
              ),
            ]),
          ),

        // Tentatives
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

        // Boutons selon état
        _buildButtons(),
      ],
    );
  }

  Widget _buildButtons() {
    switch (_state) {
      case PronunciationState.idle:
      case PronunciationState.retry:
        return _buildMicButton();
      case PronunciationState.listening:
        return _buildListeningButton();
      case PronunciationState.processing:
        return _buildProcessingButton();
      case PronunciationState.failure:
        return _buildFailureButtons();
      case PronunciationState.success:
        return _buildSuccessButton();
    }
  }

  Widget _buildMicButton() {
    return Column(children: [
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
              Text('Appuie et prononce',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 10),
      TextButton(
        onPressed: widget.onSkip,
        child: Text('Passer cette question',
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13)),
      ),
    ]);
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
            Icon(Icons.mic_rounded,
                color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text('Écoute (3 sec)...',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.orange.shade400,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Analyse en cours...',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildFailureButtons() {
    return Column(children: [
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
                Text('Réessayer',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        )
      else
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
            child: const Text('Continuer quand même →',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
          ),
        ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: widget.onSkip,
        child: Text('Passer',
            style: TextStyle(
                color: Colors.grey.shade500, fontSize: 13)),
      ),
    ]);
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
          Icon(Icons.check_circle,
              color: Colors.white, size: 22),
          SizedBox(width: 8),
          Text('Parfait ! Continuer →',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Color get _borderColor {
    switch (_state) {
      case PronunciationState.listening:
        return Colors.red;
      case PronunciationState.processing:
        return Colors.orange;
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
        return Colors.red;
      case PronunciationState.processing:
        return Colors.orange;
      default:
        return AppTheme.textDark;
    }
  }
}