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

  final List<String> tabs = ['all', 'new_order', 'in_progress', 'completed'];

  // 🚀 دالة جلب الطلبات من المستودع
  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allOrders = await _repository.getOrders();
      debugPrint('📦 ✅ تم جلب ${_allOrders.length} طلبات بنجاح من المستودع.');
      _isLoading = false;
    } catch (e) {
      debugPrint('❌ 📦 فشل جلب الطلبات في الـ ViewModel: $e');
      _isLoading = false;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  List<OrderModel> get filteredOrders {
    if (_selectedTabIndex == 0) return _allOrders; // الكل
    if (_selectedTabIndex == 1) return _allOrders.where((o) => o.status == OrderStatus.newOrder).toList(); // جديد
    if (_selectedTabIndex == 2) return _allOrders.where((o) => o.status == OrderStatus.inProgress).toList(); // قيد التنفيذ
    return _allOrders.where((o) => o.status == OrderStatus.completed).toList(); // مكتمل
  }

  void changeTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }
}