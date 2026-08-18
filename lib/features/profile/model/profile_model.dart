class ProfileModel {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? email;
  final String phoneNumber;
  final double credit;
  final String? profileImage;
  final String role;

  ProfileModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.phoneNumber,
    required this.credit,
    this.profileImage,
    required this.role,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'],
      phoneNumber: json['phone_number'] ?? '',
      credit: double.tryParse(json['credit'].toString()) ?? 0,
      profileImage: json['profile_image'],
      role: json['role'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
