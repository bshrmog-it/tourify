class PackageHintModel {
  final double totalCost;

  final double hotelTotalCost;

  final double flightTotalCost;

  final double costWithoutProfit;

  final double hotelCostPerPackage;

  final double flightCostPerPackage;

  final double suggestedMinPrice;

  PackageHintModel({
    required this.totalCost,

    required this.hotelTotalCost,

    required this.flightTotalCost,

    required this.costWithoutProfit,

    required this.hotelCostPerPackage,

    required this.flightCostPerPackage,

    required this.suggestedMinPrice,
  });

  factory PackageHintModel.fromJson(Map<String, dynamic> json) {
    return PackageHintModel(
      totalCost: double.parse(json["total_cost"].toString()),

      hotelTotalCost: double.parse(json["hotel_total_cost"].toString()),

      flightTotalCost: double.parse(json["flight_total_cost"].toString()),

      costWithoutProfit: double.parse(json["costWithoutProfit"].toString()),

      hotelCostPerPackage: double.parse(
        json["hotel_cost_per_package"].toString(),
      ),

      flightCostPerPackage: double.parse(
        json["flight_cost_per_package"].toString(),
      ),

      suggestedMinPrice: double.parse(json["suggested_min_price"].toString()),
    );
  }
}
