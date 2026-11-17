import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../core/secrets.dart';

class AiService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-sonnet-4-5';

  static const String _systemPrompt = '''
Tu es Aya, une assistante spécialisée dans la langue Baoulé de Côte d'Ivoire 🇨🇮.
Tu aides les utilisateurs à apprendre le Baoulé à travers l'application Billingue.

Tes règles :
- Tu réponds TOUJOURS en français, mais tu inclus les mots/phrases en Baoulé quand c'est pertinent
- Tu donnes des exemples concrets avec la prononciation quand possible
- Tu es encourageante, chaleureuse et pédagogique
- Si on te demande une traduction, tu donnes le mot en Baoulé + un exemple d'usage
- Tu expliques aussi la culture Akan et ivoirienne quand c'est lié
- Tu ne réponds qu'aux sujets liés au Baoulé, à la Côte d'Ivoire et à l'apprentissage des langues
- Si on te pose une question hors sujet, tu ramènes gentiment la conversation au Baoulé
- Tu te présentes comme Aya au premier message

Vocabulaire de base que tu maîtrises :
- Akwaba = Bienvenue/Bonjour
- N'dɛ = Comment vas-tu ?
- Mi si = Je vais bien
- Mɛ = Merci
- Yako = Courage/Condoléances
- Ngon = 1, Abien = 2, Abla = 3, Anon = 4, Nyo = 5, Nsia = 6, Ason = 7, Asien = 8, Akron = 9, Bla = 10
- Ni = Mère, Ba = Père, Wa = Enfant, Kaka = Grand-mère
- Fiɛ = Rouge, Fitɛ = Blanc, Tete = Noir, Blɔ = Vert, Sran = Jaune
- Nzue = Eau, Mlo = Igname, Mi di = Je mange, Mi nuan = Je bois, Kpɔ = Poisson
''';

  final List<Map<String, String>> _history = [];

  Future<String> sendMessage(String message) async {
    if (!Secrets.hasAnthropicKey) {
      return 'Aya n\'est pas configurée : lance l\'app avec '
          '--dart-define-from-file=secrets.json (voir README).';
    }
    try {
      _history.add({'role': 'user', 'content': message});

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': Secrets.anthropicApiKey,
          'anthropic-version': '2023-06-01',
          // Requis par l'API pour un appel depuis le navigateur (version web).
          if (kIsWeb) 'anthropic-dangerous-direct-browser-access': 'true',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 800,
          'system': _systemPrompt,
          'messages': _history,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['content'][0]['text'] as String;
        _history.add({'role': 'assistant', 'content': reply});
        return reply;
      } else {
        final error = jsonDecode(response.body);
        return 'ERREUR : ${error['error']['message']}';
      }
    } catch (e) {
      return 'Erreur de connexion : ${e.toString()}';
    }
  }
}