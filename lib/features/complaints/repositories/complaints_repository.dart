import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/error/api_error_handler.dart';
import '../models/complaint_model.dart';

import '../models/system_complaint_model.dart';

class ComplaintsRepository {
  final ApiService _apiService;

  ComplaintsRepository(this._apiService);

  Future<void> submitOrderComplaint(ComplaintModel complaint) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.complaints,
        data: complaint.toJson(),
      );

      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<List<SystemComplaintModel>> getSystemComplaints() async {
    try {
      final response = await _apiService.get(ApiEndpoints.systemComplaints);
      ApiErrorHandler.handleResponse(response);
      
      // 🧩 التعديل: الوصول للحزمة SystemComplaints كما يرسلها الباك إند
      final List data = response.data['SystemComplaints']?['data'] ?? [];
      return data.map((e) => SystemComplaintModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> submitSystemComplaint(SystemComplaintModel complaint) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.systemComplaints,
        data: complaint.toJson(),
      );

      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
