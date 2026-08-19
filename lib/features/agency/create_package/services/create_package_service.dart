import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/agency/create_package/models/package_day_model.dart';

class CreatePackageService {
  final ApiService api = ApiService();

  Future createPackage({
    required String name,

    required int countryId,

    required String description,

    required int quantity,

    required double price,

    required List<PackageDayModel> days,
  }) async {
    final response = await api.post(
      "/packages",
      data: {
        "name": name,
        "country_id": countryId,
        "description": description,
        "quantity": quantity,
        "price": price,
        "days": days.map((e) => e.toJson()).toList(),
      },
    );

    print("CREATE PACKAGE FINISHED");
    print(response);
  }
}
