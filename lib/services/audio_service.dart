import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  // Mapping mot Baoulé → fichier audio
  static const Map<String, String> _audioMap = {
    // Salutations
    'Mo Agni oh': 'assets/sound/baoule/mo_agni_oh.wav',
    'Mo Aé oh': 'assets/sound/baoule/mo_ae_oh.wav',
    "N'dja Agni oh": 'assets/sound/baoule/ndja_agni_oh.wav',
    "N'dja arè oh": 'assets/sound/baoule/ndja_are_oh.wav',
    'Mo Anou oh': 'assets/sound/baoule/mo_anou_oh.wav',
    "N'dja Anou oh": 'assets/sound/baoule/ndja_anou_oh.wav',
    "N'dja Aossi oh": 'assets/sound/baoule/ndja_aossi_oh.wav',

    // Pronoms
    'Mi': 'assets/sound/baoule/mi.wav',
    'Ô': 'assets/sound/baoule/o.wav',
    'Wô': 'assets/sound/baoule/wo.wav',
    'É': 'assets/sound/baoule/E.wav',
    'Amou': 'assets/sound/baoule/amou.wav',
    'Bé': 'assets/sound/baoule/Be.wav',

    // Famille
    'Ni': 'assets/sound/baoule/ni.wav',
    'Siè': 'assets/sound/baoule/sie.wav',
    'Baba': 'assets/sound/baoule/baba.wav',
    "N'man": 'assets/sound/baoule/n\'man.wav',
    'Niaman bla': 'assets/sound/baoule/niaman_bla.wav',
    'Sima yassoua': 'assets/sound/baoule/sima_yassoua.wav',
    'Bla': 'assets/sound/baoule/bla.wav',
    'niaman Yassoua': 'assets/sound/baoule/niaman_yassoua.wav',
    'Mi wa': 'assets/sound/baoule/mi_wa.wav',
    'Mi yi': 'assets/sound/baoule/mi_yi.wav',


    // Chiffres 1-10
    'Konh': 'assets/sound/baoule/konh.wav',
    "N'gnonh": 'assets/sound/baoule/ngnonh.wav',
    "N'sanh": 'assets/sound/baoule/nsanh.wav',
    "N'nanh": 'assets/sound/baoule/nnanh.wav',
    "N'nouh": 'assets/sound/baoule/nnouh.wav',
    "N'sinh": 'assets/sound/baoule/nsinh.wav',
    "N'soh": 'assets/sound/baoule/nsoh.wav',
    "N'tchouèh": 'assets/sound/baoule/ntchoueh.wav',
    "N'glouhan": 'assets/sound/baoule/nglouhan.wav',
    'Blouh': 'assets/sound/baoule/blouh.wav',

    // Chiffres 11-30
    'Blouh-ni-konh': 'assets/sound/baoule/blouh_ni_konh.wav',
    "Blouh-ni-n'gnonh": 'assets/sound/baoule/blouh_ni_ngnonh.wav',
    "Blouh-ni-n'sanh": 'assets/sound/baoule/blouh_ni_nsanh.wav',
    "Blouh-ni-n'nanh": 'assets/sound/baoule/blouh_ni_nnanh.wav',
    "Blouh-ni-n'nouh": 'assets/sound/baoule/blouh_ni_nnouh.wav',
    "Blouh-ni-n'sinh": 'assets/sound/baoule/blouh_ni_nsinh.wav',
    'Blouh-ni-soh': 'assets/sound/baoule/blouh_ni_soh.wav',
    "Blouh-ni-m'tchouèh": 'assets/sound/baoule/blouh_ni_mtchoueh.wav',
    "Blouh-ni-n'glouhan": 'assets/sound/baoule/blouh_ni_nglouhan.wav',
    'Ablabah': 'assets/sound/baoule/ablabah.wav',
    'Ablabah-ni-konh': 'assets/sound/baoule/ablabah_ni_konh.wav',
    'Ablasanh': 'assets/sound/baoule/ablasanh.wav',

    // Nourriture
    'Avié': 'assets/sound/baoule/avie.wav',
    'Manda Aliê': 'assets/sound/baoule/manda_alie.wav',
    'Douho Aliê': 'assets/sound/baoule/douho_alie.wav',
    'Agba': 'assets/sound/baoule/agba.wav',
    'Manda': 'assets/sound/baoule/manda.wav',
    'Alênda': 'assets/sound/baoule/alenda.wav',
    'Ablé': 'assets/sound/baoule/able.wav',
    'Atchéké': 'assets/sound/baoule/atcheke.wav',
    'Lohmi': 'assets/sound/baoule/lohmi.wav',
    'Nin': 'assets/sound/baoule/nin.wav',
    "N'zue": 'assets/sound/baoule/nzue.wav',
    'Tro': 'assets/sound/baoule/tro.wav',
    "Man n'koun": 'assets/sound/baoule/man_nkoun.wav',
    'Kpan hum': 'assets/sound/baoule/kpan_hum.wav',
    "N'gui": 'assets/sound/baoule/ngui.wav',
    'Soukla': 'assets/sound/baoule/soukla.wav',
    "N'gateh": 'assets/sound/baoule/ngateh.wav',

    // Animaux
    'Alua': 'assets/sound/baoule/alua.wav',
    'Wouo': 'assets/sound/baoule/wouo.wav',
    'Anouman': 'assets/sound/baoule/anouman.wav',
    'Wêtrêwa': 'assets/sound/baoule/wetrewa.wav',
    'Onssien': 'assets/sound/baoule/onssien.wav',
    'Kɔkɔti': 'assets/sound/baoule/kokoti.wav',
    'Bua': 'assets/sound/baoule/bua.wav',
    'Akɔ': 'assets/sound/baoule/ako.wav',
    'Boli': 'assets/sound/baoule/boli.wav',
    'Gbéklé': 'assets/sound/baoule/gbékle.wav',
    'Wazan ni': 'assets/sound/baoule/wazan_ni.wav',
    'Ontin ontin': 'assets/sound/baoule/ontin_ontin.wav',
    'Bouké': 'assets/sound/baoule/bouke.wav',
    'Gloglo': 'assets/sound/baoule/gloglo.wav',

    // Jours
    'Kissié': 'assets/sound/baoule/kissie.wav',
    'Djôlê': 'assets/sound/baoule/djole.wav',
    'Mlan': 'assets/sound/baoule/mlan.wav',
    'Wé': 'assets/sound/baoule/we.wav',
    'Yah': 'assets/sound/baoule/yah.wav',
    'Fué': 'assets/sound/baoule/fue.wav',
    'Monnin': 'assets/sound/baoule/monnin.wav',

    // Mois
    'Angbô': 'assets/sound/baoule/angbo.wav',
    'Djouaklê': 'assets/sound/baoule/djouakle.wav',
    "N'glo": 'assets/sound/baoule/nglo.wav',
    'Kofie': 'assets/sound/baoule/kofie.wav',
    'Djessé': 'assets/sound/baoule/djesse.wav',
    "Klannan n'déya": 'assets/sound/baoule/klannan_ndeya.wav',
    'Moughou': 'assets/sound/baoule/moughou.wav',
    'Affoliè': 'assets/sound/baoule/affolie.wav',
    'Ananya': 'assets/sound/baoule/ananya.wav',
    'Félé': 'assets/sound/baoule/fele.wav',
    'Sékéwa': 'assets/sound/baoule/sekewa.wav',
    "Kongoué n'zué": 'assets/sound/baoule/kongone_nzue.wav',

    // Transport
    'Loto': 'assets/sound/baoule/loto.wav',
    'Allié': 'assets/sound/baoule/allie.wav',
    'Alapla': 'assets/sound/baoule/alapla.wav',
    'Pkangôh': 'assets/sound/baoule/pkangoh.wav',
    'Mobilti': 'assets/sound/baoule/mobilti.wav',
    'Méli': 'assets/sound/baoule/meli.wav',

    // Quotidien
    "Tan n'ni": 'assets/sound/baoule/tan_nni.wav',
    'Sika': 'assets/sound/baoule/sika.wav',
    "Kan n'ni": 'assets/sound/baoule/kan_nni.wav',
    "S'in": 'assets/sound/baoule/sin.wav',
    'Bê': 'assets/sound/baoule/be_lit.wav',

    // Corps
    'Sa': 'assets/sound/baoule/sa.wav',
    'Su': 'assets/sound/baoule/su.wav',
    'Ti': 'assets/sound/baoule/ti.wav',
    'Nouan': 'assets/sound/baoule/nouan.wav',
    'Bodrai': 'assets/sound/baoule/bodrai.wav',
  };

  /// Joue le vrai audio enregistré par la locutrice
  /// Si le fichier n'existe pas, retourne false
  Future<bool> playWord(String word) async {
    final path = _audioMap[word];
    if (path == null) return false;

    try {
      await _player.stop();
      await _player.play(AssetSource(path.replaceFirst('assets/', '')));
      _isPlaying = true;
      _player.onPlayerComplete.listen((_) => _isPlaying = false);
      return true;
    } catch (e) {
      _isPlaying = false;
      return false;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  void dispose() {
    _player.dispose();
  }

  /// Vérifie si un audio existe pour ce mot
  static bool hasAudio(String word) => _audioMap.containsKey(word);

  /// Retourne le chemin audio d'un mot
  static String? getAudioPath(String word) => _audioMap[word];
}