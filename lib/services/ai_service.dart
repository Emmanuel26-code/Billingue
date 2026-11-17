import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Chat avec Aya via la Cloud Function `chatWithAya`.
///
/// La clé Anthropic et le prompt système vivent côté serveur
/// (functions/src/index.ts) : l'app n'envoie que la conversation.
class AiService {
  // L'émulateur éventuel est branché dans main.dart (USE_EMULATORS).
  static final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  final List<Map<String, String>> _history = [];

  Future<String> sendMessage(String message) async {
    _history.add({'role': 'user', 'content': message});
    try {
      final result = await _functions
          .httpsCallable(
            'chatWithAya',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
          )
          .call<Map<String, dynamic>>({'messages': _history});
      final reply = (result.data['reply'] as String?) ?? '…';
      _history.add({'role': 'assistant', 'content': reply});
      return reply;
    } on FirebaseFunctionsException catch (e) {
      _history.removeLast(); // le message n'a pas abouti
      debugPrint('chatWithAya: ${e.code} ${e.message}');
      return e.message ?? 'Aya est momentanément indisponible.';
    } catch (e) {
      _history.removeLast();
      return 'Erreur de connexion : $e';
    }
  }
}
