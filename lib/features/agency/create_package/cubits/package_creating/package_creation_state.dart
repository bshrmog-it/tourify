import 'package:tourify/features/agency/create_package/models/city_model.dart';
import 'package:tourify/features/agency/create_package/models/country_model.dart';
import 'package:tourify/features/agency/create_package/models/package_day_data.dart';
import 'package:tourify/features/agency/create_package/models/package_hint_model.dart';

enum PackageCreationStatus {
  initial,
  loadingHint,
  hintReady,
  creating,
  success,
  error,
}

class PackageCreationState {
  final PackageCreationStatus status;

  // ================================================================
  // BASIC INFO
  // ================================================================

  final String name;
  final String description;
  final int quantity;

  // ================================================================
  // ORIGIN
  // ================================================================

  final CountryModel? originCountry;
  final CityModel? originCity;

  // ================================================================
  // DESTINATION
  // ================================================================

  final CountryModel? country;

  // ================================================================
  // TRIP DATES
  // ================================================================

  final DateTime? startDate;
  final DateTime? endDate;

  /// Inclusive number of days.
  ///
  /// Example:
  /// 20/8 -> 24/8 = 5 days
  final int tripDays;

  // ================================================================
  // FLIGHTS
  // ================================================================

  /// true = package includes flights
  /// false = package does not include flights
  final bool withFlight;

  // ================================================================
  // DAYS
  // ================================================================

  final List<PackageDayData> days;

  /// 0 = Overview
  /// 1 = Day 1
  /// 2 = Day 2
  final int selectedTabIndex;

  // ================================================================
  // HINT / CREATE
  // ================================================================

  final PackageHintModel? hint;
  final double? finalPrice;
  final String? errorMessage;

  const PackageCreationState({
    this.status = PackageCreationStatus.initial,

    this.name = '',
    this.description = '',
    this.quantity = 1,

    this.originCountry,
    this.originCity,

    this.country,

    this.startDate,
    this.endDate,
    this.tripDays = 0,

    this.withFlight = false,

    this.days = const [],
    this.selectedTabIndex = 0,

    this.hint,
    this.finalPrice,
    this.errorMessage,
  });

  PackageCreationState copyWith({
    PackageCreationStatus? status,

    String? name,
    String? description,
    int? quantity,

    CountryModel? originCountry,
    bool clearOriginCountry = false,

    CityModel? originCity,
    bool clearOriginCity = false,

    CountryModel? country,
    bool clearCountry = false,

    DateTime? startDate,
    bool clearStartDate = false,

    DateTime? endDate,
    bool clearEndDate = false,

    int? tripDays,

    bool? withFlight,

    List<PackageDayData>? days,

    int? selectedTabIndex,

    PackageHintModel? hint,
    bool clearHint = false,

    double? finalPrice,

    String? errorMessage,
    bool clearError = false,
  }) {
    return PackageCreationState(
      status: status ?? this.status,

      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,

      originCountry: clearOriginCountry
          ? null
          : (originCountry ?? this.originCountry),

      originCity: clearOriginCity ? null : (originCity ?? this.originCity),

      country: clearCountry ? null : (country ?? this.country),

      startDate: clearStartDate ? null : (startDate ?? this.startDate),

      endDate: clearEndDate ? null : (endDate ?? this.endDate),

      tripDays: tripDays ?? this.tripDays,

      withFlight: withFlight ?? this.withFlight,

      days: days ?? this.days,

      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,

      hint: clearHint ? null : (hint ?? this.hint),

      finalPrice: finalPrice ?? this.finalPrice,

      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
