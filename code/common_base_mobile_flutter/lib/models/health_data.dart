class HealthDashboard {
  final BloodPressureData? bp;
  final GlucoseData? glucose;
  final HeartRateData? heartRate;
  final WeightData? weight;
  final Spo2Data? spo2;
  final StepData? steps;
  final SleepData? sleep;
  final List<HealthAlertData> alerts;
  final List<MedicationData> medications;

  HealthDashboard({
    this.bp,
    this.glucose,
    this.heartRate,
    this.weight,
    this.spo2,
    this.steps,
    this.sleep,
    this.alerts = const [],
    this.medications = const [],
  });

  factory HealthDashboard.fromJson(Map<String, dynamic> json) {
    return HealthDashboard(
      bp: json['bp'] != null ? BloodPressureData.fromJson(json['bp']) : null,
      glucose: json['glucose'] != null
          ? GlucoseData.fromJson(json['glucose'])
          : null,
      heartRate: json['heartRate'] != null
          ? HeartRateData.fromJson(json['heartRate'])
          : null,
      weight: json['weight'] != null
          ? WeightData.fromJson(json['weight'])
          : null,
      spo2: json['spo2'] != null ? Spo2Data.fromJson(json['spo2']) : null,
      steps: json['steps'] != null ? StepData.fromJson(json['steps']) : null,
      sleep: json['sleep'] != null ? SleepData.fromJson(json['sleep']) : null,
      alerts:
          (json['alerts'] as List<dynamic>?)
              ?.map((e) => HealthAlertData.fromJson(e))
              .toList() ??
          [],
      medications:
          (json['medications'] as List<dynamic>?)
              ?.map((e) => MedicationData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class BloodPressureData {
  final int? systolic;
  final int? diastolic;
  final int? pulse;
  final String? recordTime;
  final String? status;

  BloodPressureData({
    this.systolic,
    this.diastolic,
    this.pulse,
    this.recordTime,
    this.status,
  });

  factory BloodPressureData.fromJson(Map<String, dynamic> json) {
    return BloodPressureData(
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      pulse: json['pulse'],
      recordTime: json['recordTime'],
      status: json['status'],
    );
  }
}

class GlucoseData {
  final double? value;
  final String? type;
  final String? recordTime;
  final String? status;

  GlucoseData({this.value, this.type, this.recordTime, this.status});

  factory GlucoseData.fromJson(Map<String, dynamic> json) {
    return GlucoseData(
      value: (json['value'] as num?)?.toDouble(),
      type: json['type'],
      recordTime: json['recordTime'],
      status: json['status'],
    );
  }
}

class HeartRateData {
  final int? value;
  final String? recordTime;
  final String? status;

  HeartRateData({this.value, this.recordTime, this.status});

  factory HeartRateData.fromJson(Map<String, dynamic> json) {
    return HeartRateData(
      value: json['value'],
      recordTime: json['recordTime'],
      status: json['status'],
    );
  }
}

class WeightData {
  final double? value;
  final double? bmi;
  final String? recordTime;
  final String? status;

  WeightData({this.value, this.bmi, this.recordTime, this.status});

  factory WeightData.fromJson(Map<String, dynamic> json) {
    return WeightData(
      value: (json['value'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      recordTime: json['recordTime'],
      status: json['status'],
    );
  }
}

class Spo2Data {
  final int? value;
  final String? recordTime;
  final String? status;

  Spo2Data({this.value, this.recordTime, this.status});

  factory Spo2Data.fromJson(Map<String, dynamic> json) {
    return Spo2Data(
      value: json['value'],
      recordTime: json['recordTime'],
      status: json['status'],
    );
  }
}

class StepData {
  final int? count;
  final int? goal;
  final double? percentage;
  final String? date;

  StepData({this.count, this.goal, this.percentage, this.date});

  factory StepData.fromJson(Map<String, dynamic> json) {
    return StepData(
      count: json['count'],
      goal: json['goal'],
      percentage: (json['percentage'] as num?)?.toDouble(),
      date: json['date'],
    );
  }
}

class SleepData {
  final double? duration;
  final int? quality;
  final String? date;

  SleepData({this.duration, this.quality, this.date});

  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      duration: (json['duration'] as num?)?.toDouble(),
      quality: json['quality'],
      date: json['date'],
    );
  }
}

class HealthAlertData {
  final int? id;
  final String? indicatorName;
  final String? indicatorCode;
  final String? alertType;
  final String? actualValue;
  final String? normalRange;
  final int? severity;
  final String? alertTime;

  HealthAlertData({
    this.id,
    this.indicatorName,
    this.indicatorCode,
    this.alertType,
    this.actualValue,
    this.normalRange,
    this.severity,
    this.alertTime,
  });

  factory HealthAlertData.fromJson(Map<String, dynamic> json) {
    return HealthAlertData(
      id: json['id'],
      indicatorName: json['indicatorName'],
      indicatorCode: json['indicatorCode'],
      alertType: json['alertType'],
      actualValue: json['actualValue'],
      normalRange: json['normalRange'],
      severity: json['severity'],
      alertTime: json['alertTime'],
    );
  }
}

class MedicationData {
  final int? id;
  final int? planId;
  final String? drugName;
  final String? dosage;
  final String? scheduledTime;
  final bool? taken;

  MedicationData({
    this.id,
    this.planId,
    this.drugName,
    this.dosage,
    this.scheduledTime,
    this.taken,
  });

  factory MedicationData.fromJson(Map<String, dynamic> json) {
    return MedicationData(
      id: json['id'],
      planId: json['planId'],
      drugName: json['drugName'],
      dosage: json['dosage'],
      scheduledTime: json['scheduledTime'],
      taken: json['taken'],
    );
  }
}
