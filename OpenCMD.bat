@echo off
title ADB and Fastboot++
color 0a

REM ---------------------------------------------------------------------------
REM  Ensure platform-tools is available before opening the console.
REM  If it is missing, _bootstrap.bat will prompt the user to download it,
REM  extract only the required files and clean up the rest.
REM ---------------------------------------------------------------------------
call "%~dp0_bootstrap.bat"
if errorlevel 1 (
    echo.
    echo Failed to prepare platform-tools. Aborting.
    echo.
    pause >nul
    exit /B 1
)

REM Add the folder to this session's PATH so adb / fastboot are available
REM even if the toolkit does not export them.
set "PATH=%PATH%;%~dp0platform-tools"

cmd.exe
