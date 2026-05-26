import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> init() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1);

    _tts.setStartHandler(() => _isPlaying = true);
    _tts.setCompletionHandler(() => _isPlaying = false);
    _tts.setErrorHandler((_) => _isPlaying = false);
  }

  Future<void> speak(String text) async {
    if (_isPlaying) await stop();
    await _tts.speak(text);
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _tts.stop();
    _isPlaying = false;
  }

  Future<void> speakBaoule(String word) async {
    // Vitesse plus lente pour les mots Baoulé
    await _tts.setSpeechRate(0.35);
    await speak(word);
    await _tts.setSpeechRate(0.45);
  }

  void dispose() {
    _tts.stop();
  }
}