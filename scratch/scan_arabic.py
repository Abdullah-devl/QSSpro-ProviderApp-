import os
import re

def main():
    base_dir = r"c:\Users\Al_Hamed\Desktop\Flutter projctes\GardeionProjcts\provider"
    lib_dir = os.path.join(base_dir, "lib")
    
    # regex for arabic characters inside quotes
    pattern = re.compile(r"""(['"])([^'"]*[\u0600-\u06FF]+[^'"]*)\1""")
    
    results = []
    
    for root, _, files in os.walk(lib_dir):
        for file in files:
            if file.endswith(".dart"):
                file_path = os.path.join(root, file)
                with open(file_path, "r", encoding="utf-8") as f:
                    for i, line in enumerate(f, 1):
                        if line.strip().startswith("//"):
                            continue # skip comments
                        matches = pattern.findall(line)
                        for match in matches:
                            results.append(f"{file}:{i} - {match[1]}")
                            
    out_file = r"C:\Users\Al_Hamed\.gemini\antigravity\brain\11f03f21-ecf6-4593-9c72-e35d0bafc70b\arabic_strings_report.md"
    with open(out_file, "w", encoding="utf-8") as md:
        md.write("# Hardcoded Arabic Strings in Code\n\n")
        if not results:
            md.write("No hardcoded Arabic strings found inside quotes.\n")
        else:
            md.write(f"Found {len(results)} instances of hardcoded Arabic strings:\n\n")
            for res in results:
                md.write(f"- `{res}`\n")

if __name__ == '__main__':
    main()
