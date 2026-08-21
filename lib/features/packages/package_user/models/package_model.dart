// helper مشترك لاستخراج رابط الصورة الرئيسية من مصفوفة صور جاهزة الروابط
// (لاحظ: هون الـ API برجع "url" كامل جاهز، مش "path" متل باقي الأقسام)
String? _mainUrl(List? images) {
  if (images == null || images.isEmpty) return null;
  final main = images.firstWhere(
    (img) => img['is_main'] == 1 || img['is_main'] == true,
    orElse: () => images.first,
  );
  return main['url'];
}

class PackageAgencyPreview {
  final int id;
  final String name;
  final String? description;
  final String? landlinePhone;
  final String? address;
  final String? mainImageUrl;

  PackageAgencyPreview({
    required this.id,
    required this.name,
    this.description,
    this.landlinePhone,
    this.address,
    this.mainImageUrl,
  });

  factory PackageAgencyPreview.fromJson(Map<String, dynamic> json) {
    return PackageAgencyPreview(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      landlinePhone: json['landline_phone'],
      address: json['address'],
      mainImageUrl: _mainUrl(json['images']),
    );
  }
}

class PackageCountryPreview {
  final int id;
  final String name;
  final String? flagUrl;

  PackageCountryPreview({required this.id, required this.name, this.flagUrl});

  factory PackageCountryPreview.fromJson(Map<String, dynamic> json) {
    return PackageCountryPreview(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      flagUrl: json['flag'],
    );
  }
}

class PackagePlacePreview {
  final int id;
  final String name;
  final String? description;
  final String? mainImageUrl;

  PackagePlacePreview(
      {required this.id, required this.name, this.description, this.mainImageUrl});

  factory PackagePlacePreview.fromJson(Map<String, dynamic> json) {
    return PackagePlacePreview(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      mainImageUrl: _mainUrl(json['images']),
    );
  }
}

class PackageHotelPreview {
  final int id;
  final String name;
  final String? phone;
  final String? description;
  final String? mainImageUrl;

  PackageHotelPreview(
      {required this.id,
      required this.name,
      this.phone,
      this.description,
      this.mainImageUrl});

  factory PackageHotelPreview.fromJson(Map<String, dynamic> json) {
    return PackageHotelPreview(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      description: json['description'],
      mainImageUrl: _mainUrl(json['images']),
    );
  }
}

class PackageRestaurantPreview {
  final int id;
  final String name;
  final String? phone;
  final String? description;
  final String? mainImageUrl;

  PackageRestaurantPreview(
      {required this.id,
      required this.name,
      this.phone,
      this.description,
      this.mainImageUrl});

  factory PackageRestaurantPreview.fromJson(Map<String, dynamic> json) {
    return PackageRestaurantPreview(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      description: json['description'],
      mainImageUrl: _mainUrl(json['images']),
    );
  }
}

class PackageFlightPreview {
  final int id;
  final String departure;
  final String arrival;

  PackageFlightPreview(
      {required this.id, required this.departure, required this.arrival});

  factory PackageFlightPreview.fromJson(Map<String, dynamic> json) {
    return PackageFlightPreview(
      id: json['id'],
      departure: json['departure'] ?? '',
      arrival: json['arrival'] ?? '',
    );
  }
}

class PackageDay {
  final String date;
  final PackagePlacePreview? place;
  final PackageHotelPreview? hotel;
  final PackageRestaurantPreview? restaurant;
  final PackageFlightPreview? flight;

  PackageDay({required this.date, this.place, this.hotel, this.restaurant, this.flight});

  factory PackageDay.fromJson(Map<String, dynamic> json) {
    return PackageDay(
      date: json['date'] ?? '',
      place:
          json['place'] != null ? PackagePlacePreview.fromJson(json['place']) : null,
      hotel:
          json['hotel'] != null ? PackageHotelPreview.fromJson(json['hotel']) : null,
      restaurant: json['restaurant'] != null
          ? PackageRestaurantPreview.fromJson(json['restaurant'])
          : null,
      flight:
          json['flight'] != null ? PackageFlightPreview.fromJson(json['flight']) : null,
    );
  }
}

class PackageModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final int numberOfDays;
  final PackageAgencyPreview agency;
  final PackageCountryPreview country;
  final List<PackageDay> days;

  PackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.numberOfDays,
    required this.agency,
    required this.country,
    required this.days,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      quantity: json['quantity'] ?? 0,
      numberOfDays: json['number_of_days'] ?? 0,
      agency: PackageAgencyPreview.fromJson(json['agency'] ?? {}),
      country: PackageCountryPreview.fromJson(json['country'] ?? {}),
      days: ((json['days'] as List?) ?? []).map((e) => PackageDay.fromJson(e)).toList(),
    );
  }

  // الصورة الرئيسية المعروضة بالكارد: أول صورة مكان بأول يوم، وإلا صورة الوكالة
  String? get coverImageUrl {
    for (final day in days) {
      if (day.place?.mainImageUrl != null) return day.place!.mainImageUrl;
    }
    return agency.mainImageUrl;
  }
}
