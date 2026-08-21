import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/agency/agency_view/cubits/agencies/agencies_state.dart';
import 'package:tourify/features/agency/agency_view/services/get_agencies.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';

class AgenciesCubit extends Cubit<AgenciesState> {
  AgenciesCubit({required this.favoritesCubit}) : super(AgenciesInitial());
  final FavoritesCubit favoritesCubit;
  final GetAgencies getAgenciesService = GetAgencies();

  Future<void> getAgencies() async {
    emit(AgenciesLoading());
    try {
      final agencies = await getAgenciesService.getAgencies();
      favoritesCubit.syncFromServer(
        FavoriteType.agency,
        {for (final a in agencies) a.id: a.isFavorite},
      );
      emit(AgenciesLoaded(agencies: agencies));
    } catch (e) {
      emit(AgenciesError(message: e.toString()));
    }
  }
}
