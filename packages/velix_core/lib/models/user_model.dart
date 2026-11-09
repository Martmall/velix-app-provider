enum UserRole { user, partner, admin }

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final UserRole role;
  final bool isVerified;
  final String? licenseNumber;
  final String? businessName;
  final String? cacNumber;
  final String? cacDocumentUrl;
  final String? cacStatus; // 'pending', 'approved', 'rejected'
  final String? bankName;
  final String? accountNumber;
  final String? accountName;
  final bool isBankVerified;
  final double walletBalance;
  final DateTime? createdAt;
  /// Customers: driver's-licence check -- 'UNVERIFIED' | 'PENDING' | 'VERIFIED' | 'REJECTED'.
  final String? licenseVerificationStatus;
  /// Partners: 'pending' until an admin approves their documents, then 'active'.
  final String? providerStatus;

  bool get isApprovedPartner => providerStatus == 'active' || providerStatus == 'approved';

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.role,
    this.isVerified = false,
    this.licenseNumber,
    this.businessName,
    this.cacNumber,
    this.cacDocumentUrl,
    this.cacStatus,
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.isBankVerified = false,
    this.walletBalance = 0.0,
    this.createdAt,
    this.licenseVerificationStatus,
    this.providerStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] is Map ? json['provider'] as Map<String, dynamic> : null;
    final wallet = json['wallet'] is Map ? json['wallet'] as Map<String, dynamic> : null;

    final firstName = json['first_name'] ?? json['firstName'] ?? '';
    final lastName = json['last_name'] ?? json['lastName'] ?? '';
    String fullName = (json['fullName'] ?? json['full_name'] ?? json['name'] ?? json['display_name'] ?? '').toString();
    if (fullName.isEmpty && (firstName.isNotEmpty || lastName.isNotEmpty)) {
      fullName = '$firstName $lastName'.trim();
    }
    if (fullName.isEmpty) fullName = 'Velix User';

    final userType = (json['userType'] ?? json['user_type'] ?? json['role'] ?? 'CUSTOMER').toString().toUpperCase();
    UserRole parsedRole = UserRole.user;
    if (userType == 'ADMIN') {
      parsedRole = UserRole.admin;
    } else if (userType == 'PROVIDER' || userType == 'PARTNER' || userType == 'STAFF') {
      parsedRole = UserRole.partner;
    }

    final avatar = json['avatarUrl'] ?? json['avatar_url'] ?? json['avatar'] ?? json['profile_image'];
    final verified = json['email_verified'] ?? json['isVerified'] ?? (json['emailVerifiedAt'] != null);

    final double balance = (json['walletBalance'] ?? json['wallet_balance'] ?? wallet?['balance'] as num?)?.toDouble() ?? 0.0;
    final business = json['businessName'] ?? provider?['companyName'];
    final providerStatus = (json['provider_status'] ?? provider?['status'])?.toString().toLowerCase();

    return UserModel(
      id: (json['id'] ?? '').toString(),
      fullName: fullName,
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? json['phone_number'] ?? json['contact_number'] ?? '').toString(),
      avatarUrl: avatar?.toString(),
      role: parsedRole,
      isVerified: verified is bool ? verified : false,
      licenseNumber: json['licenseNumber'] ?? json['license_number'] ?? json['driver_license'],
      businessName: business?.toString(),
      cacNumber: json['cacNumber'] ?? json['cac_number'] ?? provider?['cac_number'],
      cacDocumentUrl: json['cacDocumentUrl'] ?? json['cac_document_url'] ?? provider?['cac_document_url'],
      cacStatus: providerStatus,
      bankName: (json['bankName'] ?? provider?['bankName'])?.toString(),
      accountNumber: (json['accountNumber'] ?? provider?['accountNumber'])?.toString(),
      accountName: (json['accountName'] ?? provider?['accountName'])?.toString(),
      isBankVerified: json['isBankVerified'] ?? json['is_bank_verified'] ?? false,
      walletBalance: balance,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
      licenseVerificationStatus: json['licenseVerificationStatus']?.toString(),
      providerStatus: providerStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'phone_number': phone,
      'avatarUrl': avatarUrl,
      'avatar_url': avatarUrl,
      'role': role == UserRole.admin ? 'admin' : (role == UserRole.partner ? 'partner' : 'user'),
      'isVerified': isVerified,
      'is_verified': isVerified,
      'licenseNumber': licenseNumber,
      'businessName': businessName,
      'cacNumber': cacNumber,
      'cacDocumentUrl': cacDocumentUrl,
      'cacStatus': cacStatus,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'isBankVerified': isBankVerified,
      'walletBalance': walletBalance,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    bool? isVerified,
    String? licenseNumber,
    String? businessName,
    String? cacNumber,
    String? cacDocumentUrl,
    String? cacStatus,
    String? bankName,
    String? accountNumber,
    String? accountName,
    bool? isBankVerified,
    double? walletBalance,
    DateTime? createdAt,
    String? licenseVerificationStatus,
    String? providerStatus,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      businessName: businessName ?? this.businessName,
      cacNumber: cacNumber ?? this.cacNumber,
      cacDocumentUrl: cacDocumentUrl ?? this.cacDocumentUrl,
      cacStatus: cacStatus ?? this.cacStatus,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      isBankVerified: isBankVerified ?? this.isBankVerified,
      walletBalance: walletBalance ?? this.walletBalance,
      createdAt: createdAt ?? this.createdAt,
      licenseVerificationStatus: licenseVerificationStatus ?? this.licenseVerificationStatus,
      providerStatus: providerStatus ?? this.providerStatus,
    );
  }
}
