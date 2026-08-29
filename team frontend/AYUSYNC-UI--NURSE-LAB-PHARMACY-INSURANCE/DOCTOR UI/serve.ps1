param([int]$Port = 8081)

$listener = New-Object System.Net.HttpListener

# Use '*' to bind to all available IP addresses (0.0.0.0).
# NOTE: This requires running PowerShell as an Administrator on Windows.
# If it fails, we catch the exception and instruct the user.
try {
    $listener.Prefixes.Add("http://*:$Port/")
    $listener.Start()
} catch {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host " ERROR: Could not start the server on http://*:$Port/" -ForegroundColor Red
    Write-Host " To make the server accessible from your phone (LAN), Windows requires" -ForegroundColor Red
    Write-Host " this script to be run as an Administrator." -ForegroundColor Red
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host " Attempting to fallback to localhost only..." -ForegroundColor Yellow
    
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$Port/")
    $listener.Start()
    $localOnly = $true
}

$ipAddresses = (Get-NetIPAddress -AddressFamily IPv4 -Type Unicast | Where-Object { $_.InterfaceAlias -notmatch 'Loopback' }).IPAddress

Write-Host "========================================="
Write-Host "  AyuSync Doctor UI Server Started! "
Write-Host "========================================="
Write-Host ""

if ($localOnly) {
    Write-Host "  Available ONLY on this computer:" -ForegroundColor Yellow
    Write-Host "  http://localhost:$Port/" -ForegroundColor Yellow
} else {
    Write-Host "  Available on this computer:"
    Write-Host "  http://localhost:$Port/"
    Write-Host ""
    Write-Host "  Available on your network (LAN):"
    foreach ($ip in $ipAddresses) {
        Write-Host "  http://${ip}:$Port/" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "  (To stop the server later, just close this terminal window)"
Write-Host "========================================="

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $path = $request.Url.LocalPath
        if ($path -eq "/") { $path = "/index.html" }
        
        $fullPath = Join-Path $PWD.Path $path
        
        if (Test-Path $fullPath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($fullPath).ToLower()
            $mimeType = switch ($ext) {
                ".html" { "text/html" }
                ".css"  { "text/css" }
                ".js"   { "application/javascript" }
                ".json" { "application/json" }
                ".png"  { "image/png" }
                ".jpg"  { "image/jpeg" }
                ".svg"  { "image/svg+xml" }
                default { "application/octet-stream" }
            }
            
            $bytes = [System.IO.File]::ReadAllBytes($fullPath)
            $response.ContentType = $mimeType
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $errorMsg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $response.ContentLength64 = $errorMsg.Length
            $response.OutputStream.Write($errorMsg, 0, $errorMsg.Length)
        }
        $response.Close()
    }
} finally {
    $listener.Stop()
}
