import os
import re

files = [
    "lib/screens/home_visits_screen.dart",
    "lib/screens/lab_screen.dart",
    "lib/screens/login_screen.dart",
    "lib/screens/messages_screen.dart",
    "lib/screens/reports_screen.dart",
    "lib/screens/tasks_screen.dart"
]

for f in files:
    path = os.path.join(r"d:\Ayusync\frontend\nurse", f)
    with open(path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    content = content.replace('const Center(child: Text(', 'Center(child: Text(')
    content = content.replace('child: const Center(child: Text(', 'child: Center(child: Text(')
    content = content.replace('const Center(child: Padding(', 'Center(child: Padding(')
    content = content.replace('? const Center(child: Text(', '? Center(child: Text(')
    content = content.replace('const Text(', 'Text(')
    
    with open(path, 'w', encoding='utf-8') as file:
        file.write(content)
print("Fixed constants")
