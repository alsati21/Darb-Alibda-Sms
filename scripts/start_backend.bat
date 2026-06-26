@echo off
set BACKEND_PATH=..\backend
set PORT=8000

where php >nul 2>nul
if ERRORLEVEL 1 (
  echo php غير موجود في PATH. ثبت PHP وتأكد أن 'php' متاح في المسار.
  exit /b 1
)

if not exist "%BACKEND_PATH%" (
  set /p BACKEND_PATH=مسار المشروع الخلفي غير موجود. أدخله الآن:
  if "%BACKEND_PATH%"=="" (
    echo تم الإلغاء.
    exit /b 1
  )
)

pushd "%BACKEND_PATH%"
echo تشغيل الخادم: php artisan serve --host=0.0.0.0 --port=%PORT%
php artisan serve --host=0.0.0.0 --port=%PORT%
popd
