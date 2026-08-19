class PackageBookingModel {
  final int id;
  final int packageId;
  final String status;
  final String bookingDate;
  final int customerId;
  final String customerName;
  final String customerPhone;
  final String createdAt;

  PackageBookingModel({
    required this.id,
    required this.packageId,
    required this.status,
    required this.bookingDate,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.createdAt,
  });

  factory PackageBookingModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>? ?? {};
    return PackageBookingModel(
      id: json['id'],
      packageId: json['package_id'],
      status: json['status'] ?? 'pending',
      bookingDate: json['booking_date'] ?? '',
      customerId: customer['id'] ?? 0,
      customerName: customer['name'] ?? '',
      customerPhone: customer['phone'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
