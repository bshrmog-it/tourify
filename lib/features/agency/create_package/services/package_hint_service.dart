import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/features/agency/create_package/models/package_hint_model.dart';
import 'package:tourify/features/agency/create_package/models/package_day_model.dart';

class PackageHintService {
  final ApiService api = ApiService();

  Future<PackageHintModel> getHint({
    required int quantity,

    required List<PackageDayModel> days,
  }) async {
    final response = await api.post(
      "/package-hint",

      data: {
        "quantity": quantity,

        "days": days.map((e) => e.toJson()).toList(),
      },
    );

    return PackageHintModel.fromJson(response["data"]);
  }
}
