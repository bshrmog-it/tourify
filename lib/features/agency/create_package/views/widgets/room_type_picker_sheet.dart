import 'package:flutter/material.dart';
import 'package:tourify/features/agency/create_package/models/hotel_model.dart';
import 'room_type_option.dart';

int roomCapacity(String type) {
  switch (type) {
    case 'A':
      return 4;
    case 'B':
      return 3;
    case 'C':
      return 2;
    case 'D':
      return 1;
    default:
      return 1;
  }
}

Future<String?> showRoomTypePicker(
  BuildContext context,
  HotelModel hotel, {
  String? lockedRoomType,
}) {
  final availableRoomTypes = hotel.roomTypes;

  if (lockedRoomType != null) {
    if (!availableRoomTypes.contains(lockedRoomType)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'This hotel does not support Room $lockedRoomType. Please choose another hotel.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
      });
      return Future.value(null);
    }

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Room Type',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  hotel.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Room type is locked to Room $lockedRoomType for all days.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                RoomTypeOption(
                  type: lockedRoomType,
                  capacity: roomCapacity(lockedRoomType),
                  onTap: () => Navigator.pop(context, lockedRoomType),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  final roomTypes = availableRoomTypes.isNotEmpty
      ? availableRoomTypes
      : ['A', 'B', 'C', 'D'];

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Room Type',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                hotel.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              for (final type in roomTypes)
                RoomTypeOption(
                  type: type,
                  capacity: roomCapacity(type),
                  onTap: () => Navigator.pop(context, type),
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}
