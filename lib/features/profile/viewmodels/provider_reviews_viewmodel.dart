// مسار الملف: lib/features/profile/viewmodels/provider_reviews_viewmodel.dart

import 'package:flutter/material.dart';
import '../repositories/review_repository.dart';
import '../models/review_model.dart';
import '../../../core/network/error/api_error_handler.dart';

class ProviderReviewsViewModel extends ChangeNotifier {
  final ReviewRepository _repository;
  final int providerId;

  ProviderReviewsViewModel(this._repository, this.providerId) {
    fetchReviews();
  }

  List<ReviewModel> _reviews = [];
  List<ReviewModel> get reviews => _reviews;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reviews = await _repository.getProviderFeedback(providerId);
    } catch (e) {
      _errorMessage = ApiErrorHandler.handle(e).message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleReviewVisibility(BuildContext context, int reviewId, bool currentIsHidden) async {
    try {
      final newIsHidden = !currentIsHidden;
      final success = await _repository.toggleReviewVisibility(reviewId, newIsHidden);
      
      if (success) {
        // تحديث القائمة محلياً لتجنب استدعاء API آخر
        final index = _reviews.indexWhere((r) => r.id == reviewId);
        if (index != -1) {
          final oldReview = _reviews[index];
          _reviews[index] = ReviewModel(
            id: oldReview.id,
            rating: oldReview.rating,
            comment: oldReview.comment,
            createdAt: oldReview.createdAt,
            isHidden: newIsHidden, // تحديث حالة الإخفاء
            user: oldReview.user,
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      final errorMsg = ApiErrorHandler.handle(e).message;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
      return false;
    }
  }
}
