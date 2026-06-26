Param(
    [string]$BackendPath = "..\backend",
    [int]$Port = 8000
)

if (-not (Get-Command php -ErrorAction SilentlyContinue)) {
    Write-Error "php غير موجود في PATH. ثبت PHP وتأكد أن 'php' متاح في المسار."
    exit 1
}

if (-not (Test-Path $BackendPath)) {
    $prompt = Read-Host "مسار المشروع الخلفي '$BackendPath' غير موجود. أدخله الآن أو اضغط Enter للإلغاء"
    if ($prompt) { $BackendPath = $prompt } else { Write-Error "تم الإلغاء."; exit 1 }
}

Push-Location $BackendPath
Write-Output "تشغيل الخادم: php artisan serve --host=0.0.0.0 --port=$Port"
php artisan serve --host=0.0.0.0 --port=$Port
Pop-Location
