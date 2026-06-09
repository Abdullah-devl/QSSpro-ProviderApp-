import os
import re
import json

def main():
    base_dir = r"c:\Users\Al_Hamed\Desktop\Flutter projctes\GardeionProjcts\provider"
    lib_dir = os.path.join(base_dir, "lib")
    lang_dir = os.path.join(base_dir, "assets", "lang")
    out_file = r"C:\Users\Al_Hamed\.gemini\antigravity\brain\11f03f21-ecf6-4593-9c72-e35d0bafc70b\translation_report.md"
    
    # 1. Extract keys from dart files
    pattern = re.compile(r"""\.tr\(\s*['"]([^'"]+)['"]""")
    
    used_keys = set()
    for root, _, files in os.walk(lib_dir):
        for file in files:
            if file.endswith(".dart"):
                file_path = os.path.join(root, file)
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()
                    matches = pattern.findall(content)
                    for match in matches:
                        if "$" not in match:
                            used_keys.add(match)
                            
    # 2. Load JSON files
    ar_path = os.path.join(lang_dir, "ar.json")
    en_path = os.path.join(lang_dir, "en.json")
    
    with open(ar_path, "r", encoding="utf-8") as f:
        ar_data = json.load(f)
    with open(en_path, "r", encoding="utf-8") as f:
        en_data = json.load(f)
        
    ar_keys = set(ar_data.keys())
    en_keys = set(en_data.keys())
    
    # 3. Find missing keys in JSON files
    missing_in_ar = used_keys - ar_keys
    missing_in_en = used_keys - en_keys
    
    # 4. Find unused keys in JSON files
    unused_ar = ar_keys - used_keys
    unused_en = en_keys - used_keys
    
    # 5. Empty values
    empty_ar = [k for k, v in ar_data.items() if not v.strip()]
    empty_en = [k for k, v in en_data.items() if not v.strip()]

    # Write report
    with open(out_file, "w", encoding="utf-8") as md:
        md.write("# Translation Keys Scan Report\n\n")
        md.write(f"**Total keys used in code:** {len(used_keys)}\n")
        md.write(f"**Total keys in ar.json:** {len(ar_keys)}\n")
        md.write(f"**Total keys in en.json:** {len(en_keys)}\n\n")
        
        md.write("## ⚠️ Missing Translations\n")
        md.write("> [!WARNING]\n> These keys are used in the Dart code (e.g., `context.tr('key')`) but are missing in the translation files.\n\n")
        
        md.write("### Missing in `ar.json`\n")
        if missing_in_ar:
            for k in sorted(missing_in_ar):
                md.write(f"- `{k}`\n")
        else:
            md.write("No missing keys in Arabic translation.\n")
            
        md.write("\n### Missing in `en.json`\n")
        if missing_in_en:
            for k in sorted(missing_in_en):
                md.write(f"- `{k}`\n")
        else:
            md.write("No missing keys in English translation.\n")
            
        md.write("\n## 🗑 Unused Translations\n")
        md.write("> [!TIP]\n> These keys exist in the translation files but are never called using `.tr('key')` in the code. You might want to clean them up.\n\n")
        
        md.write("### Unused in `ar.json`\n")
        if unused_ar:
            for k in sorted(unused_ar):
                md.write(f"- `{k}`\n")
        else:
            md.write("No unused keys.\n")
            
        md.write("\n### Unused in `en.json`\n")
        if unused_en:
            for k in sorted(unused_en):
                md.write(f"- `{k}`\n")
        else:
            md.write("No unused keys.\n")
            
        md.write("\n## 🈳 Empty Translations\n")
        md.write("> [!IMPORTANT]\n> These keys exist but have empty strings as values.\n\n")
        
        md.write("### Empty in `ar.json`\n")
        if empty_ar:
            for k in sorted(empty_ar):
                md.write(f"- `{k}`\n")
        else:
            md.write("No empty translations.\n")
            
        md.write("\n### Empty in `en.json`\n")
        if empty_en:
            for k in sorted(empty_en):
                md.write(f"- `{k}`\n")
        else:
            md.write("No empty translations.\n")

if __name__ == '__main__':
    main()
