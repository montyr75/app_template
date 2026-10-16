@echo off
rem Stops the emulator processes still listening on the emulator ports (UI 4000, hub 4400, logging 4500,
rem Firestore 8080, Auth 9099, Firestore websocket 9150). On Windows the Firestore emulator's java.exe can outlive
rem `firebase emulators:exec` and hold 8080. Only java and node processes (what the emulators run as) are stopped;
rem anything else on those ports is reported and left alone.
setlocal
pushd "%~dp0..\.."
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ports = 4000,4400,4500,8080,9099,9150; $ids = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $ports -contains $_.LocalPort } | Select-Object -ExpandProperty OwningProcess -Unique; foreach ($id in $ids) { $proc = Get-Process -Id $id -ErrorAction SilentlyContinue; if (-not $proc) { continue }; if (@('java', 'node') -contains $proc.ProcessName) { Write-Host ('stop.cmd: stopping ' + $proc.ProcessName + ' (pid ' + $id + ')'); Stop-Process -Id $id -Force } else { Write-Host ('stop.cmd: leaving ' + $proc.ProcessName + ' (pid ' + $id + '), not an emulator process') } }"
popd
exit /b 0
