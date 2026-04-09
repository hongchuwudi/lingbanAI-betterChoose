import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final bool showTimestamp;
  final Future<String?> Function(String)? onSynthesizeSpeech;

  const ChatBubble({
    super.key,
    required this.message,
    this.showTimestamp = false,
    this.onSynthesizeSpeech,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isSynthesizing = false;
  String? _ttsAudioUrl;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isPlaying = true);
    await _audioPlayer.play(UrlSource(url));

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  Future<void> _synthesizeAndPlay() async {
    if (widget.onSynthesizeSpeech == null) return;

    if (_ttsAudioUrl != null) {
      await _playAudio(_ttsAudioUrl!);
      return;
    }

    setState(() => _isSynthesizing = true);
    try {
      final url = await widget.onSynthesizeSpeech!(widget.message.content);
      if (url != null) {
        _ttsAudioUrl = url;
        await _playAudio(url);
      }
    } finally {
      if (mounted) {
        setState(() => _isSynthesizing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: widget.message.isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (widget.showTimestamp)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _formatTime(widget.message.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          ),
        Row(
          mainAxisAlignment: widget.message.isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!widget.message.isUser) ...[
              _buildAvatar(colorScheme, isDark),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.message.isUser
                      ? colorScheme.primary
                      : isDark
                          ? colorScheme.surfaceContainerHighest
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(widget.message.isUser ? 20 : 4),
                    bottomRight: Radius.circular(
                      widget.message.isUser ? 4 : 20,
                    ),
                  ),
                  boxShadow: widget.message.isUser
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.message.imageUrls != null &&
                        widget.message.imageUrls!.isNotEmpty)
                      _buildImages(context),
                    if (widget.message.audioUrl != null)
                      _buildAudioButton(
                        widget.message.audioUrl!,
                        colorScheme,
                        isUser: true,
                      ),
                    if (widget.message.content.isEmpty &&
                        widget.message.isStreaming)
                      _buildThinkingIndicator(colorScheme)
                    else if (widget.message.content.isNotEmpty)
                      widget.message.isUser
                          ? Text(
                              widget.message.content,
                              style: TextStyle(
                                fontSize: 15,
                                color: colorScheme.onPrimary,
                                height: 1.4,
                              ),
                            )
                          : MarkdownBody(
                              data: widget.message.content,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(
                                  fontSize: 15,
                                  color: colorScheme.onSurface,
                                  height: 1.5,
                                ),
                                code: TextStyle(
                                  backgroundColor: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade200,
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  height: 1.5,
                                  color: isDark
                                      ? Colors.grey.shade200
                                      : Colors.grey.shade900,
                                ),
                                codeblockDecoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E1E1E)
                                      : const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                codeblockPadding: const EdgeInsets.all(12),
                                blockquote: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                                blockquoteDecoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: colorScheme.primary,
                                      width: 4,
                                    ),
                                  ),
                                ),
                                blockquotePadding: const EdgeInsets.only(
                                  left: 12,
                                ),
                                listBullet: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 15,
                                ),
                                tableHead: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                tableBody: TextStyle(fontSize: 14),
                              ),
                              onTapLink: (text, href, title) {},
                            ),
                    if (widget.message.isStreaming)
                      _buildTypingIndicator(colorScheme),
                  ],
                ),
              ),
            ),
            if (!widget.message.isUser && widget.message.content.isNotEmpty)
              _buildTTSButton(colorScheme),
            if (widget.message.isUser) ...[
              const SizedBox(width: 8),
              _buildAvatar(colorScheme, isDark),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAudioButton(
    String url,
    ColorScheme colorScheme, {
    bool isUser = false,
  }) {
    return GestureDetector(
      onTap: () => _playAudio(url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isUser
              ? colorScheme.onPrimary.withOpacity(0.2)
              : colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isPlaying ? Icons.stop : Icons.play_arrow,
              size: 20,
              color: isUser ? colorScheme.onPrimary : colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              _isPlaying ? '停止' : '播放语音',
              style: TextStyle(
                fontSize: 13,
                color: isUser ? colorScheme.onPrimary : colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTTSButton(ColorScheme colorScheme) {
    if (widget.message.ttsAudioUrl != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: GestureDetector(
          onTap: () => _playAudio(widget.message.ttsAudioUrl!),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPlaying ? Icons.stop : Icons.volume_up,
              size: 18,
              color: colorScheme.primary,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: GestureDetector(
        onTap: _isSynthesizing ? null : _synthesizeAndPlay,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: _isSynthesizing
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                )
              : Icon(
                  Icons.volume_up_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme, bool isDark) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: widget.message.isUser
            ? colorScheme.primaryContainer
            : colorScheme.secondaryContainer,
        shape: BoxShape.circle,
      ),
      child: widget.message.isUser
          ? Icon(Icons.person, size: 18, color: colorScheme.onPrimaryContainer)
          : ClipOval(
              child: Image.asset('assets/ai_chat_logo.png', fit: BoxFit.cover),
            ),
    );
  }

  Widget _buildImages(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.message.imageUrls!.map((url) {
        return GestureDetector(
          onTap: () => _showImagePreview(context, url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImage(url),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 150,
          height: 150,
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image),
        ),
      );
    } else {
      if (kIsWeb) {
        return Image.network(
          url,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 150,
            height: 150,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image),
          ),
        );
      } else {
        return Image.file(
          File(Uri.parse(url).toFilePath()),
          width: 150,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 150,
            height: 150,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image),
          ),
        );
      }
    }
  }

  void _showImagePreview(BuildContext context, String url) {
    ImageProvider imageProvider;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      imageProvider = NetworkImage(url);
    } else {
      if (kIsWeb) {
        imageProvider = NetworkImage(url);
      } else {
        imageProvider = FileImage(File(Uri.parse(url).toFilePath()));
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
          body: PhotoView(
            imageProvider: imageProvider,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingIndicator(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              colorScheme.primary.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '思考中...',
          style: TextStyle(
            fontSize: 15,
            color: colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inDays < 1) {
      return DateFormat('HH:mm').format(time);
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return DateFormat('MM-dd HH:mm').format(time);
    }
  }
}
