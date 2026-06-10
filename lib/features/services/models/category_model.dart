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
    // إذا كانت البيانات تحتوي على كائن 'category' داخلي، نستخدمه كـ مصدر رئيسي للبيانات
    final targetJson = json['category'] is Map<String, dynamic>
        ? json['category'] as Map<String, dynamic>
        : json;

    return CategoryModel(
      // معالجة الـ ID سواء أرسله السيرفر كـ int أو String
      id: targetJson['id'] != null ? int.tryParse(targetJson['id'].toString()) ?? 0 : 0,
      name: targetJson['name'] ?? targetJson['title'] ?? 'بدون اسم',
      children: targetJson['children'] != null || targetJson['childrenRecursive'] != null
          ? ((targetJson['children'] ?? targetJson['childrenRecursive']) as List)
              .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      // قد تكون max_services في الكائن الخارجي (pivot) أو الكائن الداخلي (category)
      maxServices: json['max_services'] != null
          ? int.tryParse(json['max_services'].toString())
          : (targetJson['max_services'] != null
              ? int.tryParse(targetJson['max_services'].toString())
              : null),
    );
  }
}