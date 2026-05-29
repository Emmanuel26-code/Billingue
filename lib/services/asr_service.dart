import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../core/secrets.dart';

class AsrService {
  static final AsrService _instance = AsrService._internal();
  factory AsrService() => _instance;
  AsrService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;

  bool get isRecording => _isRecording;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> startRecording() async {
    if (!await hasPermission()) return;

    final dir = await getTemporaryDirectory();
    _recordingPath =
        '${dir.path}/baoule_recording_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: _recordingPath!,
    );
    _isRecording = true;
  }

  Future<String?> stopAndTranscribe() async {
    if (!_isRecording) return null;

    final path = await _recorder.stop();
    _isRecording = false;

    if (path == null) return null;

    return await _transcribeWithHuggingFace(path);
  }

  Future<String?> _transcribeWithHuggingFace(
      String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final base64Audio = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(Secrets.huggingFaceUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': [
            {
              'data': 'data:audio/wav;base64,$base64Audio',
              'name': 'recording.wav',
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transcription =
            data['data'][0] as String? ?? '';
        return transcription.toLowerCase().trim();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> cancelRecording() async {
    await _recorder.cancel();
    _isRecording = false;
  }

  void dispose() {
    _recorder.dispose();
  }

  // ── Tolérance de prononciation ─────────────────────────────────────────────

  bool checkPronunciation(String spoken, String expected) {
    final s = _normalize(spoken);
    final e = _normalize(expected);

    if (s == e) return true;
    if (s.contains(e) || e.contains(s)) return true;

    final distance = _levenshtein(s, e);
    final maxLen = e.length > s.length ? e.length : s.length;
    final similarity = 1 - (distance / maxLen);

    return similarity >= 0.6;
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