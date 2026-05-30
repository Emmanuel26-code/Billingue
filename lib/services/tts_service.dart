import 'package:flutter_tts/flutter_tts.dart';
import 'audio_service.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  final AudioService _audio = AudioService();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> init() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.4);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() => _isPlaying = false);
    _tts.setErrorHandler((_) => _isPlaying = false);
  }

  /// Joue le vrai audio si disponible
  /// Sinon repli sur TTS synthétique
  Future<void> speakBaoule(String word) async {
    if (_isPlaying) await stop();
    _isPlaying = true;

    final played = await _audio.playWord(word);
    if (!played) {
      await _tts.speak(word);
    }

    _isPlaying = false;
  }

  Future<void> stop() async {
    await _tts.stop();
    await _audio.stop();
    _isPlaying = false;
  }

  void dispose() {
    _tts.stop();
    _audio.stop();
  }
}