import os
import re

files_to_fix = [
    'lib/features/profile/views/services_view.dart',
    'lib/features/profile/views/contact_info_view.dart',
    'lib/features/profile/views/provider_reviews_view.dart',
    'lib/core/utils/dialog_helper.dart',
    'lib/features/profile/widgets/add_edit_phone_dialog.dart',
    'lib/features/profile/widgets/add_edit_bank_dialog.dart',
    'lib/features/services/widgets/special_service_card_widget.dart',
    'lib/features/services/views/edit_custom_service_view.dart',
    'lib/features/services/views/edit_meeting_service_view.dart',
    'lib/features/settings/views/settings_view.dart'
]

for file_path in files_to_fix:
    full_path = os.path.join(os.getcwd(), file_path)
    if not os.path.exists(full_path):
        continue
        
    with open(full_path, 'r', encoding='utf-8') as f:
        content = f.read()

    depth = file_path.count('/') - 1
    if file_path.startswith('lib/core/'):
        import_stmt = 'import \'../localization/app_localizations.dart\';'
    else:
        prefix = '../' * depth
        import_stmt = 'import \'' + prefix + 'core/localization/app_localizations.dart\';'

    if 'app_localizations.dart' not in content:
        imports = re.findall(r'^import .*;$', content, flags=re.MULTILINE)
        if imports:
            last_import = imports[-1]
            content = content.replace(last_import, last_import + '\n' + import_stmt)
        else:
            content = import_stmt + '\n' + content

    content = content.replace('const InputDecoration(', 'InputDecoration(')
    content = content.replace('const DropdownMenuItem(', 'DropdownMenuItem(')
    content = content.replace('const SnackBar(', 'SnackBar(')
    
    if file_path.endswith('settings_view.dart'):
        content = content.replace("context.tr('auto_tr_55')", "context.tr('auto_tr_55') +")

    with open(full_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
print('Fixed files successfully.')
