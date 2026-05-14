import 'package:flutter/material.dart';
import '../Models/order_model.dart';
import '../Repository/orders_repository.dart';

class OrdersViewModel extends ChangeNotifier {
  final OrdersRepository _repository;

  OrdersViewModel(this._repository);

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<OrderModel> _allOrders = [];
  List<OrderModel> get allOrders => _allOrders;

  // 🚀 تعريف التبويبات (أضفنا المرفوض والملغي)
  final List<String> tabs = [
    'all',
    'new_order',
    'in_progress',
    'completed',
    'rejected_orders',
  ];

  bool _hasFetchedOnce = false;

  // 🚀 دالة جلب الطلبات من المستودع (Cache-Then-Network)
  Future<void> fetchOrders() async {
    // 1. 📥 تحميل الطلبات من الكاش المحلي فوراً وعرضها للمستخدم بدون تأخير
    final cachedOrders = _repository.getCachedOrders();
    if (cachedOrders.isNotEmpty) {
      cachedOrders.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      _allOrders = cachedOrders;
      debugPrint('⚡ OrdersViewModel: Loaded ${_allOrders.length} orders instantly from local Hive cache.');
      notifyListeners();
    }

    // 2. ⚡ تفعيل الشيمر في المرة الأولى فقط خلال جلسة التطبيق الحالية
    if (!_hasFetchedOnce) {
      _isLoading = true;
      _hasFetchedOnce = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final fetchedOrders = await _repository.getOrders();
      // 🚀 فرز الطلبات: الأحدث دائماً في الأعلى (بناءً على تاريخ الإنشاء)
      fetchedOrders.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      _allOrders = fetchedOrders;
      debugPrint('📦 ✅ تم جلب ${_allOrders.length} طلبات بنجاح مرتبة من الأحدث للأقدم.');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 📦 فشل جلب الطلبات في الـ ViewModel: $e');
      _isLoading = false;
      if (_allOrders.isEmpty) {
        _errorMessage = e.toString();
      }
      notifyListeners();
    }
  }

  List<OrderModel> get filteredOrders {
    if (_selectedTabIndex == 0) return _allOrders; // الكل

    if (_selectedTabIndex == 1) {
      // جديد (Pending / New)
      return _allOrders
          .where((o) => o.status == 'pending' || o.status == 'new')
          .toList();
    }

    if (_selectedTabIndex == 2) {
      // قيد التنفيذ
      return _allOrders
          .where(
            (o) =>
                o.status == 'accepted_initial' ||
                o.status == 'accepted_partial_paid' ||
                o.status == 'accepted_full_paid' ||
                o.status == 'in_progress',
          )
          .toList();
    }

    if (_selectedTabIndex == 3) {
      // مكتمل
      return _allOrders
          .where((o) => o.status == 'completed' || o.status == 'finished')
          .toList();
    }

    if (_selectedTabIndex == 4) {
      // مرفوض وملغي
      return _allOrders
          .where((o) => o.status == 'cancelled' || o.status == 'rejected')
          .toList();
    }

    return []; // Fallback
  }

  void changeTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // 🚀 تحديث بيانات طلب واحد لضمان دقة العرض في صفحة التفاصيل
  Future<void> refreshOrderDetail(String id) async {
    try {
      final updatedOrder = await _repository.getOrderDetail(id);
      final index = _allOrders.indexWhere((o) => o.id == id);
      if (index != -1) {
        _allOrders[index] = updatedOrder;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ فشل تحديث بيانات الطلب الفردي: $e');
    }
  }

  // 🚀 تحديث حالة الطلب
  Future<bool> updateStatus(String id, String newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateOrderStatus(id, newStatus);
      await refreshOrderDetail(id); // تحديث بيانات هذا الطلب تحديداً
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🚀 إضافة مبلغ مدفوع
  Future<bool> addPaidAmount(String id, double amount) async {
    debugPrint(
      '🧪 [VIEWMODEL] Starting addPaidAmount for ID: $id with amount: $amount',
    );
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. إضافة المبلغ المدفوع
      await _repository.addPaidAmount(id, amount);

      // تم إزالة الترقية التلقائية للحالة بناءً على طلب المستخدم لأن الباك إند يقوم بذلك تلقائياً


      // 3. تحديث البيانات النهائية من السيرفر
      await refreshOrderDetail(id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🚀 إنهاء العمل من قبل المزود
  Future<bool> finishOrder(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.finishRequest(id);
      await refreshOrderDetail(id); // تحديث البيانات للتأكد من حالة provider_finished
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🚀 قبول السند
  Future<bool> approveBond(String orderId, String bondId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.approveBond(bondId);
      await refreshOrderDetail(orderId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🚀 رفض السند
  Future<bool> rejectBond(String orderId, String bondId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.rejectBond(bondId);
      await refreshOrderDetail(orderId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🚀 جلب بيانات حساب طالب الخدمة
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _repository.getUserProfile(userId);
      debugPrint('🟢 [ViewModel] Fetched Seeker Profile Successfully: $res');
      return res;
    } catch (e) {
      debugPrint('🔴 [ViewModel] Failed to fetch Seeker Profile: $e');
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
