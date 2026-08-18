import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/shared/cubits/wallet/wallet_state.dart';

// حالة الرصيد المشتركة عبر التطبيق كله (نفس فلسفة FavoritesCubit).
// لازم يترّجب فوق الـ Navigator (فوق MaterialApp) منشان يضل نفس
// الكائن متاح من أي شاشة، وينعمله refresh() بعد أي عملية دفع/حجز.
class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletInitial());
  final ApiService _apiService = ApiService();

  Future<void> refresh() async {
    emit(WalletLoading());
    try {
      final response = await _apiService.get('/profile');
      final creditRaw = response['data']['user']['credit'];
      final credit = double.tryParse(creditRaw.toString()) ?? 0;
      emit(WalletLoaded(credit: credit));
    } catch (e) {
      emit(WalletError(message: e.toString()));
    }
  }
}
