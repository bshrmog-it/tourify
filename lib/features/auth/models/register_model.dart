import 'dart:io';
import 'package:dio/dio.dart';

class RegisterModel {
  final String role; // 'user' or 'agency'
  final String phoneNumber;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String password;
  final String? dateOfBirth;
  final File? profileImage;
  final File? idCardImage;

  // Agency only
  final String? agencyName;
  final String? agencyDescription;
  final String? agencyLandlinePhone;
  final String? agencyAddress;
  final File? agencyImage;

  RegisterModel({
    required this.role,
    required this.phoneNumber,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.password,
    this.dateOfBirth,
    this.profileImage,
    this.idCardImage,
    this.agencyName,
    this.agencyDescription,
    this.agencyLandlinePhone,
    this.agencyAddress,
    this.agencyImage,
  });

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'phone_number': phoneNumber,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'password_confirmation': password,
      'role': role,
    };

    if (dateOfBirth != null) map['date_of_birth'] = dateOfBirth;

    if (profileImage != null) {
      map['profile_image'] = await MultipartFile.fromFile(profileImage!.path);
    }
    if (idCardImage != null) {
      map['id_card_image'] = await MultipartFile.fromFile(idCardImage!.path);
    }

    if (role == 'agency') {
      if (agencyName != null) map['agency_name'] = agencyName;
      if (agencyDescription != null)
        map['agency_description'] = agencyDescription;
      if (agencyLandlinePhone != null)
        map['agency_landline_phone'] = agencyLandlinePhone;
      if (agencyAddress != null) map['agency_address'] = agencyAddress;
      if (agencyImage != null) {
        map['agency_image'] = await MultipartFile.fromFile(agencyImage!.path);
      }
    }

    return FormData.fromMap(map);
  }
}
