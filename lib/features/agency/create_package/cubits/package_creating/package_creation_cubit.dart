import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tourify/features/agency/create_package/cubits/package_creating/package_creation_state.dart';
import 'package:tourify/features/agency/create_package/models/city_model.dart';
import 'package:tourify/features/agency/create_package/models/country_model.dart';
import 'package:tourify/features/agency/create_package/models/flight_model.dart';
import 'package:tourify/features/agency/create_package/models/hotel_model.dart';
import 'package:tourify/features/agency/create_package/models/package_day_data.dart';
import 'package:tourify/features/agency/create_package/models/place_model.dart';
import 'package:tourify/features/agency/create_package/models/resturent_model.dart';
import 'package:tourify/features/agency/create_package/services/create_package_service.dart';
import 'package:tourify/features/agency/create_package/services/package_hint_service.dart';

class PackageCreationCubit extends Cubit<PackageCreationState> {
  PackageCreationCubit() : super(const PackageCreationState());

  final PackageHintService _hintService = PackageHintService();
  final CreatePackageService _createService = CreatePackageService();

  // ================================================================
  // BASIC INFO
  // ================================================================

  void setBasicInfo({String? name, String? description, int? quantity}) {
    emit(
      state.copyWith(
        name: name ?? state.name,
        description: description ?? state.description,
        quantity: quantity ?? state.quantity,
        status: PackageCreationStatus.initial,
        clearError: true,
      ),
    );
  }

  // ================================================================
  // COUNTRY
  // ================================================================

  // ================================================================
  // ORIGIN
  // ================================================================

  void selectOriginCountry(CountryModel country) {
    emit(
      state.copyWith(
        originCountry: country,
        clearOriginCity: true,

        clearHint: true,
        status: PackageCreationStatus.initial,
        clearError: true,
      ),
    );
  }

  void selectOriginCity(CityModel city) {
    emit(
      state.copyWith(
        originCity: city,

        // إذا تغير مكان الانطلاق
        // الرحلات القديمة لم تعد صالحة.
        days: const [],
        selectedTabIndex: 0,

        clearHint: true,
        status: PackageCreationStatus.initial,
        clearError: true,
      ),
    );
  }

  // ================================================================
  // DESTINATION COUNTRY
  // ================================================================

  void selectCountry(CountryModel country) {
    emit(
      state.copyWith(
        country: country,

        // الدولة السياحية تغيرت
        // لذلك الأيام والرحلات القديمة لم تعد صالحة.
        days: const [],
        selectedTabIndex: 0,

        clearHint: true,
        status: PackageCreationStatus.initial,
        clearError: true,
      ),
    );
  }

  // ================================================================
  // TRIP DATES
  // ================================================================

  void setTripDates({required DateTime startDate, required DateTime endDate}) {
    if (endDate.isBefore(startDate)) {
      return;
    }

    final tripDays = endDate.difference(startDate).inDays + 1;

    final country = state.country;

    if (country == null || country.cities.isEmpty) {
      emit(
        state.copyWith(
          startDate: startDate,
          endDate: endDate,
          tripDays: tripDays,
          days: const [],
          selectedTabIndex: 0,
          clearHint: true,
          status: PackageCreationStatus.initial,
          clearError: true,
        ),
      );

      return;
    }

    final defaultCityId = country.cities.first.id;

    final days = List.generate(tripDays, (index) {
      final date = startDate.add(Duration(days: index));

      return PackageDayData(
        dayNumber: index + 1,
        date: _formatDate(date),
        cityId: defaultCityId,
      );
    });

    emit(
      state.copyWith(
        startDate: startDate,
        endDate: endDate,
        tripDays: tripDays,
        days: days,
        selectedTabIndex: 0,
        clearHint: true,
        status: PackageCreationStatus.initial,
        clearError: true,
      ),
    );
  }
  // ================================================================
  // FLIGHT OPTION
  // ================================================================

  void setWithFlight(bool value) {
    List<PackageDayData> updatedDays = [...state.days];

    if (!value) {
      // Remove all flights if user disables flights.
      updatedDays = updatedDays.map((day) {
        day.flight = null;
        day.flightId = null;
        return day;
      }).toList();
    }

    emit(
      state.copyWith(
        withFlight: value,
        days: updatedDays,
        clearHint: true,
        status: PackageCreationStatus.initial,
        clearError: true,
      ),
    );
  }

  // ================================================================
  // CREATE ALL DAYS
  // ================================================================

