# AI Development Skills & Guidelines

هذا الملف يحتوي على القواعد الأساسية (المهارات) التي يجب على الذكاء الاصطناعي اتباعها دائماً عند تعديل أو كتابة أي كود في هذا المشروع.

## 1. الألوان والتصميم (Colors & Theme)
- **ممنوع تماماً** استخدام الألوان الثابتة (Hardcoded Colors) مثل `Color(0xFF5CA4B8)` أو `Colors.blue`.
- **يجب دائماً** استخدام نظام الألوان الموحد الخاص بالتطبيق عبر `QsColorExtension`.
- طريقة الاستخدام الصحيحة في الواجهات:
  ```dart
  final colors = context.qsColors;
  
  Container(
    color: colors.background, // بدلاً من اللون الرمادي الفاتح
    child: Text(
      'نص',
      style: TextStyle(color: colors.text), // بدلاً من الأسود
    ),
  );
  ```
- **الألوان المتاحة:** `primary`, `background`, `card`, `text`, `textSub`, `error`, `success`, `warning`.

## 2. الترجمة والنصوص (Localization & Translation)
- **ممنوع تماماً** كتابة نصوص عربية أو إنجليزية ثابتة داخل واجهات المستخدم (UI) مثل `Text('حفظ')` أو `Text('Save')`.
- **يجب دائماً** استخدام نظام الترجمة المدمج `context.tr('key')`.
- طريقة الاستخدام الصحيحة:
  ```dart
  Text(context.tr('save_button_key'))
  ```
- عند إضافة نصوص جديدة، تأكد من توفيرها باللغتين إذا لزم الأمر في ملفات الـ JSON الخاصة بالترجمة.

## 3. الهيكلة والمعمارية (Architecture & Structure)
يتبع هذا المشروع معمارية **MVVM (Model-View-ViewModel)**. يجب وضع كل كود في مكانه الصحيح:
- **Views (الواجهات):** مسؤولة فقط عن بناء واجهة المستخدم (UI) باستخدام `StatelessWidget` أو `StatefulWidget`. لا تضع فيها أي منطق برمجي معقد أو استدعاءات API مباشرة.
- **ViewModels (المتحكمات):** مسؤولة عن إدارة الحالة (State Management) مثل `isLoading` و `errorMessage`، وتحتوي على المنطق البرمجي، وتقوم باستدعاء الدوال من الـ Repository باستخدام `ChangeNotifier`.
- **Repositories (مستودعات البيانات):** مسؤولة عن التواصل مع الـ Backend (APIs) باستخدام `ApiService`، ومعالجة الأخطاء عن طريق `ApiErrorHandler`.
- **Models (النماذج):** مسؤولة عن هيكلة البيانات فقط (دوال `fromJson` و `toJson`).

## 4. المسارات (Routing) والتنقل
- عند التوجيه لشاشة جديدة تحتاج لـ ViewModel، استخدم `ChangeNotifierProvider` لتمرير الـ ViewModel داخل `MaterialPageRoute`.
- مثال:
  ```dart
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (ctx) => ChangeNotifierProvider(
        create: (c) => ExampleViewModel(ExampleRepository(c.read<ApiService>())),
        child: const ExampleView(),
      ),
    ),
  );
  ```

---
> **ملاحظة للذكاء الاصطناعي:** راجع هذا الملف دائماً قبل إجراء أي تعديلات لضمان اتساق الكود والحفاظ على نظافة الهيكلة.
