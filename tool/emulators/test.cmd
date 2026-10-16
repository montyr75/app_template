@echo off
rem Runs integration tests on Windows desktop against fresh Auth and Firestore emulators, then stops any emulator
rem process left behind. Usage: tool\emulators\test.cmd [paths...]   (default: integration_test)
rem Exits with the test run's exit code (1 when any file failed). The project id below is the demo id until
rem `flutterfire configure` and `firebase use` name the real one; change it here and in lib\dev\dev_config.dart.
rem
rem Each test file gets its own `flutter test <file> -d windows`: flutter_tools keeps ONE log reader per desktop device
rem and closes it when the first app exits, so a multi-file run fails from the second file on with "Error waiting for a
rem debug connection: The log reader stopped unexpectedly". emulators:exec therefore runs this script again in its
rem --each mode, which loops over the files (a directory expands to its *_test.dart files) inside one emulator session.
rem The exit code lives in EXIT_RC, never RC: CMake reads an RC variable as the resource compiler, so a stray RC=0
rem fails every Windows build that has no CMake cache yet (a fresh clone, a worktree, after `flutter clean`).
setlocal EnableExtensions
if "%~1"=="--each" goto each

pushd "%~dp0..\.."
call firebase emulators:exec --only auth,firestore --project demo-app-template "tool\emulators\test.cmd --each %*"
set "EXIT_RC=%ERRORLEVEL%"
call "%~dp0stop.cmd"
popd
exit /b %EXIT_RC%

:each
shift
set "EXIT_RC=0"
set "ANY="
:nextArg
if "%~1"=="" goto argsDone
set "ANY=1"
call :runPath "%~1"
shift
goto nextArg
:argsDone
if not defined ANY call :runPath integration_test
exit /b %EXIT_RC%

:runPath
set "TARGET=%~1"
set "TARGET=%TARGET:/=\%"
if exist "%TARGET%\" (
  for /r "%TARGET%" %%F in (*_test.dart) do call :runFile "%%F"
) else (
  call :runFile "%TARGET%"
)
exit /b 0

:runFile
echo test.cmd: flutter test %~1 -d windows
call flutter test "%~1" -d windows
if errorlevel 1 set "EXIT_RC=1"
exit /b 0
