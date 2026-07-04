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

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.role,
    this.organizationId,
    this.status,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['uuid'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      organizationId: json['organization_id'],
      status: json['status'],
      email: json['email'],
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
      };
}
