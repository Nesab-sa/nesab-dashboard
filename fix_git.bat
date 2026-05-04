@echo off
cd /d "C:\Users\Admin\OneDrive\Desktop\Desktop-dashboard"
if exist ".git\index.lock" del /f /q ".git\index.lock"
git add -A
git status --short
git commit -m "redesign profit margins page with 11 banks 8 products and color coding"
git push origin main
echo DONE
pause
