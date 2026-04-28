// مسار الملف: lib/features/points/views/points_packages_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import '../models/points_package_model.dart';
import '../viewmodels/points_viewmodel.dart';
import 'submit_points_payment_view.dart';

class PointsPackagesView extends StatefulWidget {
  const PointsPackagesView({super.key});

  @override
  State<PointsPackagesView> createState() => _PointsPackagesViewState();
}

class _PointsPackagesViewState extends State<PointsPackagesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PointsViewModel>().fetchPointsPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<PointsViewModel>();
    final Color bgColor = colors.background;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('points_packages_title'),
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: colors.text, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        leading: const SizedBox.shrink(),
      ),
      body: RefreshIndicator(
        color: colors.primary,
        backgroundColor: colors.card,
        onRefresh: () async => await vm.fetchPointsPackages(),
        child: vm.isLoading
            ? Center(child: CircularProgressIndicator(color: colors.primary))
            : vm.errorMessage != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      _buildErrorWidget(context, vm.errorMessage!),
                    ],
                  )
                : vm.packages.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                          _buildEmptyWidget(context, colors),
                        ],
                      )
                    : _buildPackagesList(context, vm.packages, colors),
      ),
    );
  }

  Widget _buildPackagesList(BuildContext context, List<PointsPackageModel> packages, dynamic colors) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.62,
      ),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        return _buildPointCardObject(context, packages[index], colors);
      },
    );
  }

  Widget _buildPointCardObject(BuildContext context, PointsPackageModel package, dynamic colors) {
    final bool hasBonus = package.bonusPoints > 0;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.text.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.stars_rounded, color: colors.primary, size: 36),
              ),

              Text(
                package.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                children: [
                  Text(
                    context.tr('points_amount', args: {'count': package.points.toString()}),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.primary),
                  ),
                  if (hasBonus)
                    Text(
                      '+ ${package.bonusPoints}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.success),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                '${package.price.toInt()} ${context.tr('sar')}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: colors.text),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => ChangeNotifierProvider.value(
                          value: context.read<PointsViewModel>(),
                          child: SubmitPointsPaymentView(package: package),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.card,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    context.tr('buy_now'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (hasBonus)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.warning,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: colors.warning.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.card_giftcard, color: colors.card, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    context.tr('gift'),
                    style: TextStyle(color: colors.card, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: context.qsColors.error, size: 48),
            const SizedBox(height: 16),
            Text(context.tr('error_loading_points_packages'), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context, dynamic colors) {
    return Center(
      child: Text(context.tr('no_packages_available'), style: TextStyle(color: colors.textSub)),
    );
  }
}
