// مسار الملف: lib/features/commissions/viewmodels/pay_commissions_viewmodel.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/commissions_repository.dart';
import '../models/commission_model.dart';

enum PaymentMethodType { bankTransfer, rewardPoints }

class PayCommissionsViewModel extends ChangeNotifier {
  final CommissionsRepository _repository;
  final ImagePicker _picker = ImagePicker();

  PayCommissionsViewModel(this._repository);

  // البيانات الديناميكية من الـ API
  CommissionDataModel? _commissionData;
  CommissionDataModel? get commissionData => _commissionData;

  // طريقة الدفع الافتراضية
  PaymentMethodType _selectedMethod = PaymentMethodType.bankTransfer;
  PaymentMethodType get selectedMethod => _selectedMethod;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- حقول السداد بالسند (تتوافق مع API: request_id, bond_number, image, description) ---
  File? _receiptImage;
  File? get receiptImage => _receiptImage;

  final TextEditingController requestIdController = TextEditingController();
  final TextEditingController bondNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void changePaymentMethod(PaymentMethodType method) {
    _selectedMethod = method;
    notifyListeners();
  }

  // اختيار صورة السند
  Future<void> pickReceiptImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _receiptImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "error_image_selection"; // مفتاح الترجمة
      notifyListeners();
    }
  }

  // جلب بيانات العمولات والنقاط
  Future<void> fetchCommissionsData(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. نحن لا نطلب api/commissions لتجنب 404
      // _commissionData = await _repository.getCommissionsData();

      // 2. جلب رصيد النقاط المحدث (bonus_points) من المسار 5.11
      final dynamic pointsData = await _repository.getPointsBalance(userId);
      debugPrint('🔍 PayCommissionsViewModel: pointsData received: $pointsData');

      // محاولة استخراج القيم بشكل مرن (سواء كانت في 'data' أو مباشرة)
      final map = (pointsData is Map && pointsData.containsKey('data')) 
          ? pointsData['data'] 
          : pointsData;

      int parsePoints(dynamic val) {
        if (val == null) return 0;
        if (val is num) return val.toInt();
        return double.tryParse(val.toString())?.toInt() ?? 0;
      }

      final int bonus = parsePoints(map['bonus_points']);
      final int paid = parsePoints(map['paid_points']);
      
      debugPrint('🔍 PayCommissionsViewModel: Parsed Points -> Bonus: $bonus, Paid: $paid');

      // إنشاء نموذج بيانات افتراضي يحتوي على النقاط المحدثة
      _commissionData = CommissionDataModel(
        summary: CommissionSummaryModel(
          dueAmount: 0.0, 
          isVerified: true, 
          availablePoints: bonus + paid,
          bonusPoints: bonus,
          paidPoints: paid,
          pointsConversionFactor: 1, 
        ),
        transactions: [],
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ PayCommissionsViewModel Error: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // السداد باستخدام النقاط لطلب محدد — POST /api/requests/{id}/pay-commission
  Future<bool> payCommissionUsingPoints(String requestId, int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.payCommissionWithPoints(requestId);
      
      // تحديث البيانات بعد السداد الناجح
      await fetchCommissionsData(userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // السداد باستخدام النقاط (قديم/عام)
  Future<bool> payUsingPoints(double amount, int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.payWithPoints(amount);
      await fetchCommissionsData(userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // السداد بإرفاق السند — POST /api/request-commission-bonds
  Future<bool> submitReceipt(double amount) async {
    // التحقق من الحقول المطلوبة
    if (_receiptImage == null) {
      _errorMessage = "error_missing_receipt_image"; // مفتاح الترجمة
      notifyListeners();
      return false;
    }
    if (requestIdController.text.trim().isEmpty) {
      _errorMessage = "error_missing_request_id"; // مفتاح الترجمة
      notifyListeners();
      return false;
    }
    if (bondNumberController.text.trim().isEmpty) {
      _errorMessage = "error_missing_bond_number"; // مفتاح الترجمة
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.payWithReceipt(
        requestId: requestIdController.text.trim(),
        bondNumber: bondNumberController.text.trim(),
        amount: amount,
        imagePath: _receiptImage!.path,
        description: descriptionController.text.trim(),
      );

      _isLoading = false;
      // تفريغ الحقول بعد النجاح
      _receiptImage = null;
      requestIdController.clear();
      bondNumberController.clear();
      descriptionController.clear();
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    requestIdController.dispose();
    bondNumberController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
