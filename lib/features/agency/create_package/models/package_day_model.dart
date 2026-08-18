class PackageDayModel {
  final String date;
  final int placeId;
  final int hotelId;
  final String roomType;
  final int restaurantId;
  final int? flightScheduleId;

  PackageDayModel({
    required this.date,
    required this.placeId,
    required this.hotelId,
    required this.roomType,
    required this.restaurantId,
    this.flightScheduleId,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'place_id': placeId,
      'hotel_id': hotelId,
      'room_type': roomType,
      'restaurant_id': restaurantId,
      if (flightScheduleId != null) 'flight_schedule_id': flightScheduleId,
    };
  }
}
