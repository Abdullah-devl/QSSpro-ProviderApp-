import 'package:flutter/material.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:provider/provider.dart';
import '../viewmodels/services_viewmodel.dart';

class ServicesView extends StatelessWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم watch لمراقبة التغييرات داخل الفيو مودل
    final vm = context.watch<ServicesViewModel>();

    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF5CA4B8)),
      );
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(vm.errorMessage!, style: TextStyle(color: context.qsColors.error)),
            ElevatedButton(
              onPressed: vm.fetchServices,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final services = vm.services;

    if (services.isEmpty) {
      return RefreshIndicator(
        color: context.qsColors.textSub,
        backgroundColor: context.qsColors.card,
        onRefresh: vm.fetchServices,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Center(
              child: Text('لا توجد خدمات حالياً', style: TextStyle(color: context.qsColors.textSub)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: context.qsColors.textSub,
      backgroundColor: context.qsColors.card,
      onRefresh: vm.fetchServices,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final service = services[index];
          return Container(
            decoration: BoxDecoration(
              color: context.qsColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.qsColors.textSub),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // صورة الخدمة الدائرية على اليمين
                ClipOval(
                  child: Image.network(
                    service.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: context.qsColors.textSub,
                      child: Icon(Icons.miscellaneous_services, color: context.qsColors.textSub),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // اسم الخدمة وتقييمها بالمنتصف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        service.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      // ⭐ عرض التقييم بالنجوم
                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (starIndex) {
                          if (starIndex < service.rating.floor()) {
                            // نجمة كاملة
                            return Icon(Icons.star, color: context.qsColors.warning, size: 18);
                          } else if (starIndex < service.rating) {
                            // نصف نجمة
                            return Icon(Icons.star_half, color: context.qsColors.warning, size: 18);
                          } else {
                            // نجمة فارغة
                            return Icon(Icons.star_border, color: context.qsColors.warning, size: 18);
                          }
                        }),
                      ),
                    ],
                  ),
                ),

                // زر التبديل (Switch) لتفعيل/إلغاء تفعيل الخدمة على اليسار
                Switch(
                  value: service.isActive,
                  activeColor: const Color(0xFF5CA4B8),
                  onChanged: (val) {
                    vm.toggleServiceStatus(service.id, val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت محاكاة التغيير (تحتاج رابط التعديل من الباك إند)')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


