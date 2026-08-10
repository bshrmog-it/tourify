import 'package:tourify/features/package/models/package_day_model.dart';

import 'flight_model.dart';
import 'hotel_model.dart';
import 'place_model.dart';
import 'resturent_model.dart';

class PackageDayData {
  int dayNumber;

  String date;

  int cityId;
  int? hotelId;

  int? placeId;

  int? restaurantId;

  int? flightId;
  HotelModel? hotel;

  PlaceModel? place;

  RestaurantModel? restaurant;

  FlightModel? flight;

  String? roomType;

  PackageDayData({
    required this.dayNumber,
    required this.date,
    required this.cityId,
    this.hotelId,
    this.placeId,
    this.restaurantId,
    this.flightId,
    this.hotel,
    this.place,
    this.restaurant,
    this.flight,
    this.roomType,
  });

  PackageDayModel toPackageDayModel() {
    return PackageDayModel(
      date: date,
      placeId: place!.id,
      hotelId: hotel!.id,
      roomType: roomType ?? hotel!.roomTypes.first,
      restaurantId: restaurant!.id,
      flightScheduleId: flight?.id,
    );
  }
}
