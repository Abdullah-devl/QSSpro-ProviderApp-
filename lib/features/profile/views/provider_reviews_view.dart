// مسار الملف: lib/features/profile/views/provider_reviews_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import '../viewmodels/provider_reviews_viewmodel.dart';
import '../models/review_model.dart';

class ProviderReviewsView extends StatelessWidget {
  const ProviderReviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProviderReviewsViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Text(
          vm.errorMessage!,
          style: TextStyle(color: context.qsColors.error),
        ),
      );
    }

    if (vm.reviews.isEmpty) {
      return const Center(child: Text('لا توجد تقييمات حالياً.'));
    }

    return RefreshIndicator(
      onRefresh: vm.fetchReviews,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: vm.reviews.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final review = vm.reviews[index];
          return _buildReviewCard(context, vm, review);
        },
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, ProviderReviewsViewModel vm, ReviewModel review) {
    final colors = context.qsColors;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.textSub.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: review.user.avatarUrl.isNotEmpty 
                      ? NetworkImage(review.user.avatarUrl) 
                      : null,
                  backgroundColor: colors.primary.withValues(alpha: 0.1),
                  child: review.user.avatarUrl.isEmpty 
                      ? Icon(Icons.person, color: colors.primary) 
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        review.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                review.comment,
                style: TextStyle(color: colors.text, height: 1.5),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: () {
                  vm.toggleReviewVisibility(context, review.id, review.isHidden);
                },
                icon: Icon(
                  review.isHidden ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                  color: review.isHidden ? colors.success : colors.error,
                ),
                label: Text(
                  review.isHidden ? 'إظهار التقييم' : 'إخفاء التقييم',
                  style: TextStyle(
                    color: review.isHidden ? colors.success : colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: (review.isHidden ? colors.success : colors.error).withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString; // Fallback if parsing fails
    }
  }
}
