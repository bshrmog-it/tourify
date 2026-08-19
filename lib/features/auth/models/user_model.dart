class UserModel {
  final int? id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? role;
  final String? profileImage;
  final String? status; // approved / pending ...

  UserModel({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.role,
    this.profileImage,
    this.status,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json, {
    String? roleFallback,
  }) {
    String? statusValue;
    final rawStatus = json['status'];
    if (rawStatus is String) {
      statusValue = rawStatus;
    } else if (rawStatus is Map) {
      statusValue = rawStatus['key']?.toString();
    }

    return UserModel(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      role: json['role']?.toString() ?? roleFallback,
      profileImage: json['profile_image'],
      status: statusValue,
    );
  }

  String get fullName => "${firstName ?? ''} ${lastName ?? ''}".trim();
}
