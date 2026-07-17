class LoginResponse {
  final String accessToken;
  final String? refreshToken;
  final UserModel user;

  LoginResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] ?? json['token'] ?? '',
      refreshToken: json['refresh_token'],
      user: UserModel.fromJson(json['user'] ?? json),
    );
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String role;
  final String? organizationId;
  final String? status;
  final String? email;
  final String? kycStatus;
  final String? organizationStatus;
  final String? suspensionReason;
  final String? businessName;
  final int? smsBalance;
  final String? avatar;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.role,
    this.organizationId,
    this.status,
    this.email,
    this.kycStatus,
    this.organizationStatus,
    this.suspensionReason,
    this.businessName,
    this.smsBalance,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final org = json['organization'];
    return UserModel(
      id: json['id'] ?? json['uuid'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      organizationId: json['organization_id'],
      status: json['status'],
      email: json['email'],
      kycStatus: org is Map ? org['kyc_status'] : null,
      organizationStatus: org is Map ? org['status'] : null,
      suspensionReason: org is Map ? org['suspension_reason'] : null,
      businessName: org is Map ? org['business_name'] : null,
      smsBalance: org is Map ? (org['sms_balance'] is int ? org['sms_balance'] : (org['sms_balance'] != null ? int.tryParse(org['sms_balance'].toString()) : null)) : null,
      avatar: json['avatar']?.toString(),
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? role,
    String? organizationId,
    String? status,
    String? email,
    String? kycStatus,
    String? organizationStatus,
    String? suspensionReason,
    String? businessName,
    int? smsBalance,
    String? avatar,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      status: status ?? this.status,
      email: email ?? this.email,
      kycStatus: kycStatus ?? this.kycStatus,
      organizationStatus: organizationStatus ?? this.organizationStatus,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      businessName: businessName ?? this.businessName,
      smsBalance: smsBalance ?? this.smsBalance,
      avatar: avatar ?? this.avatar,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'phone': phone,
        'role': role,
        'organization_id': organizationId,
        'status': status,
        'email': email,
        'kyc_status': kycStatus,
        'organization_status': organizationStatus,
        'suspension_reason': suspensionReason,
        'business_name': businessName,
        'sms_balance': smsBalance,
        'avatar': avatar,
      };
}
