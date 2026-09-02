import os
import re

lib_dir = r"d:\Ayusync\frontend\nurse\lib"

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8') as file:
                content = file.read()
            
            original = content
            
            # Remove const from common widgets that were modified to use Theme.of(context)
            content = content.replace('const Text(', 'Text(')
            content = content.replace('const Icon(', 'Icon(')
            content = content.replace('const Center(', 'Center(')
            content = content.replace('const Padding(', 'Padding(')
            content = content.replace('const Row(', 'Row(')
            content = content.replace('const Column(', 'Column(')
            content = content.replace('const Expanded(', 'Expanded(')
            content = content.replace('const SizedBox(', 'SizedBox(') # Just to be absolutely safe if it contains a child somehow
            
            if content != original:
                with open(path, 'w', encoding='utf-8') as file:
                    file.write(content)
                print(f"Fixed const in {f}")

print("Done fixing all constants!")
