abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final double credit;
  WalletLoaded({required this.credit});
}

class WalletError extends WalletState {
  final String message;
  WalletError({required this.message});
}
