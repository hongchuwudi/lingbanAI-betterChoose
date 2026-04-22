import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  @JsonKey(fromJson: _idFromStringOrInt)
  final String id;
  final String nickname;
  final String username;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? birthday;
  final int? gender;
  final String? bio;
  final int? updateUnTimes;
  final bool? isVip;
  final String? createdAt;
  final String? updatedAt;
  final String? roleCode;
  final String? roleName;
  final String? roleCategory;
  final String? roleDescription;
  final bool? isActive;
  final String? token;
  final String? refreshToken;
  final ElderlyProfile? elderlyProfile;
  final ChildProfile? childProfile;

  User({
    required this.id,
    required this.nickname,
    required this.username,
    this.email,
    this.phone,
    this.avatar,
    this.birthday,
    this.gender,
    this.bio,
    this.updateUnTimes,
    this.isVip,
    this.createdAt,
    this.updatedAt,
    this.roleCode,
    this.roleName,
    this.roleCategory,
    this.roleDescription,
    this.isActive,
    this.token,
    this.refreshToken,
    this.elderlyProfile,
    this.childProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class ElderlyProfile {
  final String? id;
  final String? userId;
  final String? chronicDiseases;
  final String? allergies;
  final String? bloodType;
  final double? height;
  final double? weight;
  final String? livingStatus;
  final String? address;
  final String? emergencyContact;
  final String? dietRestrictions;
  final String? medicalHistory;

  ElderlyProfile({
    this.id,
    this.userId,
    this.chronicDiseases,
    this.allergies,
    this.bloodType,
    this.height,
    this.weight,
    this.livingStatus,
    this.address,
    this.emergencyContact,
    this.dietRestrictions,
    this.medicalHistory,
  });

  factory ElderlyProfile.fromJson(Map<String, dynamic> json) =>
      _$ElderlyProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ElderlyProfileToJson(this);
}

@JsonSerializable()
class ChildProfile {
  final String? id;
  final String? userId;
  final String? guardianSettings;
  final String? checkinSettings;

  ChildProfile({
    this.id,
    this.userId,
    this.guardianSettings,
    this.checkinSettings,
  });

  factory ChildProfile.fromJson(Map<String, dynamic> json) =>
      _$ChildProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ChildProfileToJson(this);
}

@JsonSerializable()
class FamilyBinding {
  final String? id;
  final String? elderlyProfileId;
  final String? childProfileId;
  final String? relationType;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? elderlyName;
  final String? childName;
  final String? elderlyAvatar;
  final String? childAvatar;
  final String? elderlyPhone;
  final String? childPhone;
  final int? elderlyGender;
  final int? childGender;
  final String? elderlyBirthday;
  final String? childBirthday;
  final String? myRole;
  final String? elderlyToChildRelation;
  final String? elderlyUserId;
  final String? childUserId;

  // 老人档案详细信息
  final String? elderlyChronicDiseases;
  final String? elderlyAllergies;
  final String? elderlyBloodType;
  final double? elderlyHeight;
  final double? elderlyWeight;
  final String? elderlyLivingStatus;
  final String? elderlyAddress;
  final String? elderlyEmergencyContact;
  final String? elderlyDietRestrictions;
  final String? elderlyMedicalHistory;

  // 子女档案详细信息
  final String? childGuardianSettings;
  final String? childCheckinSettings;

  FamilyBinding({
    this.id,
    this.elderlyProfileId,
    this.childProfileId,
    this.relationType,
    this.elderlyToChildRelation,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.elderlyName,
    this.childName,
    this.elderlyAvatar,
    this.childAvatar,
    this.elderlyPhone,
    this.childPhone,
    this.elderlyGender,
    this.childGender,
    this.elderlyBirthday,
    this.childBirthday,
    this.myRole,
    this.elderlyUserId,
    this.childUserId,
    this.elderlyChronicDiseases,
    this.elderlyAllergies,
    this.elderlyBloodType,
    this.elderlyHeight,
    this.elderlyWeight,
    this.elderlyLivingStatus,
    this.elderlyAddress,
    this.elderlyEmergencyContact,
    this.elderlyDietRestrictions,
    this.elderlyMedicalHistory,
    this.childGuardianSettings,
    this.childCheckinSettings,
  });

  factory FamilyBinding.fromJson(Map<String, dynamic> json) =>
      _$FamilyBindingFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyBindingToJson(this);

  String getDisplayName(String myRole) {
    if (myRole == 'elderly') {
      return childName ?? '未知';
    } else {
      return elderlyName ?? '未知';
    }
  }

  String? getDisplayAvatar(String myRole) {
    if (myRole == 'elderly') {
      return childAvatar;
    } else {
      return elderlyAvatar;
    }
  }

  int? getDisplayGender(String myRole) {
    if (myRole == 'elderly') {
      return childGender;
    } else {
      return elderlyGender;
    }
  }

  String? getDisplayPhone(String myRole) {
    if (myRole == 'elderly') {
      return childPhone;
    } else {
      return elderlyPhone;
    }
  }

  String? getOtherUserId(String myRole) {
    if (myRole == 'elderly') {
      return childUserId;
    } else {
      return elderlyUserId;
    }
  }
}

String _idFromStringOrInt(dynamic value) {
  if (value is String) return value;
  if (value is int) return value.toString();
  return value.toString();
}
