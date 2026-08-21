import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/agency/agency_view/cubits/agency_details/agency_details_state.dart';
import 'package:tourify/features/agency/agency_view/services/get_agency_details.dart';
import 'package:tourify/features/agency/agency_view/services/agency_actions_service.dart';
import 'package:tourify/shared/cubits/favorites/favorites_cubit.dart';
import 'package:tourify/shared/cubits/favorites/favorites_state.dart';

class AgencyDetailsCubit extends Cubit<AgencyDetailsState> {
  AgencyDetailsCubit({required this.favoritesCubit})
      : super(AgencyDetailsInitial());
  final FavoritesCubit favoritesCubit;
  final GetAgencyDetails getAgencyDetailsService = GetAgencyDetails();
  final AgencyActionsService actionsService = AgencyActionsService();

  Future<void> getAgencyDetails(int id) async {
    emit(AgencyDetailsLoading());
    try {
      final agency = await getAgencyDetailsService.getAgencyDetails(id);
      favoritesCubit
          .syncFromServer(FavoriteType.agency, {agency.id: agency.isFavorite});
      emit(AgencyDetailsLoaded(agency: agency));
    } catch (e) {
      emit(AgencyDetailsError(message: e.toString()));
    }
  }

  Future<void> rateAgency(int agencyId, int rating) async {
    await actionsService.rateAgency(agencyId, rating);
  }
}
