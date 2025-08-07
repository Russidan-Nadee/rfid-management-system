@echo off
echo Stopping backend server...
taskkill /f /im node.exe /t >nul 2>&1

echo Waiting for processes to stop...
timeout /t 3 /nobreak >nul

echo Regenerating Prisma client...
npx prisma generate

echo Starting backend server...
start /min cmd /c "npm run dev"

echo Backend restarted with updated Prisma client!
pause