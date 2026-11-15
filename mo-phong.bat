@echo off
title Phong chung Bang Doan
start "PHONG-CHAT-SERVER" /min cmd /c "node E:\Nha-Em\phong-chat\server.js"
start "EM-WORKER" /min cmd /c "powershell -NoProfile -ExecutionPolicy Bypass -File E:\Nha-Em\phong-chat\em-worker.ps1"
start "TELEGRAM-BRIDGE" /min cmd /c "powershell -NoProfile -ExecutionPolicy Bypass -File E:\Nha-Em\phong-chat\bridge-telegram-room.ps1"
start "" http://localhost:8788
