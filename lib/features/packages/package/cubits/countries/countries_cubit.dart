import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/get_countries.dart';
import 'countries_state.dart';

class CountriesCubit extends Cubit<CountriesState> {
  CountriesCubit() : super(CountriesInitial());

  final GetCountries service = GetCountries();

  Future<void> getCountries() async {
    emit(CountriesLoading());

    try {
      final countries = await service.getCountries();

      emit(CountriesLoaded(countries));
    } catch (e) {
      emit(CountriesError(e.toString()));
    }
  }
}
