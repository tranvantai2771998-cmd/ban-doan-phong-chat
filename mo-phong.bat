@echo off
title Phong chung Bang Doan
start "PHONG-CHAT-SERVER" "C:\Users\DELL\AppData\Local\Microsoft\WindowsApps\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File "E:\Nha-Em\phong-chat\server.ps1"
start "EM-WORKER" "C:\Users\DELL\AppData\Local\Microsoft\WindowsApps\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File "E:\Nha-Em\phong-chat\em-worker.ps1"
start "" http://localhost:8787
start "TELEGRAM-BRIDGE" "C:\Users\DELL\AppData\Local\Microsoft\WindowsApps\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File "E:\Nha-Em\phong-chat\bridge-telegram-room.ps1"
