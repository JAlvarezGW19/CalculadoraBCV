
import os
import json

# Files suspected to be corrupted (UTF-8 bytes interpreted as Latin-1/Windows-1252)
files_to_fix = [
    "app_ar.arb",
    "app_hi.arb",
    "app_ja.arb",
    "app_ko.arb",
    "app_ru.arb",
    "app_tr.arb", 
    "app_vi.arb",
    "app_zh.arb",
    "app_pt.arb",
    "app_it.arb",
    "app_de.arb",
    "app_es.arb"
]

def fix_text(text):
    if not isinstance(text, str):
        return text
    
    # Heuristic: If we can encode as latin-1 and valid utf-8 comes out, it was likely Mojibake
    try:
        # Build reverse map for Windows-1252 special characters to their byte values
        # This handles characters like 'š' (U+0161) which maps to 0x9A in CP1252
        cp1252_chars = {}
        for i in range(128, 160): # 0x80 to 0x9F
             try:
                 char = bytes([i]).decode('cp1252')
                 # If it decoded to something other than the control char itself
                 if ord(char) != i:
                     cp1252_chars[char] = chr(i)
             except:
                 pass
        
        # Replace CP1252 display characters with their latin-1 control code equivalents
        temp_text = text
        for char, replacement in cp1252_chars.items():
            temp_text = temp_text.replace(char, replacement)
            
        # now encode as latin1 (which allows direct 00-FF mapping) and decode as utf-8
        fixed = temp_text.encode('latin1').decode('utf-8')
        
        # Safety check: if the "fixed" text is drastically shorter or empty unexpectedly, abort
        if len(fixed) == 0 and len(text) > 0:
            return text
            
        return fixed
    except (UnicodeEncodeError, UnicodeDecodeError):
        # If it contains characters that are NOT in Latin-1, it means it wasn't purely 
        # "UTF-8 read as Latin-1" (or it's already correct/mixed).
        # In this case, we leave it alone.
        return text

def process_file(filename):
    path = os.path.join("lib/l10n", filename)
    if not os.path.exists(path):
        print(f"Skipping {filename}: Not found")
        return

    print(f"Processing {filename}...")
    
    try:
        with open(path, 'r', encoding='utf-8-sig') as f:
            data = json.load(f)
            
        fixed_data = {}
        changes_count = 0
        
        for key, value in data.items():
            if key == "@@locale": 
                fixed_data[key] = value
                continue
                
            fixed_val = fix_text(value)
            fixed_data[key] = fixed_val
            
            if fixed_val != value:
                changes_count += 1
                # print(f"  Fixed {key}: {value} -> {fixed_val}")
                
        if changes_count > 0:
            print(f"  Saving {filename} with {changes_count} fixes.")
            with open(path, 'w', encoding='utf-8') as f:
                json.dump(fixed_data, f, ensure_ascii=False, indent=2)
        else:
            print(f"  No changes needed for {filename}")
            
    except Exception as e:
        print(f"  Error processing {filename}: {e}")

if __name__ == "__main__":
    for f in files_to_fix:
        process_file(f)
