class ActivePackageModel {
  final int id;
  final String name;
  final String description;
  final int numberOfDays;
  final String roomType;
  final double price;
  final int quantity;

  final int pendingCount;
  final int confirmedCount;
  final int rejectedCount;
  final int availableCount;

  final String? countryName;

  ActivePackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.numberOfDays,
    required this.roomType,
    required this.price,
    required this.quantity,
    required this.pendingCount,
    required this.confirmedCount,
    required this.rejectedCount,
    required this.availableCount,
    this.countryName,
  });

  factory ActivePackageModel.fromJson(Map<String, dynamic> json) {
    final package = json['package'] as Map<String, dynamic>;
    final country = package['country'] as Map<String, dynamic>?;

    return ActivePackageModel(
      id: package['id'],
      name: package['name'] ?? '',
      description: package['description'] ?? '',
      numberOfDays: package['number_of_days'] ?? 0,
      roomType: package['room_type'] ?? '',
      price: double.parse(package['price'].toString()),
      quantity: package['quantity'] ?? 0,

      pendingCount: json['pending_count'] ?? 0,
      confirmedCount: json['confirmed_count'] ?? 0,
      rejectedCount: json['rejected_count'] ?? 0,
      availableCount: json['available_count'] ?? 0,

      countryName: country?['name'],
    );
  }

  ActivePackageModel copyWith({
    int? pendingCount,
    int? confirmedCount,
    int? rejectedCount,
    int? availableCount,
  }) {
    return ActivePackageModel(
      id: id,
      name: name,
      description: description,
      numberOfDays: numberOfDays,
      roomType: roomType,
      price: price,
      quantity: quantity,

      pendingCount: pendingCount ?? this.pendingCount,
      confirmedCount: confirmedCount ?? this.confirmedCount,
      rejectedCount: rejectedCount ?? this.rejectedCount,
      availableCount: availableCount ?? this.availableCount,

      countryName: countryName,
    );
  }
}
