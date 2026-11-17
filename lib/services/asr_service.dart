import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../core/secrets.dart';
import 'package:http_parser/http_parser.dart';


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
  if (!await hasPermission()) {
    debugPrint('❌ Permission micro refusée');
    return;
  }

  final dir = await getTemporaryDirectory();
  _recordingPath =
      '${dir.path}/baoule_${DateTime.now().millisecondsSinceEpoch}.wav';

  debugPrint('🎙️ Début enregistrement : $_recordingPath');

  await _recorder.start(
    const RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 16000,
      numChannels: 1,
      bitRate: 128000,
    ),
    path: _recordingPath!,
  );
  _isRecording = true;
  debugPrint('🔴 Enregistrement en cours...');
}

  Future<String?> stopAndTranscribe() async {
  if (!_isRecording) {
    debugPrint('⚠️ Pas d\'enregistrement en cours');
    return null;
  }

  debugPrint('⏹️ Arrêt enregistrement...');
  final path = await _recorder.stop();
  _isRecording = false;

  if (path == null) {
    debugPrint('❌ Chemin enregistrement null');
    return null;
  }

  debugPrint('✅ Enregistrement sauvegardé : $path');

  // Vérifie la taille du fichier
  final file = File(path);
  if (await file.exists()) {
    final size = await file.length();
    debugPrint('📦 Taille : $size bytes');
  }

  return await _transcribeWithHuggingFace(path);
}

Future<String?> _transcribeWithHuggingFace(String filePath) async {
  try {
    debugPrint('📤 Envoi à Hugging Face...');

    final file = File(filePath);
    if (!await file.exists()) return null;
    final fileSize = await file.length();
    if (fileSize < 100) return null;

    debugPrint('📦 Taille : $fileSize bytes');

    // ── Étape 1 : Upload le fichier audio ─────────────────
    final uploadRequest = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://jean2255-whisper-baoule-627cba0.hf.space/gradio_api/upload',
      ),
    );

    uploadRequest.files.add(
      await http.MultipartFile.fromPath(
        'files',
        filePath,
        contentType: MediaType('audio', 'wav'),
      ),
    );

    final uploadResponse =
        await uploadRequest.send().timeout(const Duration(seconds: 30));
    final uploadBody =
        await uploadResponse.stream.bytesToString();

    debugPrint('📥 Upload status : ${uploadResponse.statusCode}');
    debugPrint('📥 Upload body : $uploadBody');

    if (uploadResponse.statusCode != 200) {
      debugPrint('❌ Upload échoué');
      return null;
    }

    // Récupère le chemin du fichier uploadé
    final uploadData = jsonDecode(uploadBody);
    final uploadedPath = uploadData[0] as String?;

    if (uploadedPath == null) {
      debugPrint('❌ Chemin upload null');
      return null;
    }

    debugPrint('✅ Fichier uploadé : $uploadedPath');

    // ── Étape 2 : Appelle la prédiction ───────────────────
    final predictResponse = await http.post(
      Uri.parse(
        'https://jean2255-whisper-baoule-627cba0.hf.space/gradio_api/call/predict',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'data': [
          {
      'path': uploadedPath,
      'orig_name': 'baoule.wav',
      'size': fileSize,
      'mime_type': 'audio/wav',
      'is_stream': false,
      'meta': {'_type': 'gradio.FileData'}
      }
        ]
      }),
    ).timeout(const Duration(seconds: 30));

    debugPrint('📥 Predict status : ${predictResponse.statusCode}');
    debugPrint('📥 Predict body : ${predictResponse.body}');

    if (predictResponse.statusCode != 200) return null;

    final predictData = jsonDecode(predictResponse.body);
    final eventId = predictData['event_id'] as String?;

    if (eventId == null) return null;

    debugPrint('🎫 Event ID : $eventId');

    // ── Étape 3 : Récupère le résultat ────────────────────
    return await _getResult(eventId);
  } catch (e) {
    debugPrint('❌ Erreur : $e');
    return null;
  }
}

Future<String?> _getResult(String eventId) async {
  try {
    debugPrint('⏳ Récupération résultat...');

    final response = await http.get(
      Uri.parse(
        'https://jean2255-whisper-baoule-627cba0.hf.space/gradio_api/call/predict/$eventId',
      ),
      headers: {'Accept': 'text/event-stream'},
    ).timeout(const Duration(seconds: 60));

    debugPrint('📥 Résultat status : ${response.statusCode}');
    debugPrint('📥 Résultat body : ${response.body}');

    if (response.statusCode == 200) {
      for (final line in response.body.split('\n')) {
        if (line.startsWith('data: ')) {
          final jsonStr = line.substring(6).trim();
          if (jsonStr.isEmpty || jsonStr == 'null') continue;
          try {
            final parsed = jsonDecode(jsonStr);
            if (parsed is List && parsed.isNotEmpty) {
              final transcription = parsed[0] as String? ?? '';
              debugPrint('🎯 Transcription : "$transcription"');
              return transcription.toLowerCase().trim();
            }
          } catch (_) {}
        }
      }
    }
    return null;
  } catch (e) {
    debugPrint('❌ Erreur résultat : $e');
    return null;
  }
}

  Future<void> cancelRecording() async {
    await _recorder.cancel();
    _isRecording = false;
  }

  /// Réveille le Space HF avant l'enregistrement
Future<void> warmUp() async {
  try {
    debugPrint('🔥 Réveil du Space HF...');
    await http.get(
      Uri.parse(Secrets.huggingFaceUrl.replaceAll('/api/predict', '')),
    ).timeout(const Duration(seconds: 10));
    debugPrint('✅ Space réveillé');
  } catch (_) {
    debugPrint('⚠️ Space pas encore prêt');
  }
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

    for (int i = 0; i <= s.length; i++) {
      d[i][0] = i;
    }
    for (int j = 0; j <= t.length; j++) {
      d[0][j] = j;
    }

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