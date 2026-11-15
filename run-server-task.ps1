# Wrapper cho Task Scheduler: chay server + redirect log (ca stdout va stderr)
& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File 'E:\Nha-Em\phong-chat\server.ps1' *> 'E:\Nha-Em\phong-chat\server-log2.txt'
