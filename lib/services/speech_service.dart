import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;

  Future<bool> init() async {
    _isAvailable = await _speech.initialize(
      onError: (error) => _isListening = false,
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
    );
    return _isAvailable;
  }

  Future<String> listen() async {
    if (!_isAvailable) return '';
    String result = '';
    _isListening = true;

    await _speech.listen(
      onResult: (val) {
        result = val.recognizedWords.toLowerCase().trim();
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 2),
      localeId: 'fr_FR',
    );

    // Attend la fin de l'écoute
    await Future.delayed(const Duration(seconds: 6));
    _isListening = false;
    return result;
  }

  Future<void> stop() async {
    await _speech.stop();
    _isListening = false;
  }

  void dispose() {
    _speech.stop();
  }

  // ── Tolérance de prononciation ─────────────────────────────────────────────

  /// Vérifie si ce que l'utilisateur a dit correspond au mot attendu
  /// avec une tolérance configurable (0.0 = strict, 1.0 = tout accepter)
  bool checkPronunciation(String spoken, String expected) {
    final s = _normalize(spoken);
    final e = _normalize(expected);

    // Correspondance exacte
    if (s == e) return true;

    // Correspondance partielle — le mot attendu est contenu dans ce qui a été dit
    if (s.contains(e) || e.contains(s)) return true;

    // Distance de Levenshtein — tolérance de 40%
    final distance = _levenshtein(s, e);
    final maxLen = e.length > s.length ? e.length : s.length;
    final similarity = 1 - (distance / maxLen);

    return similarity >= 0.6; // 60% de similarité minimum
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[àáâã]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõ]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '');
  }

  /// Algorithme de distance de Levenshtein
  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<List<int>> d = List.generate(
      s.length + 1,
      (i) => List.generate(t.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s.length; i++) d[i][0] = i;
    for (int j = 0; j <= t.length; j++) d[0][j] = j;

    for (int i = 1; i <= s.length; i++) {
      for (int j = 1; j <= t.length; j++) {
        int cost = s[i - 1] == t[j - 1] ? 0 : 1;
        d[i][j] = [
          d[i - 1][j] + 1,
          d[i][j - 1] + 1,
          d[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return d[s.length][t.length];
  }
}