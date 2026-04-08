import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playReceiveMessage() async {
    try {
      await _player.play(AssetSource('iphone接收信息声.wav'));
    } catch (e) {
      print('播放接收消息音频失败: $e');
    }
  }

  Future<void> playSendMessage() async {
    try {
      await _player.play(AssetSource('iphone发送信息声.wav'));
    } catch (e) {
      print('播放发送消息音频失败: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
