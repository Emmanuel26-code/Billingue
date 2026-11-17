/// Clés et URLs de services externes.
///
/// AUCUNE valeur secrète n'est écrite ici : elles sont injectées au moment
/// du build/lancement depuis `secrets.json` (ignoré par git) :
///
///   flutter run --dart-define-from-file=secrets.json
///
/// Copie `secrets.example.json` en `secrets.json` et remplis tes clés.
class Secrets {
  Secrets._();

  /// Clé API Anthropic (chat avec Aya). Vide = chat désactivé.
  static const String anthropicApiKey =
      String.fromEnvironment('ANTHROPIC_API_KEY');

  /// URL du Space Hugging Face Whisper Baoulé (reconnaissance vocale).
  static const String huggingFaceUrl = String.fromEnvironment(
    'HUGGINGFACE_URL',
    defaultValue: 'https://jean2255-whisper-baoule-627cba0.hf.space/api/predict',
  );

  static bool get hasAnthropicKey => anthropicApiKey.isNotEmpty;
}
