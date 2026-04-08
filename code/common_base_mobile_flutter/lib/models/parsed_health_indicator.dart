class ParsedHealthIndicator {
  final String? indicatorCode;
  final double? value;
  final String? unit;
  final String? recordTime;
  final String? type;

  ParsedHealthIndicator({
    this.indicatorCode,
    this.value,
    this.unit,
    this.recordTime,
    this.type,
  });

  factory ParsedHealthIndicator.fromJson(Map<String, dynamic> json) {
    return ParsedHealthIndicator(
      indicatorCode: json['indicatorCode'] as String?,
      value: (json['value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      recordTime: json['recordTime'] as String?,
      type: json['type'] as String?,
    );
  }

  static List<ParsedHealthIndicator> fromJsonList(List<dynamic> list) {
    return list.map((e) => ParsedHealthIndicator.fromJson(e)).toList();
  }

  String get indicatorName {
    return _indicatorNameMap[indicatorCode] ?? indicatorCode ?? '未知指标';
  }

  String get statusText {
    if (value == null) return '未知';

    final normalRange = _normalRanges[indicatorCode];
    if (normalRange == null) return '正常';

    if (value! < normalRange['min']!) return '偏低';
    if (value! > normalRange['max']!) return '偏高';
    return '正常';
  }

  String get statusColor {
    switch (statusText) {
      case '偏低':
        return 'low';
      case '偏高':
        return 'high';
      default:
        return 'normal';
    }
  }

  static const Map<String?, String> _indicatorNameMap = {
    'bp_systolic': '收缩压',
    'bp_diastolic': '舒张压',
    'pulse': '脉搏',
    'glucose_fasting': '空腹血糖',
    'glucose_postprandial': '餐后血糖',
    'heart_rate': '心率',
    'weight': '体重',
    'spo2': '血氧饱和度',
    'steps': '步数',
    'sleep_duration': '睡眠时长',
    'total_cholesterol': '总胆固醇',
    'triglyceride': '甘油三酯',
    'hdl_cholesterol': '高密度脂蛋白',
    'ldl_cholesterol': '低密度脂蛋白',
    'creatinine': '肌酐',
    'uric_acid': '尿酸',
    'alt': '谷丙转氨酶',
    'ast': '谷草转氨酶',
  };

  static const Map<String?, Map<String, double>> _normalRanges = {
    'bp_systolic': {'min': 90, 'max': 140},
    'bp_diastolic': {'min': 60, 'max': 90},
    'pulse': {'min': 60, 'max': 100},
    'glucose_fasting': {'min': 3.9, 'max': 6.1},
    'glucose_postprandial': {'min': 3.9, 'max': 7.8},
    'heart_rate': {'min': 60, 'max': 100},
    'spo2': {'min': 95, 'max': 100},
    'total_cholesterol': {'min': 0, 'max': 5.2},
    'triglyceride': {'min': 0, 'max': 1.7},
    'hdl_cholesterol': {'min': 1.0, 'max': 10},
    'ldl_cholesterol': {'min': 0, 'max': 3.4},
    'creatinine': {'min': 44, 'max': 133},
    'uric_acid': {'min': 150, 'max': 420},
    'alt': {'min': 0, 'max': 40},
    'ast': {'min': 0, 'max': 40},
  };
}
