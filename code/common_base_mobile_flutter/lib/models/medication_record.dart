class MedicationRecord {
  final String? id;
  final String? userId;
  final String? planId;
  final DateTime? scheduledTime;
  final DateTime? actualTime;
  final int? status;
  final String? remark;
  final DateTime? createdAt;
  final String? drugName;
  final String? dosage;
  final String? frequency;
  final String? timePoints;
  final String? instruction;
  final String? userName;
  final String? userAvatar;
  final String? notificationId;

  MedicationRecord({
    this.id,
    this.userId,
    this.planId,
    this.scheduledTime,
    this.actualTime,
    this.status,
    this.remark,
    this.createdAt,
    this.drugName,
    this.dosage,
    this.frequency,
    this.timePoints,
    this.instruction,
    this.userName,
    this.userAvatar,
    this.notificationId,
  });

  factory MedicationRecord.fromJson(Map<String, dynamic> json) {
    return MedicationRecord(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      planId: json['planId']?.toString(),
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'])
          : null,
      actualTime:
          json['actualTime'] != null ? DateTime.parse(json['actualTime']) : null,
      status: json['status'] as int?,
      remark: json['remark'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      drugName: json['drugName'] as String?,
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      timePoints: json['timePoints'] as String?,
      instruction: json['instruction'] as String?,
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      notificationId: json['notificationId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'planId': planId,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'actualTime': actualTime?.toIso8601String(),
      'status': status,
      'remark': remark,
      'createdAt': createdAt?.toIso8601String(),
      'drugName': drugName,
      'dosage': dosage,
      'frequency': frequency,
      'timePoints': timePoints,
      'instruction': instruction,
      'userName': userName,
      'userAvatar': userAvatar,
      'notificationId': notificationId,
    };
  }

  bool get isCheckedIn => status == 1;
  bool get isMissed => status == 0 && scheduledTime != null && scheduledTime!.isBefore(DateTime.now());
  bool get isPending => status == 0 && scheduledTime != null && !scheduledTime!.isBefore(DateTime.now());

  String get statusText {
    if (isCheckedIn) return '已服用';
    if (isMissed) return '已错过';
    return '待服用';
  }
}
