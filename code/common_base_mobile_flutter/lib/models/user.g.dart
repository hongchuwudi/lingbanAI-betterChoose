// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: _idFromStringOrInt(json['id']),
  nickname: json['nickname'] as String,
  username: json['username'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  avatar: json['avatar'] as String?,
  birthday: json['birthday'] as String?,
  gender: (json['gender'] as num?)?.toInt(),
  bio: json['bio'] as String?,
  updateUnTimes: (json['updateUnTimes'] as num?)?.toInt(),
  isVip: json['isVip'] as bool?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  roleCode: json['roleCode'] as String?,
  roleName: json['roleName'] as String?,
  roleCategory: json['roleCategory'] as String?,
  roleDescription: json['roleDescription'] as String?,
  isActive: json['isActive'] as bool?,
  token: json['token'] as String?,
  refreshToken: json['refreshToken'] as String?,
  elderlyProfile: json['elderlyProfile'] == null
      ? null
      : ElderlyProfile.fromJson(json['elderlyProfile'] as Map<String, dynamic>),
  childProfile: json['childProfile'] == null
      ? null
      : ChildProfile.fromJson(json['childProfile'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'nickname': instance.nickname,
  'username': instance.username,
  'email': instance.email,
  'phone': instance.phone,
  'avatar': instance.avatar,
  'birthday': instance.birthday,
  'gender': instance.gender,
  'bio': instance.bio,
  'updateUnTimes': instance.updateUnTimes,
  'isVip': instance.isVip,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'roleCode': instance.roleCode,
  'roleName': instance.roleName,
  'roleCategory': instance.roleCategory,
  'roleDescription': instance.roleDescription,
  'isActive': instance.isActive,
  'token': instance.token,
  'refreshToken': instance.refreshToken,
  'elderlyProfile': instance.elderlyProfile?.toJson(),
  'childProfile': instance.childProfile?.toJson(),
};

ElderlyProfile _$ElderlyProfileFromJson(Map<String, dynamic> json) =>
    ElderlyProfile(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      chronicDiseases: json['chronicDiseases'] as String?,
      allergies: json['allergies'] as String?,
      bloodType: json['bloodType'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      livingStatus: json['livingStatus'] as String?,
      address: json['address'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      dietRestrictions: json['dietRestrictions'] as String?,
      medicalHistory: json['medicalHistory'] as String?,
    );

Map<String, dynamic> _$ElderlyProfileToJson(ElderlyProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'chronicDiseases': instance.chronicDiseases,
      'allergies': instance.allergies,
      'bloodType': instance.bloodType,
      'height': instance.height,
      'weight': instance.weight,
      'livingStatus': instance.livingStatus,
      'address': instance.address,
      'emergencyContact': instance.emergencyContact,
      'dietRestrictions': instance.dietRestrictions,
      'medicalHistory': instance.medicalHistory,
    };

ChildProfile _$ChildProfileFromJson(Map<String, dynamic> json) => ChildProfile(
  id: json['id'] as String?,
  userId: json['userId'] as String?,
  guardianSettings: json['guardianSettings'] as String?,
  checkinSettings: json['checkinSettings'] as String?,
);

Map<String, dynamic> _$ChildProfileToJson(ChildProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'guardianSettings': instance.guardianSettings,
      'checkinSettings': instance.checkinSettings,
    };

FamilyBinding _$FamilyBindingFromJson(Map<String, dynamic> json) =>
    FamilyBinding(
      id: json['id'] as String?,
      elderlyProfileId: json['elderlyProfileId'] as String?,
      childProfileId: json['childProfileId'] as String?,
      relationType: json['relationType'] as String?,
      elderlyToChildRelation: json['elderlyToChildRelation'] as String?,
      status: (json['status'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      elderlyName: json['elderlyName'] as String?,
      childName: json['childName'] as String?,
      elderlyAvatar: json['elderlyAvatar'] as String?,
      childAvatar: json['childAvatar'] as String?,
      elderlyPhone: json['elderlyPhone'] as String?,
      childPhone: json['childPhone'] as String?,
      elderlyGender: (json['elderlyGender'] as num?)?.toInt(),
      childGender: (json['childGender'] as num?)?.toInt(),
      elderlyBirthday: json['elderlyBirthday'] as String?,
      childBirthday: json['childBirthday'] as String?,
      myRole: json['myRole'] as String?,
      elderlyChronicDiseases: json['elderlyChronicDiseases'] as String?,
      elderlyAllergies: json['elderlyAllergies'] as String?,
      elderlyBloodType: json['elderlyBloodType'] as String?,
      elderlyHeight: (json['elderlyHeight'] as num?)?.toDouble(),
      elderlyWeight: (json['elderlyWeight'] as num?)?.toDouble(),
      elderlyLivingStatus: json['elderlyLivingStatus'] as String?,
      elderlyAddress: json['elderlyAddress'] as String?,
      elderlyEmergencyContact: json['elderlyEmergencyContact'] as String?,
      elderlyDietRestrictions: json['elderlyDietRestrictions'] as String?,
      elderlyMedicalHistory: json['elderlyMedicalHistory'] as String?,
      childGuardianSettings: json['childGuardianSettings'] as String?,
      childCheckinSettings: json['childCheckinSettings'] as String?,
    );

Map<String, dynamic> _$FamilyBindingToJson(FamilyBinding instance) =>
    <String, dynamic>{
      'id': instance.id,
      'elderlyProfileId': instance.elderlyProfileId,
      'childProfileId': instance.childProfileId,
      'relationType': instance.relationType,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'elderlyName': instance.elderlyName,
      'childName': instance.childName,
      'elderlyAvatar': instance.elderlyAvatar,
      'childAvatar': instance.childAvatar,
      'elderlyPhone': instance.elderlyPhone,
      'childPhone': instance.childPhone,
      'elderlyGender': instance.elderlyGender,
      'childGender': instance.childGender,
      'elderlyBirthday': instance.elderlyBirthday,
      'childBirthday': instance.childBirthday,
      'myRole': instance.myRole,
      'elderlyToChildRelation': instance.elderlyToChildRelation,
      'elderlyChronicDiseases': instance.elderlyChronicDiseases,
      'elderlyAllergies': instance.elderlyAllergies,
      'elderlyBloodType': instance.elderlyBloodType,
      'elderlyHeight': instance.elderlyHeight,
      'elderlyWeight': instance.elderlyWeight,
      'elderlyLivingStatus': instance.elderlyLivingStatus,
      'elderlyAddress': instance.elderlyAddress,
      'elderlyEmergencyContact': instance.elderlyEmergencyContact,
      'elderlyDietRestrictions': instance.elderlyDietRestrictions,
      'elderlyMedicalHistory': instance.elderlyMedicalHistory,
      'childGuardianSettings': instance.childGuardianSettings,
      'childCheckinSettings': instance.childCheckinSettings,
    };
