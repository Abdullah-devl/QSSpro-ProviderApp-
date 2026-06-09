// // مسار الملف: lib/features/services/models/category_model.dart

// class CategoryModel {
//   final int id;
//   final String name;

//   CategoryModel({required this.id, required this.name});

//   factory CategoryModel.fromJson(Map<String, dynamic> json) {
//     return CategoryModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//     );
//   }
// }
// مسار الملف: lib/features/services/models/category_model.dart

class CategoryModel {
  final int id;
  final String name;
  final List<CategoryModel> children;
  final int? maxServices;

  CategoryModel({
    required this.id,
    required this.name,
    this.children = const [],
    this.maxServices,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      // معالجة الـ ID سواء أرسله السيرفر كـ int أو String
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      name: json['name'] ?? json['title'] ?? 'بدون اسم',
      children: json['children'] != null || json['childrenRecursive'] != null
          ? ((json['children'] ?? json['childrenRecursive']) as List)
              .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      maxServices: json['max_services'] != null ? int.tryParse(json['max_services'].toString()) : null,
    );
  }
}