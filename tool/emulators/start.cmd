@echo off
rem Starts the Auth and Firestore emulators with the Emulator UI (http://127.0.0.1:4000) for the project named below
rem (the demo id until `flutterfire configure` and `firebase use` name the real one; change it here and in
rem lib\dev\dev_config.dart with them). Single-project mode: local only, nothing reaches a live project. Stop with
rem Ctrl+C, then stop.cmd if a port stays taken.
setlocal
pushd "%~dp0..\.."
call firebase emulators:start --only auth,firestore,ui --project demo-app-template
set "EXIT_RC=%ERRORLEVEL%"
popd
exit /b %EXIT_RC%
