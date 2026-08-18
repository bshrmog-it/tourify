import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/airlines/services/airlines_service.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';
import 'airlines_state.dart';

class AirlinesCubit extends Cubit<AirlinesState> {
  AirlinesCubit({
    required FavoritesCubit favoritesCubit,
    AirlinesService? service,
  })  : _favoritesCubit = favoritesCubit,
        _service = service ?? AirlinesService(),
        super(const AirlinesInitial());

  final FavoritesCubit _favoritesCubit;
  final AirlinesService _service;

  Future<void> getAirlines() async {
    emit(const AirlinesLoading());

    try {
      final airlines = await _service.getAirlines();

      _favoritesCubit.syncFromServer(
        FavoriteType.airline,
        {for (final airline in airlines) airline.id: airline.isFavorite},
      );

      emit(AirlinesLoaded(airlines));
    } catch (e) {
      emit(AirlinesError(e.toString()));
    }
  }
}
