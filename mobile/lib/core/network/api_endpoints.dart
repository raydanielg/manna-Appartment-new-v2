class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register-landlord';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh-token';
  static const String me = '/auth/me';

  // Landlord
  static const String landlordDashboard = '/landlord/dashboard';
  static const String properties = '/landlord/properties';
  static const String units = '/landlord/units';
  static const String tenants = '/landlord/tenants';
  static const String contracts = '/landlord/contracts';
  static const String payments = '/landlord/payments';
  static const String financeReport = '/landlord/finance/report';
  static const String smsBroadcast = '/landlord/sms/broadcast';
  static const String smsLogs = '/landlord/sms/logs';
  static const String subscriptions = '/landlord/subscriptions';
  static const String staff = '/landlord/staff';
  static const String kyc = '/landlord/kyc';
  static const String kycStatus = '/landlord/kyc/status';
  static const String maintenanceRequests = '/landlord/maintenance-requests';

  // Tenant
  static const String tenantDashboard = '/tenant/dashboard';
  static const String myUnit = '/tenant/my-unit';
  static const String myContract = '/tenant/my-contract';
  static const String myPayments = '/tenant/my-payments';
  static const String submitMaintenance = '/tenant/maintenance-requests';
  static const String myMaintenanceRequests = '/tenant/my-maintenance-requests';

  // Shared
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String changePassword = '/profile/change-password';
  static const String registerFcmToken = '/device-tokens';
}
