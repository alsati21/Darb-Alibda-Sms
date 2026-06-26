**Start backend helper**

Files:
- `start_backend.ps1` — PowerShell helper that runs `php artisan serve --host=0.0.0.0 --port=8000`.
- `start_backend.bat` — Windows batch equivalent.

Usage examples:

PowerShell (recommended):

```powershell
# from project root
\scripts\start_backend.ps1
# or specify path and port
\scripts\start_backend.ps1 -BackendPath "C:\path\to\backend" -Port 8000
```

Command Prompt:

```cmd
scripts\start_backend.bat
```

Notes:
- تأكد أن PHP مثبت ومتوفر في PATH.
- إذا كان المشروع الخلفي Laravel، تأكد أن `artisan` موجود في المسار المحدد.
- السكربت يشغّل الخادم للاستماع على 0.0.0.0 ليكون متاحًا من الأجهزة الأخرى بالشبكة.
