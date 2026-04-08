class SystemNotification {
  final String? id;
  final String? userId;
  final String? type;
  final String? title;
  final String? content;
  final String? level;
  final String? relatedId;
  final String? relatedType;
  final int? status;
  final DateTime? readAt;
  final DateTime? createdAt;
  final String? medicineName;
  final String? dosage;
  final String? scheduledTime;
  final bool? canCheckIn;
  final bool? checkedIn;

  SystemNotification({
    this.id,
    this.userId,
    this.type,
    this.title,
    this.content,
    this.level,
    this.relatedId,
    this.relatedType,
    this.status,
    this.readAt,
    this.createdAt,
    this.medicineName,
    this.dosage,
    this.scheduledTime,
    this.canCheckIn,
    this.checkedIn,
  });

  factory SystemNotification.fromJson(Map<String, dynamic> json) {
    return SystemNotification(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      type: json['type'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      level: json['level'] as String?,
      relatedId: json['relatedId']?.toString(),
      relatedType: json['relatedType'] as String?,
      status: json['status'] as int?,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      medicineName: json['medicineName'] as String?,
      dosage: json['dosage'] as String?,
      scheduledTime: json['scheduledTime'] as String?,
      canCheckIn: json['canCheckIn'] as bool?,
      checkedIn: json['checkedIn'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'content': content,
      'level': level,
      'relatedId': relatedId,
      'relatedType': relatedType,
      'status': status,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'medicineName': medicineName,
      'dosage': dosage,
      'scheduledTime': scheduledTime,
      'canCheckIn': canCheckIn,
      'checkedIn': checkedIn,
    };
  }

  bool get isRead => status == 1;
  bool get isMedicationReminder => type == 'medication_reminder';
  bool get isRemindFromChild => type == 'medication_remind_from_child';
}
