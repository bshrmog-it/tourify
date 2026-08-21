import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/shared/widgets/retryable_network_image.dart';
import 'package:tourify/features/packages/package_user/cubits/view_package/view_package_cubit.dart';
import 'package:tourify/features/packages/package_user/cubits/view_package/view_package_state.dart';
import 'package:tourify/features/packages/package_user/models/package_model.dart';

class ViewPackageScreen extends StatelessWidget {
  final int packageId;

  const ViewPackageScreen({
    super.key,
    required this.packageId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ViewPackageCubit()..load(packageId),
      child: _ViewPackageBody(packageId: packageId),
    );
  }
}

class _ViewPackageBody extends StatefulWidget {
  final int packageId;

  const _ViewPackageBody({
    required this.packageId,
  });

  @override
  State<_ViewPackageBody> createState() => _ViewPackageBodyState();
}

class _ViewPackageBodyState extends State<_ViewPackageBody> {
  bool _booking = false;

  Future<void> _book() async {
    setState(() => _booking = true);

    try {
      await context.read<ViewPackageCubit>().book(widget.packageId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Package booked successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _booking = false);
      }
    }
  }

  Future<void> _showBookingConfirmation(PackageModel package) async {
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surfaceContainer,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            16,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 31,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Confirm Booking',
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to book this package?',
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      height: 1.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        package.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '\$${package.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        side: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                        minimumSize: const Size(
                          0,
                          50,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        minimumSize: const Size(
                          0,
                          50,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left:15),
                        child: const Text(
                          'Confirm Booking',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      await _book();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocBuilder<ViewPackageCubit, ViewPackageState>(
        builder: (context, state) {
          if (state is ViewPackageLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            );
          }

          if (state is ViewPackageError) {
            return _ErrorView(
              message: state.message,
              onRetry: () {
                context
                    .read<ViewPackageCubit>()
                    .load(widget.packageId);
              },
            );
          }

          if (state is! ViewPackageLoaded) {
            return const SizedBox.shrink();
          }

          final package = state.package;

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildHeroSection(
                    context,
                    package,
                  ),

                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -28),
                      child: _buildPackageHeader(
                        context,
                        package,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _buildDescriptionSection(
                              context,
                              package,
                            ),
                            const SizedBox(height: 28),
                            _buildItineraryHeader(
                              context,
                              package,
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      150,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final day = package.days[index];

                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 16,
                            ),
                            child: _DayCard(
                              dayNumber: index + 1,
                              day: day,
                            ),
                          );
                        },
                        childCount: package.days.length,
                      ),
                    ),
                  ),
                ],
              ),
              _buildBottomBookingBar(
                context,
                package,
                primary,
              ),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildHeroSection(
    BuildContext context,
    PackageModel package,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      backgroundColor: colorScheme.primary,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _CircleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (package.coverImageUrl != null)
              RetryableNetworkImage(
                url: package.coverImageUrl!,
                fit: BoxFit.cover,
              )
            else
              Container(
                color: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.landscape_outlined,
                  size: 70,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.20),
                    Colors.transparent,
                    Colors.black.withOpacity(0.30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageHeader(
    BuildContext context,
    PackageModel package,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 25,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  package.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _PriceBadge(
                price: package.price,
                primary: primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.public_rounded,
                label: package.country.name,
              ),
              _InfoChip(
                icon: Icons.calendar_month_rounded,
                label: '${package.numberOfDays} days',
              ),
              _InfoChip(
                icon: Icons.business_rounded,
                label: package.agency.name,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(
    BuildContext context,
    PackageModel package,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'About this package',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          package.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.65,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildItineraryHeader(
    BuildContext context,
    PackageModel package,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Text(
          'Your itinerary',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const Spacer(),
        Text(
          '${package.days.length} days',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBookingBar(
    BuildContext context,
    PackageModel package,
    Color primary,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            14,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Package price',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${package.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _booking
                        ? null
                        : () => _showBookingConfirmation(package),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: colorScheme.onPrimary,
                      disabledBackgroundColor:
                          primary.withOpacity(0.55),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(17),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration:
                          const Duration(milliseconds: 200),
                      child: _booking
                          ? SizedBox(
                              key: const ValueKey('loading'),
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : Row(
                              key: const ValueKey('book'),
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  size: 21,
                                  color:
                                      colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 9),
                                Text(
                                  'Book Now',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w700,
                                    color:
                                        colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final int dayNumber;
  final PackageDay day;

  const _DayCard({
    required this.dayNumber,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;

    final events = <Widget>[
      if (day.place != null)
        _EventCard(
          imageUrl: day.place!.mainImageUrl,
          title: day.place!.name,
          type: 'Place',
          icon: Icons.location_on_outlined,
          primary: primary,
        ),
      if (day.hotel != null)
        _EventCard(
          imageUrl: day.hotel!.mainImageUrl,
          title: day.hotel!.name,
          type: 'Hotel',
          icon: Icons.hotel_outlined,
          primary: primary,
        ),
      if (day.restaurant != null)
        _EventCard(
          imageUrl: day.restaurant!.mainImageUrl,
          title: day.restaurant!.name,
          type: 'Restaurant',
          icon: Icons.restaurant_outlined,
          primary: primary,
        ),
      if (day.flight != null)
        _FlightCard(
          departure: day.flight!.departure,
          arrival: day.flight!.arrival,
          primary: primary,
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day $dayNumber',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        day.date,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (events.isEmpty)
              const _EmptyDay()
            else
              SizedBox(
                height: 205,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: events.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 12),
                  itemBuilder: (_, index) => events[index],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String type;
  final IconData icon;
  final Color primary;

  const _EventCard({
    required this.imageUrl,
    required this.title,
    required this.type,
    required this.icon,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 125,
            width: 160,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: imageUrl != null
                ? RetryableNetworkImage(
                    url: imageUrl!,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Icon(
                      icon,
                      size: 38,
                      color: primary.withOpacity(0.55),
                    ),
                  ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: primary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlightCard extends StatelessWidget {
  final String departure;
  final String arrival;
  final Color primary;

  const _FlightCard({
    required this.departure,
    required this.arrival,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 160,
      height: 205,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withOpacity(0.08),
            primary.withOpacity(0.16),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primary.withOpacity(0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flight_takeoff_rounded,
              color: primary,
              size: 29,
            ),
          ),
          const Spacer(),
          Text(
            'Flight',
            style: TextStyle(
              color: primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            departure,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: primary.withOpacity(0.25),
                    thickness: 1,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Divider(
                    color: primary.withOpacity(0.25),
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),
          Text(
            arrival,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBadge extends StatelessWidget {
  final double price;
  final Color primary;

  const _PriceBadge({
    required this.price,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary,
            primary.withOpacity(0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${price.toStringAsFixed(0)}',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'package',
            style: TextStyle(
              color: colorScheme.onPrimary.withOpacity(0.70),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: primary.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: primary,
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 150,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.42),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 28,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 7),
          Text(
            'No activities planned',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 58,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}