  /// Called from Overview when user presses NEXT.
  ///
  /// Creates exactly the number of days calculated from
  /// startDate -> endDate.
  ///
  /// Example:
  /// 20/8 -> 24/8
  ///
  /// Creates:
  /// Day 1 = 20/8
  /// Day 2 = 21/8
  /// Day 3 = 22/8
  /// Day 4 = 23/8
  /// Day 5 = 24/8
  void startCreatingDays() {
    final country = state.country;

    if (country == null) {
      emit(
        state.copyWith(
          status: PackageCreationStatus.error,
          errorMessage: 'Please select a country first',
        ),
      );
      return;
    }

    if (state.startDate == null || state.endDate == null) {
      emit(
        state.copyWith(
          status: PackageCreationStatus.error,
          errorMessage: 'Please select start and end dates',
        ),
      );
      return;
    }

    if (state.days.length != state.tripDays) {
      emit(
        state.copyWith(
          status: PackageCreationStatus.error,
          errorMessage: 'The selected dates are not configured correctly',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedTabIndex: 1,
        status: PackageCreationStatus.initial,
        clearError: true,
      ),
    );
  }

  // ================================================================
  // CITY
  // ================================================================

  void setDayCity(int index, int cityId) {
    if (index < 0 || index >= state.days.length) {
      return;
    }

    final updatedDays = [...state.days];
    final day = updatedDays[index];

    // City changed => everything related to the old city is invalid.
    day.cityId = cityId;

    day.hotel = null;
    day.hotelId = null;
    day.roomType = null;

    day.place = null;
    day.placeId = null;

    day.restaurant = null;
    day.restaurantId = null;

    day.flight = null;
    day.flightId = null;

    emit(
      state.copyWith(
        days: updatedDays,
        status: PackageCreationStatus.initial,
        clearHint: true,
        clearError: true,
      ),
    );
  }

  // ================================================================
  // HOTEL
  // ================================================================

  void setDayHotel(int index, HotelModel hotel, {String? roomType}) {
    if (index < 0 || index >= state.days.length) {
      return;
    }

    final updatedDays = [...state.days];

    final selectedRoomType =
        roomType ?? (hotel.roomTypes.isNotEmpty ? hotel.roomTypes.first : null);

    // Set hotel + room type for the selected day
    updatedDays[index].hotel = hotel;
    updatedDays[index].hotelId = hotel.id;
    updatedDays[index].roomType = selectedRoomType;

    // ============================================================
    // IMPORTANT:
    // Use the FIRST day's room type for ALL days
    // ============================================================

    if (selectedRoomType != null) {
      for (int i = 0; i < updatedDays.length; i++) {
        updatedDays[i].roomType = selectedRoomType;
      }
    }

    emit(
      state.copyWith(
        days: updatedDays,
        status: PackageCreationStatus.initial,
        clearHint: true,
        clearError: true,
      ),
    );
  }

  // ================================================================
  // PLACE
  // ================================================================

  void setDayPlace(int index, PlaceModel place) {
    if (index < 0 || index >= state.days.length) {
      return;
    }

    final updatedDays = [...state.days];

    updatedDays[index].place = place;
    updatedDays[index].placeId = place.id;

    emit(
      state.copyWith(
        days: updatedDays,
        status: PackageCreationStatus.initial,
        clearHint: true,
        clearError: true,
      ),
    );
  }

  // ================================================================
  // RESTAURANT
  // ================================================================

  void setDayRestaurant(int index, RestaurantModel restaurant) {
    if (index < 0 || index >= state.days.length) {
      return;
    }

    final updatedDays = [...state.days];

    updatedDays[index].restaurant = restaurant;
    updatedDays[index].restaurantId = restaurant.id;

    emit(
      state.copyWith(
        days: updatedDays,
        status: PackageCreationStatus.initial,
        clearHint: true,
        clearError: true,
      ),
    );
  }

  // ================================================================
  // FLIGHT
  // ================================================================

  void setDayFlight(
    int index,
    FlightModel flight,
    FlightScheduleModel schedule,
  ) {
    if (index < 0 || index >= state.days.length) {
      return;
    }

    final updatedDays = [...state.days];

    updatedDays[index].flight = flight;
    updatedDays[index].flightId = flight.id;
    updatedDays[index].flightSchedule = schedule; // 👈 جديد

    emit(
      state.copyWith(
        days: updatedDays,
        status: PackageCreationStatus.initial,
        clearHint: true,
        clearError: true,
      ),
    );
  }

  void removeDayFlight(int index) {
    if (index < 0 || index >= state.days.length) {
      return;
    }

    final updatedDays = [...state.days];

    updatedDays[index].flight = null;
    updatedDays[index].flightId = null;
    updatedDays[index].flightSchedule = null; // 👈 جديد

    emit(
      state.copyWith(
        days: updatedDays,
        status: PackageCreationStatus.initial,
        clearHint: true,
        clearError: true,
      ),
    );
  }

  // ================================================================
  // VALIDATION
  // ================================================================

  bool get isReadyForHint {
    if (state.originCountry == null) {
      return false;
    }

    if (state.originCity == null) {
      return false;
    }

    if (state.country == null) {
      return false;
    }

    if (state.startDate == null || state.endDate == null) {
      return false;
    }

    // لازم عدد الأيام يطابق الفترة المحددة.
    if (state.days.length != state.tripDays) {
      return false;
    }

    // كل يوم لازم يكون مكتمل.
    for (final day in state.days) {
      if (day.hotel == null || day.place == null || day.restaurant == null) {
        return false;
      }
    }

    // إذا الطيران مفعّل،
    // فقط أول يوم وآخر يوم يحتاجان Flight.
    if (state.withFlight) {
      if (state.days.isEmpty) {
        return false;
      }

      if (state.days.first.flight == null) {
        return false;
      }

      if (state.days.last.flight == null) {
        return false;
      }
    }

    return true;
  }

  // ================================================================
  // HINT
  // ================================================================

  Future<void> fetchHint() async {
    if (!isReadyForHint) {
      emit(
        state.copyWith(
          status: PackageCreationStatus.error,
          errorMessage: _validationMessage(),
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        status: PackageCreationStatus.loadingHint,
        clearError: true,
      ),
    );

    try {
      final dayModels = state.days
          .map((day) => day.toPackageDayModel())
          .toList();

      final hint = await _hintService.getHint(
        quantity: state.quantity,
        days: dayModels,
      );

      emit(
        state.copyWith(
          status: PackageCreationStatus.hintReady,
          hint: hint,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PackageCreationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ================================================================
  // BACK TO EDIT
  // ================================================================

  void backToEdit() {
    emit(
      state.copyWith(
        status: PackageCreationStatus.initial,
        clearHint: true,
        clearError: true,
      ),
    );
  }

  // ================================================================
  // CREATE PACKAGE
  // ================================================================

  Future<void> confirmAndCreate(double pricePerPerson) async {
    print('================ CREATE PACKAGE ================');

    print('Country: ${state.country?.name}');
    print('Start date: ${state.startDate}');
    print('End date: ${state.endDate}');
    print('Trip days: ${state.tripDays}');
    print('Actual days: ${state.days.length}');
    print('With flight: ${state.withFlight}');
    print('Price per person: $pricePerPerson');

    for (int i = 0; i < state.days.length; i++) {
      final day = state.days[i];

      print('---------- DAY ${i + 1} ----------');
      print('Date: ${day.date}');
      print('City ID: ${day.cityId}');
      print('Hotel: ${day.hotel?.name}');
      print('Hotel ID: ${day.hotelId}');
      print('Room type: ${day.roomType}');
      print('Place: ${day.place?.name}');
      print('Place ID: ${day.placeId}');
      print('Restaurant: ${day.restaurant?.name}');
      print('Restaurant ID: ${day.restaurantId}');
      print('Flight: ${day.flight?.fromCity} -> ${day.flight?.toCity}');
      print('Flight ID: ${day.flight?.id}');
    }

    print('==============================================');

    // ------------------------------------------------
    // VALIDATION
    // ------------------------------------------------

    if (!isReadyForHint) {
      final error = _validationMessage();

      print('❌ CREATE BLOCKED');
      print('❌ ERROR: $error');

      emit(
        state.copyWith(
          status: PackageCreationStatus.error,
          errorMessage: error,
        ),
      );

      return;
    }

    print('✅ Validation passed');
    print('🚀 Sending package to API...');

    emit(
      state.copyWith(
        status: PackageCreationStatus.creating,
        finalPrice: pricePerPerson,
        clearError: true,
      ),
    );

    try {
      final dayModels = state.days
          .map((day) => day.toPackageDayModel())
          .toList();

      print('📦 Day models:');

      for (final day in dayModels) {
        print(day.toJson());
      }

      await _createService.createPackage(
        name: state.name,
        countryId: state.country!.id,
        description: state.description,
        quantity: state.quantity,
        price: pricePerPerson,
        days: dayModels,
      );

      print('✅ PACKAGE CREATED SUCCESSFULLY');

      emit(state.copyWith(status: PackageCreationStatus.success));
    } catch (e, stackTrace) {
      print('❌❌ CREATE PACKAGE API ERROR ❌❌');
      print('ERROR: $e');
      print('STACK TRACE:');
      print(stackTrace);

      emit(
        state.copyWith(
          status: PackageCreationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void selectTab(int index) {
    if (index < 0 || index > state.days.length) {
      return;
    }

    emit(
      state.copyWith(
        selectedTabIndex: index,
        status: PackageCreationStatus.initial,
        clearError: true,
      ),
    );
  }

  // ================================================================
  // HELPERS
  // ================================================================

  void _error(String message) {
    emit(
      state.copyWith(
        status: PackageCreationStatus.error,
        errorMessage: message,
      ),
    );
  }

  String _validationMessage() {
    if (state.country == null) {
      return 'اختر الدولة أولاً';
    }

    if (state.startDate == null || state.endDate == null) {
      return 'حدد تاريخ البداية والنهاية';
    }

    if (state.days.length != state.tripDays) {
      return 'لازم يكون عندك ${state.tripDays} أيام بالضبط';
    }

    for (int i = 0; i < state.days.length; i++) {
      final day = state.days[i];

      if (day.hotel == null) {
        return 'كمل الفندق في Day ${i + 1}';
      }

      if (day.place == null) {
        return 'كمل المكان السياحي في Day ${i + 1}';
      }

      if (day.restaurant == null) {
        return 'كمل المطعم في Day ${i + 1}';
      }
    }

    if (state.withFlight) {
      if (state.days.first.flight == null) {
        return 'اختر رحلة الذهاب في Day 1';
      }

      if (state.days.last.flight == null) {
        return 'اختر رحلة العودة في Day ${state.days.length}';
      }
    }

    return 'كمل بيانات الباقة';
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
