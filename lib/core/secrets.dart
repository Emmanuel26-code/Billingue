/// URLs de services externes, surchargeables au lancement :
///
///   flutter run --dart-define=HUGGINGFACE_URL=...
///
/// La clé Anthropic n'est PAS ici : elle reste sur le serveur
/// (Cloud Function `chatWithAya`, voir functions/).
class Secrets {
  Secrets._();

  /// URL du Space Hugging Face Whisper Baoulé (reconnaissance vocale).
  static const String huggingFaceUrl = String.fromEnvironment(
    'HUGGINGFACE_URL',
    defaultValue: 'https://jean2255-whisper-baoule-627cba0.hf.space/api/predict',
  );
}
