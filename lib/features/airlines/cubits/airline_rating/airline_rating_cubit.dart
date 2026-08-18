import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/airlines/services/airline_rating_service.dart';
import 'airline_rating_state.dart';

class AirlineRatingCubit extends Cubit<AirlineRatingState> {
  AirlineRatingCubit({AirlineRatingService? service})
      : _service = service ?? AirlineRatingService(),
        super(const AirlineRatingInitial());

  final AirlineRatingService _service;

  Future<void> rate({
    required int airlineId,
    required int rating,
  }) async {
    if (rating < 1 || rating > 5) return;

    emit(const AirlineRatingLoading());

    try {
      await _service.rateAirline(
        airlineId: airlineId,
        rating: rating,
      );
      emit(AirlineRatingSuccess(rating));
    } catch (e) {
      emit(AirlineRatingError(_cleanMessage(e)));
    }
  }

  String _cleanMessage(Object error) {
    final text = error.toString();
    return text.replaceFirst('Exception: ', '');
  }
}
