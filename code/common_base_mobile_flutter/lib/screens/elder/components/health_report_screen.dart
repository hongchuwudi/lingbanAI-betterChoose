import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../../../models/api_response.dart';
import '../../../models/parsed_health_indicator.dart';
import '../../../services/health_service.dart';

class HealthReportScreen extends StatefulWidget {
  const HealthReportScreen({super.key});

  @override
  State<HealthReportScreen> createState() => _HealthReportScreenState();
}

class _HealthReportScreenState extends State<HealthReportScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  File? _selectedFile;
  List<int>? _selectedBytes;
  String? _fileName;
  bool _isLoading = false;
  bool _isAnalyzing = false;
  String _parseStatus = '';
  int? _recordId;
  int _indicatorCount = 0;
  String? _errorMessage;
  List<ParsedHealthIndicator> _indicators = [];
  final ImagePicker _imagePicker = ImagePicker();
  Timer? _pollTimer;
  Timer? _analysisPollTimer;

  int? _analysisId;
  String _analysisStatus = '';
  HealthAnalysisResponse? _analysisResult;

  static const int _maxFileSize = 10 * 1024 * 1024;

  @override
  void dispose() {
    _pollTimer?.cancel();
    _analysisPollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUploadCard(isDark, colorScheme),
          const SizedBox(height: 20),
          if (_isLoading) _buildLoadingIndicator(isDark, colorScheme),
          if (_errorMessage != null && !_isLoading)
            _buildErrorCard(isDark, colorScheme),
          if (!_isLoading && _indicatorCount > 0) ...[
            _buildResultHeader(isDark, colorScheme),
            const SizedBox(height: 12),
            Text(
              '已识别 $_indicatorCount 项健康指标',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(height: 16),
            _buildAnalyzeButton(isDark, colorScheme),
          ],
          if (_isAnalyzing) _buildAnalysisLoading(isDark, colorScheme),
          if (_analysisResult != null && !_isAnalyzing)
            _buildAnalysisResult(isDark, colorScheme),
        ],
      ),
    );
  }

  Widget _buildUploadCard(bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252542) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.fileUp,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '上传健康报告',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '支持 PDF、JPG、PNG 格式，最大 10MB',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showHistoryBottomSheet(isDark, colorScheme),
                  icon: Icon(
                    LucideIcons.history,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  tooltip: '历史记录',
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_selectedFile == null && _selectedBytes == null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildUploadButton(
                      icon: LucideIcons.image,
                      label: '选择图片',
                      onTap: () => _pickImage(),
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUploadButton(
                      icon: LucideIcons.camera,
                      label: '拍照',
                      onTap: () => _takePhoto(),
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUploadButton(
                      icon: LucideIcons.fileText,
                      label: 'PDF文件',
                      onTap: () => _pickPdf(),
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildSelectedFileCard(isDark, colorScheme),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _clearSelection,
                      icon: const Icon(LucideIcons.trash2, size: 18),
                      label: const Text('清除'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.withAlpha(138)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _uploadAndParse,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(LucideIcons.sparkles, size: 18),
                      label: Text(_isLoading ? '处理中...' : '上传并解析'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFileCard(bool isDark, ColorScheme colorScheme) {
    final isImage =
        _fileName!.toLowerCase().endsWith('.jpg') ||
        _fileName!.toLowerCase().endsWith('.jpeg') ||
        _fileName!.toLowerCase().endsWith('.png');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isImage && _selectedFile != null && !kIsWeb
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_selectedFile!, fit: BoxFit.cover),
                  )
                : Icon(
                    isImage ? LucideIcons.image : LucideIcons.fileText,
                    size: 24,
                    color: colorScheme.primary,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fileName!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _getFileSize(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.checkCircle, size: 20, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isDark, ColorScheme colorScheme) {
    String statusText;
    switch (_parseStatus) {
      case 'pending':
        statusText = '文件已上传，等待处理...';
        break;
      case 'processing':
        statusText = 'AI 正在分析中...';
        break;
      default:
        statusText = '正在处理...';
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252542) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        children: [
          SpinKitFadingCube(color: colorScheme.primary, size: 40),
          const SizedBox(height: 20),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请稍候，解析完成后将自动显示结果',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.alertCircle, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? '解析失败',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultHeader(bool isDark, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            LucideIcons.checkCircle2,
            size: 20,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '识别完成',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                '健康指标已自动保存到您的健康档案',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton(bool isDark, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isAnalyzing ? null : _startAnalysis,
        icon: _isAnalyzing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(LucideIcons.brain, size: 20),
        label: Text(_isAnalyzing ? 'AI分析中...' : 'AI健康分析'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisLoading(bool isDark, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252542) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SpinKitPulse(color: const Color(0xFF6366F1), size: 50),
          const SizedBox(height: 20),
          Text(
            'AI正在分析您的健康数据...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '正在生成健康建议和用药推荐',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult(bool isDark, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252542) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.heartPulse,
                    color: Color(0xFF6366F1),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI健康分析报告',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '基于您的健康指标生成',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_analysisResult!.healthConclusion != null)
            _buildAnalysisSection(
              title: '健康结论',
              icon: LucideIcons.clipboardCheck,
              content: _analysisResult!.healthConclusion!,
              color: Colors.green,
              isDark: isDark,
            ),
          if (_analysisResult!.currentStatus != null)
            _buildAnalysisSection(
              title: '当前状况',
              icon: LucideIcons.activity,
              content: _analysisResult!.currentStatus!,
              color: Colors.blue,
              isDark: isDark,
            ),
          if (_analysisResult!.medicationRecommendation != null)
            _buildAnalysisSection(
              title: '用药推荐',
              icon: LucideIcons.pill,
              content: _analysisResult!.medicationRecommendation!,
              color: Colors.orange,
              isDark: isDark,
            ),
          if (_analysisResult!.improvementPoints != null)
            _buildAnalysisSection(
              title: '改善建议',
              icon: LucideIcons.trendingUp,
              content: _analysisResult!.improvementPoints!,
              color: Colors.teal,
              isDark: isDark,
            ),
          if (_analysisResult!.recheckReminders != null)
            _buildAnalysisSection(
              title: '复查提醒',
              icon: LucideIcons.calendarClock,
              content: _analysisResult!.recheckReminders!,
              color: Colors.purple,
              isDark: isDark,
            ),
          if (_analysisResult!.suggestedIndicators != null)
            _buildAnalysisSection(
              title: '建议关注',
              icon: LucideIcons.heart,
              content: _analysisResult!.suggestedIndicators!,
              color: Colors.red,
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFileSize() {
    final bytes = _selectedBytes?.length ?? _selectedFile?.lengthSync() ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatTime(String time) {
    try {
      final dt = DateTime.parse(time);
      return DateFormat('MM-dd HH:mm').format(dt);
    } catch (e) {
      return time;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      final name = image.name;

      if (bytes.length > _maxFileSize) {
        _showError('文件大小超过10MB限制');
        return;
      }

      setState(() {
        _selectedFile = File(image.path);
        _selectedBytes = bytes;
        _fileName = name;
        _indicators = [];
        _errorMessage = null;
        _indicatorCount = 0;
        _analysisResult = null;
      });
    } catch (e) {
      _showError('选择图片失败: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      final name = image.name;

      if (bytes.length > _maxFileSize) {
        _showError('文件大小超过10MB限制');
        return;
      }

      setState(() {
        _selectedFile = File(image.path);
        _selectedBytes = bytes;
        _fileName = name;
        _indicators = [];
        _errorMessage = null;
        _indicatorCount = 0;
        _analysisResult = null;
      });
    } catch (e) {
      _showError('拍照失败: $e');
    }
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final name = file.name;
      final bytes = file.bytes;

      if (bytes == null) {
        _showError('无法读取文件内容');
        return;
      }

      if (bytes.length > _maxFileSize) {
        _showError('文件大小超过10MB限制');
        return;
      }

      final ext = name.toLowerCase().split('.').last;
      if (!['pdf', 'jpg', 'jpeg', 'png'].contains(ext)) {
        _showError('不支持的文件格式');
        return;
      }

      setState(() {
        _selectedFile = null;
        _selectedBytes = bytes;
        _fileName = name;
        _indicators = [];
        _errorMessage = null;
        _indicatorCount = 0;
        _analysisResult = null;
      });
    } catch (e) {
      _showError('选择文件失败: $e');
    }
  }

  void _clearSelection() {
    _pollTimer?.cancel();
    _analysisPollTimer?.cancel();
    setState(() {
      _selectedFile = null;
      _selectedBytes = null;
      _fileName = null;
      _indicators = [];
      _errorMessage = null;
      _indicatorCount = 0;
      _recordId = null;
      _parseStatus = '';
      _analysisId = null;
      _analysisStatus = '';
      _analysisResult = null;
    });
  }

  Future<void> _uploadAndParse() async {
    if (_fileName == null) return;
    if (_selectedFile == null && _selectedBytes == null) return;

    setState(() {
      _isLoading = true;
      _parseStatus = 'uploading';
      _errorMessage = null;
      _analysisResult = null;
    });

    try {
      ApiResponse<HealthParseResponse>? response;

      if (_selectedBytes != null) {
        response = await HealthService.uploadHealthDocumentBytes(
          bytes: _selectedBytes!,
          fileName: _fileName!,
        );
      } else if (_selectedFile != null) {
        response = await HealthService.uploadHealthDocument(
          filePath: _selectedFile!.path,
          fileName: _fileName!,
        );
      }

      if (response != null && response.isSuccess && response.data != null) {
        setState(() {
          _recordId = response!.data!.recordId;
          _parseStatus = response.data!.status;
        });

        _startPolling();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response?.message ?? '上传失败';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '上传失败: $e';
      });
    }
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_recordId == null) {
        timer.cancel();
        return;
      }

      try {
        final response = await HealthService.getParseRecord(_recordId!);

        if (response.isSuccess && response.data != null) {
          final record = response.data!;
          setState(() {
            _parseStatus = record.status;
          });

          if (record.status == 'completed') {
            timer.cancel();
            setState(() {
              _isLoading = false;
              _indicatorCount = record.indicatorCount ?? 0;
            });
          } else if (record.status == 'failed') {
            timer.cancel();
            setState(() {
              _isLoading = false;
              _errorMessage = record.errorMessage ?? '解析失败';
            });
          }
        }
      } catch (e) {
        timer.cancel();
        setState(() {
          _isLoading = false;
          _errorMessage = '查询状态失败: $e';
        });
      }
    });
  }

  Future<void> _startAnalysis() async {
    if (_recordId == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisStatus = 'pending';
    });

    try {
      final response = await HealthService.analyzeHealth(_recordId!);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _analysisId = response.data!.analysisId;
          _analysisStatus = response.data!.status;
        });

        if (_analysisStatus == 'completed' &&
            response.data!.healthConclusion != null) {
          setState(() {
            _isAnalyzing = false;
            _analysisResult = response.data;
          });
        } else {
          _startAnalysisPolling();
        }
      } else {
        setState(() {
          _isAnalyzing = false;
        });
        _showError(response.message);
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showError('分析失败: $e');
    }
  }

  void _startAnalysisPolling() {
    _analysisPollTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      if (_analysisId == null) {
        timer.cancel();
        return;
      }

      try {
        final response = await HealthService.getAnalysisRecord(_analysisId!);

        if (response.isSuccess && response.data != null) {
          final record = response.data!;
          setState(() {
            _analysisStatus = record.status;
          });

          if (record.status == 'completed') {
            timer.cancel();
            setState(() {
              _isAnalyzing = false;
              _analysisResult = record;
            });
          } else if (record.status == 'failed') {
            timer.cancel();
            setState(() {
              _isAnalyzing = false;
              _errorMessage = '分析失败';
            });
          }
        }
      } catch (e) {
        timer.cancel();
        setState(() {
          _isAnalyzing = false;
        });
        _showError('查询分析状态失败: $e');
      }
    });
  }

  void _showHistoryBottomSheet(bool isDark, ColorScheme colorScheme) {
    List<HealthAnalysisResponse> historyRecords = [];
    bool isLoadingHistory = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> loadRecords() async {
            final response = await HealthService.getAnalysisRecordList(
              page: 1,
              size: 20,
            );
            if (response.isSuccess) {
              setModalState(() {
                historyRecords = response.data ?? [];
                isLoadingHistory = false;
              });
            } else {
              setModalState(() {
                isLoadingHistory = false;
              });
            }
          }

          if (isLoadingHistory && historyRecords.isEmpty) {
            loadRecords();
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(LucideIcons.history, color: colorScheme.primary),
                        const SizedBox(width: 10),
                        Text(
                          '历史记录',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            LucideIcons.x,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: isLoadingHistory
                        ? Center(
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                          )
                        : historyRecords.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.inbox,
                                  size: 64,
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black12,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '暂无历史记录',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: historyRecords.length,
                            itemBuilder: (context, index) {
                              final record = historyRecords[index];
                              return _buildHistoryRecordCard(
                                record,
                                isDark,
                                colorScheme,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryRecordCard(
    HealthAnalysisResponse record,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (record.status) {
      case 'completed':
        statusColor = Colors.green;
        statusText = '分析完成';
        statusIcon = LucideIcons.checkCircle;
        break;
      case 'failed':
        statusColor = Colors.red;
        statusText = '分析失败';
        statusIcon = LucideIcons.xCircle;
        break;
      case 'processing':
      case 'pending':
        statusColor = Colors.orange;
        statusText = '分析中';
        statusIcon = LucideIcons.loader;
        break;
      default:
        statusColor = Colors.grey;
        statusText = '等待处理';
        statusIcon = LucideIcons.clock;
    }

    return GestureDetector(
      onTap: () => _showAnalysisDetail(record, isDark, colorScheme),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252542) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white10
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.healthConclusion != null ? '健康分析报告' : 'AI健康分析',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (record.createdAt != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatDateTime(record.createdAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: isDark ? Colors.white24 : Colors.black26,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalysisDetail(
    HealthAnalysisResponse record,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(LucideIcons.brain, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      'AI健康分析报告',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        LucideIcons.x,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: _AnalysisDetailContent(
                    analysis: record,
                    isDark: isDark,
                    colorScheme: colorScheme,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('yyyy-MM-dd HH:mm').format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }
}

class _AnalysisDetailContent extends StatelessWidget {
  final HealthAnalysisResponse analysis;
  final bool isDark;
  final ColorScheme colorScheme;

  const _AnalysisDetailContent({
    required this.analysis,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (analysis.status != 'completed') {
      return _buildStatusCard();
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252542) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.heartPulse,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI健康分析报告',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (analysis.createdAt != null)
                        Text(
                          _formatDateTime(analysis.createdAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (analysis.healthConclusion != null)
            _buildSection(
              '健康结论',
              LucideIcons.clipboardCheck,
              analysis.healthConclusion!,
              Colors.green,
            ),
          if (analysis.currentStatus != null)
            _buildSection(
              '当前状况',
              LucideIcons.activity,
              analysis.currentStatus!,
              Colors.blue,
            ),
          if (analysis.medicationRecommendation != null)
            _buildSection(
              '用药推荐',
              LucideIcons.pill,
              analysis.medicationRecommendation!,
              Colors.orange,
            ),
          if (analysis.improvementPoints != null)
            _buildSection(
              '改善建议',
              LucideIcons.trendingUp,
              analysis.improvementPoints!,
              Colors.teal,
            ),
          if (analysis.recheckReminders != null)
            _buildSection(
              '复查提醒',
              LucideIcons.calendarClock,
              analysis.recheckReminders!,
              Colors.purple,
            ),
          if (analysis.suggestedIndicators != null)
            _buildSection(
              '建议检查指标',
              LucideIcons.listChecks,
              analysis.suggestedIndicators!,
              Colors.indigo,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (analysis.status) {
      case 'failed':
        statusColor = Colors.red;
        statusText = '分析失败';
        statusIcon = LucideIcons.xCircle;
        break;
      case 'processing':
      case 'pending':
        statusColor = Colors.orange;
        statusText = '分析中，请稍后查看';
        statusIcon = LucideIcons.loader;
        break;
      default:
        statusColor = Colors.grey;
        statusText = '等待处理';
        statusIcon = LucideIcons.clock;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252542) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(statusIcon, size: 48, color: statusColor),
          const SizedBox(height: 12),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    String content,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white10
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('yyyy-MM-dd HH:mm').format(dt);
    } catch (e) {
      return dateTime;
    }
  }
}
