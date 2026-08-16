import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/shared/cubits/wallet/wallet_cubit.dart';
import 'package:tourify/shared/cubits/wallet/wallet_state.dart';

// Badge صغير للرصيد، للوضع بزاوية أي AppBar/SliverAppBar actions.
class WalletBadge extends StatelessWidget {
  const WalletBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        String display;
        if (state is WalletLoaded) {
          display = '\$${state.credit.toStringAsFixed(0)}';
        } else if (state is WalletError) {
          display = '—';
        } else {
          display = '...';
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.30),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    display,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
