import os
import re

lib_dir = r"d:\Ayusync\frontend\nurse\lib"

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart') and f != 'app_theme.dart':
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8') as file:
                content = file.read()
            
            original = content
            
            # Remove `const ` before `TextStyle` if it contains AppTheme.textSecondary or bgMain
            # It's safer to just remove all `const TextStyle` and replace with `TextStyle` 
            # to avoid invalid const expressions when we inject Theme.of(context)
            content = re.sub(r'const\s+TextStyle', 'TextStyle', content)
            
            # Remove `const ` before `Icon` if it contains AppTheme.textSecondary
            content = re.sub(r'const\s+Icon\(', 'Icon(', content)
            
            # Remove `color: AppTheme.textDark,` or `color: AppTheme.textDark`
            content = re.sub(r'color:\s*AppTheme\.textDark\s*,?', '', content)
            
            # Replace AppTheme.textSecondary with Theme.of(context).hintColor
            content = content.replace('AppTheme.textSecondary', 'Theme.of(context).hintColor')
            
            # Replace AppTheme.bgMain with Theme.of(context).scaffoldBackgroundColor
            content = content.replace('AppTheme.bgMain', 'Theme.of(context).scaffoldBackgroundColor')
            
            if original != content:
                with open(path, 'w', encoding='utf-8') as file:
                    file.write(content)
                print(f"Updated {f}")

print("Done")
