@echo off
echo Starting Ayusync Doctor Portal...

:: Check if the user wants web or desktop
echo Select platform:
echo 1) Windows Desktop (Recommended - Faster, no CanvasKit/CORS errors)
echo 2) Chrome Web (using HTML renderer to avoid CanvasKit fetch errors)
set /p choice="Enter 1 or 2: "

if "%choice%"=="1" (
    echo Launching on Windows...
    flutter run -d windows
) else (
    echo Launching on Chrome (HTML Renderer)...
    flutter run -d chrome --web-renderer html
)
