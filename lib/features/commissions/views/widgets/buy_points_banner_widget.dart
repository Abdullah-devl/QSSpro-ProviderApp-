// مسار الملف: lib/features/commissions/views/widgets/buy_points_banner_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:service_provider_app/features/points/repositories/points_repository.dart';
import 'package:service_provider_app/features/points/viewmodels/points_viewmodel.dart';
import 'package:service_provider_app/features/points/views/points_packages_view.dart';
import 'package:service_provider_app/core/network/api_client.dart';

class BuyPointsBannerWidget extends StatelessWidget {
  const BuyPointsBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 📦 أيقونة النقاط
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.stars_rounded,
                  color: colors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // 📝 النصوص تظهر بجانب الأيقونة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('buy_points_banner_title'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('buy_points_banner_subtitle'),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSub,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 🔘 زر الشراء (Top Up)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (context) => PointsViewModel(
                        PointsRepository(context.read<ApiService>()),
                      ),
                      child: const PointsPackagesView(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.card,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                context.tr('buy_points_now'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
