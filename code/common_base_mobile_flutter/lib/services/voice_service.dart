import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../config/app_config.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final Dio _dio = Dio();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<String> recognizeSpeech(String audioPathOrUrl) async {
    final result = await recognizeSpeechWithUrl(audioPathOrUrl);
    return result['text'] ?? '';
  }

  Future<Map<String, String?>> recognizeSpeechWithUrl(
    String audioPathOrUrl,
  ) async {
    try {
      MultipartFile audioFile;

      if (kIsWeb) {
        final response = await Dio().get(
          audioPathOrUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        final bytes = Uint8List.fromList(response.data);
        audioFile = MultipartFile.fromBytes(bytes, filename: 'audio.m4a');
      } else {
        final file = File(audioPathOrUrl);
        if (!await file.exists()) {
          throw Exception('音频文件不存在');
        }
        final fileName = audioPathOrUrl.split(Platform.pathSeparator).last;
        audioFile = await MultipartFile.fromFile(
          audioPathOrUrl,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap({'file': audioFile});

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/ai/voice/transcribe-with-url',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data.containsKey('text')) {
          return {
            'text': data['text'] as String?,
            'audioUrl': data['audioUrl'] as String?,
          };
        }
        throw Exception('响应格式错误');
      }
      throw Exception('语音识别失败: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('语音识别失败: $e');
    }
  }

  Future<void> synthesizeSpeech(String text) async {
    if (text.isEmpty) return;

    try {
      _isPlaying = true;

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/ai/voice/synthesize-with-url',
        data: {'text': text},
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        String? audioUrl;
        if (data is Map) {
          if (data.containsKey('data') && data['data'] is Map) {
            audioUrl = data['data']['audioUrl'];
          } else {
            audioUrl = data['audioUrl'];
          }
        }

        if (audioUrl != null && audioUrl.isNotEmpty) {
          if (kIsWeb) {
            await _audioPlayer.play(UrlSource(audioUrl));
          } else {
            final tempDir = await getTemporaryDirectory();
            final audioFile = File('${tempDir.path}/tts_output.mp3');
            await _dio.download(audioUrl, audioFile.path);
            await _audioPlayer.play(DeviceFileSource(audioFile.path));
          }
        } else {
          throw Exception('语音合成返回空URL');
        }
      } else {
        throw Exception('语音合成失败: ${response.statusCode}');
      }

      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } on DioException catch (e) {
      _isPlaying = false;
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      _isPlaying = false;
      throw Exception('语音合成失败: $e');
    }
  }

  Future<void> stopPlaying() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
