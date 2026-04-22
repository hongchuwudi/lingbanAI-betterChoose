import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../services/voice_service.dart';
import '../services/chat_service.dart';
import '../models/chat_message.dart';
import '../widgets/notification/notification_helper.dart';

class VoiceCallScreen extends StatefulWidget {
  final String? sessionId;
  final List<ChatMessage>? existingMessages;

  const VoiceCallScreen({super.key, this.sessionId, this.existingMessages});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen>
    with TickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final VoiceService _voiceService = VoiceService();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isAiSpeaking = false;
  double _recordingSeconds = 0;
  Timer? _recordingTimer;

  // Always-running controllers
  late AnimationController _ringController; // expanding rings
  late AnimationController _idleController; // gentle idle glow
  // Start/stop controller
  late AnimationController _waveController; // sound wave bars

  late Animation<double> _idleAnimation;

  static const Color _accentPurple = Color(0xFF7C6FF7);
  static const Color _accentDeep = Color(0xFF5A4FCF);
  static const Color _bgTop = Color(0xFF0C0A1F);
  static const Color _bgMid = Color(0xFF141030);
  static const Color _bgBot = Color(0xFF0A1428);

  @override
  void initState() {
    super.initState();
    _messages = widget.existingMessages ?? [];

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _idleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    _waveController.dispose();
    _idleController.dispose();
    _audioRecorder.dispose();
    _recordingTimer?.cancel();
    _scrollController.dispose();
    _voiceService.stopPlaying();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<bool> _checkPermission() async {
    if (kIsWeb) return true;
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final status = await Permission.microphone.status;
        if (status.isGranted) return true;
        final result = await Permission.microphone.request();
        return result.isGranted;
      } catch (e) {
        return true;
      }
    }
    return true;
  }

  Future<void> _startRecording() async {
    if (_isProcessing || _isAiSpeaking) return;

    if (!kIsWeb) {
      final hasPermission = await _checkPermission();
      if (!hasPermission) {
        _showMessage('请授予麦克风权限', isError: true);
        return;
      }
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      if (kIsWeb) {
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: 'audio_$timestamp.m4a',
        );
      } else {
        final directory = await getTemporaryDirectory();
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: '${directory.path}/voice_$timestamp.m4a',
        );
      }

      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      _waveController.repeat();

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingSeconds++;
          });
          if (_recordingSeconds >= 60) {
            _stopRecording();
          }
        }
      });
    } catch (e) {
      debugPrint('录音启动失败: $e');
      if (e.toString().contains('Permission') ||
          e.toString().contains('NotAllowedError') ||
          e.toString().contains('permission')) {
        _showMessage('请允许麦克风权限', isError: true);
      } else {
        _showMessage('录音启动失败', isError: true);
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    _recordingTimer?.cancel();
    _waveController.stop();
    _waveController.reset();

    if (_recordingSeconds < 1) {
      setState(() {
        _isRecording = false;
        _recordingSeconds = 0;
      });
      _showMessage('录音时间太短，请长按说话', isError: true);
      try {
        await _audioRecorder.stop();
      } catch (_) {}
      return;
    }

    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      if (path != null && path.isNotEmpty) {
        final userMessage = ChatMessage(content: '正在识别...', isUser: true);
        setState(() {
          _messages.add(userMessage);
        });
        _scrollToBottom();

        try {
          final result = await _voiceService.recognizeSpeechWithUrl(path);
          final text = result['text'] ?? '';
          final audioUrl = result['audioUrl'];

          setState(() {
            _messages[_messages.length - 1] = ChatMessage(
              content: text.isEmpty ? '（未识别到内容）' : text,
              isUser: true,
              audioUrl: audioUrl,
            );
          });

          if (text.isNotEmpty) {
            await _sendMessageToAi(text, audioUrl: audioUrl);
          }
        } catch (e) {
          setState(() {
            _messages[_messages.length - 1] = ChatMessage(
              content: '识别失败',
              isUser: true,
            );
          });
          _showMessage('语音识别失败', isError: true);
        }
      }
    } catch (e) {
      debugPrint('录音失败: $e');
      _showMessage('录音失败', isError: true);
    } finally {
      setState(() {
        _isProcessing = false;
        _recordingSeconds = 0;
      });
    }
  }

  Future<void> _sendMessageToAi(String text, {String? audioUrl}) async {
    final aiMessage = ChatMessage(content: '正在思考...', isUser: false);
    setState(() {
      _messages.add(aiMessage);
      _isAiSpeaking = true;
    });
    _waveController.repeat();
    _scrollToBottom();

    try {
      final chatService = ChatService();
      final sessionId =
          widget.sessionId ?? chatService.currentSessionId ?? 'voice_session';

      String promptText = text;
      if (audioUrl != null && audioUrl.isNotEmpty) {
        promptText = '[audio:$audioUrl]$text';
      }

      String fullResponse = '';

      await for (final chunk in chatService.sendMessage(
        prompt: promptText,
        chatId: sessionId,
      )) {
        if (chunk.startsWith('[ERROR:') || chunk.startsWith('[CANCELLED]')) {
          throw Exception(chunk);
        }
        fullResponse += chunk;

        setState(() {
          _messages[_messages.length - 1] = ChatMessage(
            content: fullResponse,
            isUser: false,
          );
        });
        _scrollToBottom();
      }

      if (fullResponse.isEmpty) {
        fullResponse = '抱歉，我没有理解您的问题。';
      }

      setState(() {
        _messages[_messages.length - 1] = ChatMessage(
          content: fullResponse,
          isUser: false,
        );
      });

      await _voiceService.synthesizeSpeech(fullResponse);

      try {
        final ttsAudioUrl = await ChatService().synthesizeSpeech(fullResponse);
        if (ttsAudioUrl != null && ttsAudioUrl.isNotEmpty) {
          final chatService = ChatService();
          final sid = widget.sessionId ??
              chatService.currentSessionId ??
              'voice_session';
          await chatService.updateTtsUrl(sid, ttsAudioUrl);
        }
      } catch (e) {
        debugPrint('保存TTS URL失败: $e');
      }
    } catch (e) {
      setState(() {
        _messages[_messages.length - 1] = ChatMessage(
          content: 'AI回复失败',
          isUser: false,
        );
      });
      _showMessage('语音合成失败', isError: true);
    } finally {
      setState(() {
        _isAiSpeaking = false;
      });
      _waveController.stop();
      _waveController.reset();
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    if (isError) {
      NotificationHelper.showError(message: msg);
    } else {
      NotificationHelper.showInfo(message: msg);
    }
  }

  void _endCall() {
    _voiceService.stopPlaying();
    Navigator.pop(context, _messages);
  }

  Color _getStatusColor() {
    if (_isRecording) return Colors.redAccent;
    if (_isProcessing) return Colors.orange;
    if (_isAiSpeaking) return _accentPurple;
    return const Color(0xFF4ADE80);
  }

  String _getStatusText() {
    if (_isRecording) return '正在聆听...';
    if (_isProcessing) return '正在识别...';
    if (_isAiSpeaking) return '正在回复...';
    return '随时可以说话';
  }

  // ─────────────────────────── BUILD ────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Layered gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_bgTop, _bgMid, _bgBot],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Subtle radial glow at center
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _idleAnimation,
              builder: (context, _) {
                return Center(
                  child: Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _accentPurple.withOpacity(
                            0.04 + 0.04 * _idleAnimation.value,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState()
                      : _buildConversationArea(),
                ),
                _buildControlArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── HEADER ───────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: _endCall,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: const Icon(
                LucideIcons.chevron_down,
                color: Colors.white60,
                size: 18,
              ),
            ),
          ),

          // Center title + status
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated status dot
                    AnimatedBuilder(
                      animation: _ringController,
                      builder: (_, __) {
                        final color = _getStatusColor();
                        return Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.8),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '灵伴',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 38), // balance
        ],
      ),
    );
  }

  // ─────────────────────────── EMPTY STATE ──────────────────────

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 48),
          _buildCenterAvatar(large: true),
          const SizedBox(height: 36),
          const Text(
            '嗨，我在这里',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '按住下方麦克风开始语音对话',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 36),
          // Feature pills row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeaturePill(Icons.hearing_rounded, '实时识别'),
              const SizedBox(width: 10),
              _buildFeaturePill(Icons.record_voice_over_rounded, '语音回复'),
              const SizedBox(width: 10),
              _buildFeaturePill(Icons.psychology_rounded, 'AI驱动'),
            ],
          ),
          const SizedBox(height: 32),
          // Suggestion chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip('今天心情如何？'),
              _buildSuggestionChip('帮我分析健康数据'),
              _buildSuggestionChip('给我讲个故事'),
              _buildSuggestionChip('最近有什么新鲜事？'),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _accentPurple.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentPurple.withOpacity(0.25), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _accentPurple.withOpacity(0.9)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13),
      ),
    );
  }

  // ──────────────────────── CENTER AVATAR ───────────────────────

  Widget _buildCenterAvatar({bool large = false}) {
    final isActive = _isRecording || _isAiSpeaking;
    final baseSize = large ? 110.0 : 72.0;
    final containerSize = large ? 220.0 : 160.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_ringController, _idleController]),
      builder: (context, _) {
        return SizedBox(
          width: containerSize,
          height: containerSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Idle soft glow
              if (!isActive)
                Container(
                  width: baseSize + 40,
                  height: baseSize + 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accentPurple.withOpacity(
                      0.04 + 0.06 * _idleAnimation.value,
                    ),
                  ),
                ),

              // Expanding rings when active
              if (isActive)
                for (int i = 0; i < 3; i++)
                  Builder(
                    builder: (ctx) {
                      final delay = i / 3;
                      final v = (_ringController.value + delay) % 1.0;
                      final sz =
                          baseSize + 12 + v * (containerSize - baseSize - 12);
                      final op = (1.0 - v) * (_isRecording ? 0.55 : 0.45);
                      return Container(
                        width: sz,
                        height: sz,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (_isRecording
                                    ? Colors.redAccent
                                    : _accentPurple)
                                .withOpacity(op),
                            width: 1.5,
                          ),
                        ),
                      );
                    },
                  ),

              // Inner gradient circle
              Container(
                width: baseSize,
                height: baseSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _isRecording
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.redAccent, Colors.red.shade800],
                        )
                      : null,
                  color: _isRecording ? null : _accentPurple.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? Colors.redAccent : _accentPurple)
                          .withOpacity(
                        isActive ? 0.65 : 0.2 + 0.18 * _idleAnimation.value,
                      ),
                      blurRadius: isActive ? 48 : 24,
                      spreadRadius: isActive ? 6 : 0,
                    ),
                  ],
                ),
                child: _isRecording
                    ? Icon(
                        LucideIcons.mic,
                        size: large ? 48 : 30,
                        color: Colors.white,
                      )
                    : _isAiSpeaking
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  'assets/ai_chat_logo.png',
                                  width: baseSize,
                                  height: baseSize,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Icon(
                                Icons.volume_up_rounded,
                                size: large ? 32 : 20,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(blurRadius: 8, color: Colors.black54),
                                ],
                              ),
                            ],
                          )
                        : ClipOval(
                            child: Image.asset(
                              'assets/ai_chat_logo.png',
                              width: baseSize,
                              height: baseSize,
                              fit: BoxFit.cover,
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────── CONVERSATION ─────────────────────────

  Widget _buildConversationArea() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI avatar
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(
                  'assets/ai_chat_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],

          // Bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.68,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_accentPurple, _accentDeep],
                      )
                    : null,
                color: isUser ? null : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: _accentPurple.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                msg.content,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.white.withOpacity(0.88),
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
            ),
          ),

          // User avatar
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                size: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────── CONTROL AREA ─────────────────────────

  Widget _buildControlArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status/visualizer zone
          SizedBox(height: 46, child: _buildStatusZone()),
          const SizedBox(height: 20),
          // Buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: LucideIcons.phone_off,
                label: '结束',
                bgColor: Colors.red.withOpacity(0.8),
                size: 54,
                onTap: _endCall,
              ),
              _buildMicButton(),
              _buildActionButton(
                icon: Icons.message_rounded,
                label: '消息',
                bgColor: Colors.white.withOpacity(0.08),
                size: 54,
                onTap: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusZone() {
    if (_isRecording) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimerBadge(),
          const SizedBox(width: 16),
          _buildWaveBars(color: Colors.redAccent),
        ],
      );
    }

    if (_isProcessing) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation(
                  Colors.white.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '正在识别语音...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    if (_isAiSpeaking) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildWaveBars(color: _accentPurple),
            const SizedBox(width: 14),
            Text(
              '灵伴正在回复',
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Text(
        _messages.isEmpty ? '长按麦克风开始说话' : '长按继续对话',
        style: TextStyle(
          color: Colors.white.withOpacity(0.28),
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildWaveBars({required Color color}) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(9, (i) {
            final phase = i * 0.75;
            final raw = 0.5 + 0.5 * sin(_waveController.value * 2 * pi + phase);
            final barH = 5.0 + 26.0 * raw;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3.5,
              height: barH,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withOpacity(0.9), color.withOpacity(0.4)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildTimerBadge() {
    final minutes = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordingSeconds % 60).toInt().toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            '$minutes:$seconds',
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── MIC BUTTON ───────────────────────────

  Widget _buildMicButton() {
    final isLoading = _isProcessing || _isAiSpeaking;

    return GestureDetector(
      onTapDown: isLoading ? null : (_) => _startRecording(),
      onTapUp: isLoading ? null : (_) => _stopRecording(),
      onTapCancel: isLoading ? null : () => _stopRecording(),
      child: AnimatedBuilder(
        animation: _ringController,
        builder: (context, _) {
          return SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing rings when recording
                if (_isRecording)
                  for (int i = 0; i < 2; i++)
                    Builder(
                      builder: (ctx) {
                        final delay = i * 0.5;
                        final v = (_ringController.value + delay) % 1.0;
                        final sz = 84.0 + v * 32.0;
                        final op = (1.0 - v) * 0.5;
                        return Container(
                          width: sz,
                          height: sz,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(op),
                              width: 1.5,
                            ),
                          ),
                        );
                      },
                    ),

                // Button body
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isRecording
                          ? [Colors.redAccent, Colors.red.shade800]
                          : isLoading
                              ? [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ]
                              : [_accentPurple, _accentDeep],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording
                                ? Colors.redAccent
                                : isLoading
                                    ? Colors.transparent
                                    : _accentPurple)
                            .withOpacity(_isRecording ? 0.55 : 0.45),
                        blurRadius: 28,
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(
                        _isRecording ? 0.0 : 0.12,
                      ),
                      width: 0.8,
                    ),
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(
                                Colors.white.withOpacity(0.55),
                              ),
                            ),
                          )
                        : Icon(
                            _isRecording ? LucideIcons.square : LucideIcons.mic,
                            size: 34,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────── ACTION BUTTON ────────────────────────

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required double size,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 0.5,
              ),
            ),
            child: Icon(icon, size: 22, color: Colors.white.withOpacity(0.85)),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
