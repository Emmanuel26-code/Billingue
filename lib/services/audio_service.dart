import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal() {
    _configureAudio();
  }

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSub;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  /// Mapping exact : mot Baoulé → chemin fichier audio
  static const Map<String, String> _audioMap = {
    // Salutations
    'Mo Agni oh':     'sound/baoule/mo_agni_oh.mp4',
    'Mo Aré oh':       'sound/baoule/mo_are_oh.mp4',
    "N'dja Agni oh":  'sound/baoule/N\'dja_agni_oh.mp4',
    "N'dja Aré oh":   'sound/baoule/N\'dja_are_oh.mp4',
    'Mo Anou oh':     'sound/baoule/mo_anou_oh.mp4',
    "N'dja Anou oh":  'sound/baoule/N\'dja_Anou_oh.mp4',
    "N'dja Aossi oh": 'sound/baoule/N\'dja_aossi_oh.mp4',

    // Pronoms
    'Mi':    'sound/baoule/mi.mp4',
    'Ô':     'sound/baoule/o.mp4',
    'Wô':    'sound/baoule/wo.mp4',
    'É':     'sound/baoule/e.mp4',
    'Amou':  'sound/baoule/amou.mp4',
    'Bé':    'sound/baoule/be.mp4',

    // Famille
    'Ni':           'sound/baoule/ni.mp4',
    'Siè':          'sound/baoule/sie.mp4',
    'Baba':         'sound/baoule/baba.mp4',
    "N'man":        'sound/baoule/nman.mp4',
    'Niaman bla':   'sound/baoule/niaman_bla.mp4',
    'Sima yassoua': 'sound/baoule/sima_yassoua.mp4',
    'Bla':          'sound/baoule/bla.mp4',
    'Yassoua':      'sound/baoule/yassoua.mp4',
    'Mi wa':        'sound/baoule/mi_wa.mp4',
    'Mi yi':        'sound/baoule/mi_yi.mp4',
    'Mi wou':       'sound/baoule/mi_wou.mp4',

    // Chiffres 1-10
    'Konh':        'sound/baoule/konh.mp4',
    "N'gnonh":     'sound/baoule/ngnonh.mp4',
    "N'sanh":      'sound/baoule/nsanh.mp4',
    "N'nanh":      'sound/baoule/nnanh.mp4',
    "N'nouh":      'sound/baoule/nnouh.mp4',
    "N'sinh":      'sound/baoule/nsinh.mp4',
    "N'soh":       'sound/baoule/nsoh.mp4',
    "N'tchouèh":   'sound/baoule/ntchoueh.mp4',
    "N'glouhan":   'sound/baoule/nglouhan.mp4',
    'Blouh':       'sound/baoule/blouh.mp4',

    // Chiffres 11-30
    'Blouh-ni-konh':       'sound/baoule/blouh_ni_konh.mp4',
    "Blouh-ni-n'gnonh":    'sound/baoule/blouh_ni_ngnonh.mp4',
    "Blouh-ni-n'sanh":     'sound/baoule/blouh_ni_nsanh.mp4',
    "Blouh-ni-n'nanh":     'sound/baoule/blouh_ni_nnanh.mp4',
    "Blouh-ni-n'nouh":     'sound/baoule/blouh_ni_nnouh.mp4',
    "Blouh-ni-n'sinh":     'sound/baoule/blouh_ni_nsinh.mp4',
    'Blouh-ni-soh':        'sound/baoule/blouh_ni_soh.mp4',
    "Blouh-ni-m'tchouèh":  'sound/baoule/blouh_ni_mtchoueh.mp4',
    "Blouh-ni-n'glouhan":  'sound/baoule/blouh_ni_nglouhan.mp4',
    'Ablabah':             'sound/baoule/ablabah.mp4',
    'Ablabah-ni-konh':     'sound/baoule/ablabah_ni_konh.mp4',
    'Ablasanh':            'sound/baoule/ablasanh.mp4',

    // Nourriture
    'Avié':       'sound/baoule/avie.mp4',
    'Manda Aliê': 'sound/baoule/manda_alie.mp4',
    'Douho Aliê': 'sound/baoule/douho_alie.mp4',
    'Agba':       'sound/baoule/agba.mp4',
    'Manda':      'sound/baoule/manda.mp4',
    'Alênda':     'sound/baoule/alenda.mp4',
    'Ablé':       'sound/baoule/able.mp4',
    'Atchéké':    'sound/baoule/atcheke.mp4',
    'Lohmi':      'sound/baoule/lohmi.mp4',
    'Nin':        'sound/baoule/nin.mp4',
    "N'zue":      'sound/baoule/nzue.mp4',
    'Tro':        'sound/baoule/tro.mp4',
    "Man n'koun": 'sound/baoule/man_nkoun.mp4',
    'Kpan hum':   'sound/baoule/kpan_hum.mp4',
    "N'gui":      'sound/baoule/ngui.mp4',
    'Soukla':     'sound/baoule/soukla.mp4',
    "N'gateh":    'sound/baoule/ngateh.mp4',

    // Animaux
    'Alua':        'sound/baoule/alua.mp4',
    'Wouo':        'sound/baoule/wouo.mp4',
    'Anouman':     'sound/baoule/anouman.mp4',
    'Wêtrêwa':     'sound/baoule/wetrewa.mp4',
    'Onssien':     'sound/baoule/onssien.mp4',
    'Kɔkɔti':      'sound/baoule/kokoti.mp4',
    'Bua':         'sound/baoule/bua.mp4',
    'Akɔ':         'sound/baoule/ako.mp4',
    'Boli':        'sound/baoule/boli.mp4',
    'Gbéklé':      'sound/baoule/gbékle.mp4',
    'Wazan ni':    'sound/baoule/wazan_ni.mp4',
    'Ontin ontin': 'sound/baoule/ontin_ontin.mp4',
    'Bouké':       'sound/baoule/bouke.mp4',
    'Gloglo':      'sound/baoule/gloglo.mp4',

    // Jours
    'Kissié': 'sound/baoule/kissie.mp4',
    'Djôlê':  'sound/baoule/djole.mp4',
    'Mlan':   'sound/baoule/mlan.mp4',
    'Wé':     'sound/baoule/we.mp4',
    'Yah':    'sound/baoule/yah.mp4',
    'Fué':    'sound/baoule/fue.mp4',
    'Monnin': 'sound/baoule/monnin.mp4',

    // Mois
    'Angbô':           'sound/baoule/angbo.mp4',
    'Djouaklê':        'sound/baoule/djouakle.mp4',
    "N'glo":           'sound/baoule/nglo.mp4',
    'Kofie':           'sound/baoule/kofie.mp4',
    'Djessé':          'sound/baoule/djesse.mp4',
    "Klannan n'déya":  'sound/baoule/klannan_ndeya.mp4',
    'Moughou':         'sound/baoule/moughou.mp4',
    'Affoliè':         'sound/baoule/affolie.mp4',
    'Ananya':          'sound/baoule/ananya.mp4',
    'Félé':            'sound/baoule/fele.mp4',
    'Sékéwa':          'sound/baoule/sekewa.mp4',
    "Kongoué n'zué":   'sound/baoule/kongone_nzue.mp4',

    // Transport
    'Loto':    'sound/baoule/loto.mp4',
    'Allié':   'sound/baoule/allie.mp4',
    'Alapla':  'sound/baoule/alapla.mp4',
    'Pkangôh': 'sound/baoule/pkangoh.mp4',
    'Mobilti': 'sound/baoule/mobilti.mp4',
    'Méli':    'sound/baoule/meli.mp4',

    // Quotidien
    "Tan n'ni": 'sound/baoule/tan_nni.mp4',
    'Sika':     'sound/baoule/sika.mp4',
    "Kan n'ni": 'sound/baoule/kan_nni.mp4',
    "S'in":     'sound/baoule/sin.mp4',
    'Bê':       'sound/baoule/be_lit.mp4',

    // Corps
    'Sa':     'sound/baoule/sa.mp4',
    'Su':     'sound/baoule/su.mp4',
    'Ti':     'sound/baoule/ti.mp4',
    'Nouan':  'sound/baoule/nouan.mp4',
    'Bodrai': 'sound/baoule/bodrai.mp4',
  };

  void _configureAudio() {
    _playerStateSub = _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
    });
  }

  Future<bool> playWord(String word) async {
    final path = _audioMap[word];
    if (path == null) {
      debugPrint('❌ Pas de mapping pour : $word');
      return false;
    }

    try {
      await _player.stop();
      _isPlaying = true;
      debugPrint('▶️ Lecture audio : $path');

      if (!kIsWeb) {
        await _player.setAudioContext(
          AudioContext(
            android: AudioContextAndroid(
              audioFocus: AndroidAudioFocus.gain,
              usageType: AndroidUsageType.media,
              contentType: AndroidContentType.music,
            ),
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.playback,
            ),
          ),
        );
      }

      if (kIsWeb) {
        await _player.play(UrlSource('assets/$path'));
      } else {
        await _player.play(AssetSource(path));
      }

      return true;
    } catch (e) {
      _isPlaying = false;
      debugPrint('❌ Erreur audio : $e');
      return false;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  void dispose() {
    _playerStateSub?.cancel();
    _player.stop();
  }

  static bool hasAudio(String word) =>
      _audioMap.containsKey(word);

  static String? getAudioPath(String word) =>
      _audioMap[word];
}