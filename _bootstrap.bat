@echo off
REM ============================================================================
REM  _bootstrap.bat - ADB & Fastboot++ (portable)
REM ----------------------------------------------------------------------------
REM  Responsibilities:
REM    1) Ensure .\platform-tools\adb.exe exists next to this script.
REM       - If missing, prompt the user to download the official ZIP from
REM         Google, extract ONLY the needed files, and delete the rest.
REM    2) Patch "Toolkit - Portable.bat" if it still references the legacy
REM       "ADB and Fastboot++ v1.1.1 Portable" folder, so it points to
REM       "%~dp0platform-tools" instead.
REM  This script is idempotent: if everything is already in place, it exits
REM  silently.
REM ============================================================================

setlocal EnableExtensions

set "ROOT=%~dp0"
set "PT_DIR=%ROOT%platform-tools"
set "ADB_EXE=%PT_DIR%\adb.exe"
set "TOOLKIT=%ROOT%Toolkit - Portable.bat"
set "DL_URL=https://dl.google.com/android/repository/platform-tools-latest-windows.zip"

REM ---------------------------------------------------------------------------
REM 1) Is platform-tools present?
REM ---------------------------------------------------------------------------
if exist "%ADB_EXE%" goto :patch_toolkit

echo.
echo ============================================================
echo   platform-tools (adb + fastboot) was not found
echo ============================================================
echo.
echo This toolkit requires the official Google package.
echo.
echo   1) Download it from:
echo        %DL_URL%
echo.
echo   2) Save the .zip file into this folder:
echo        %ROOT%
echo.
echo   3) Press any key to continue. Only the required files will
echo      be extracted; the rest will be deleted.
echo.
pause >nul

REM -- Look for the ZIP in the script folder --------------------------------
set "ZIP="
for %%F in ("%ROOT%platform-tools-latest-windows.zip") do if exist "%%~fF" set "ZIP=%%~fF"
if not defined ZIP for %%F in ("%ROOT%platform-tools*.zip") do if exist "%%~fF" set "ZIP=%%~fF"

if not defined ZIP (
    echo.
    echo ERROR: no platform-tools*.zip found in:
    echo   %ROOT%
    echo.
    pause
    endlocal & exit /B 1
)

echo.
echo Using archive: %ZIP%
echo Extracting to a temporary directory...

set "TMP=%TEMP%\adbpp_%RANDOM%_%RANDOM%"
mkdir "%TMP%" >nul 2>&1
if not exist "%TMP%" (
    echo ERROR: could not create %TMP%
    endlocal & exit /B 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "try { Expand-Archive -LiteralPath '%ZIP%' -DestinationPath '%TMP%' -Force -ErrorAction Stop } catch { Write-Error $_.Exception.Message; exit 1 }"

if errorlevel 1 (
    echo ERROR: failed to extract the ZIP.
    rmdir /S /Q "%TMP%" >nul 2>&1
    pause
    endlocal & exit /B 1
)

REM -- Locate the folder that contains adb.exe ------------------------------
set "SRC="
for /d %%D in ("%TMP%\*") do (
    if exist "%%~fD\adb.exe" set "SRC=%%~fD"
)
if not defined SRC if exist "%TMP%\adb.exe" set "SRC=%TMP%"

if not defined SRC (
    echo ERROR: adb.exe was not found inside the archive.
    rmdir /S /Q "%TMP%" >nul 2>&1
    pause
    endlocal & exit /B 1
)

echo Creating "%PT_DIR%"...
if not exist "%PT_DIR%" mkdir "%PT_DIR%" >nul 2>&1

REM -- Copy ONLY the required files -----------------------------------------
for %%F in (adb.exe fastboot.exe AdbWinApi.dll AdbWinUsbApi.dll source.properties) do (
    if exist "%SRC%\%%F" (
        echo   copying %%F
        copy /Y "%SRC%\%%F" "%PT_DIR%\%%F" >nul
    )
)

REM -- Cleanup --------------------------------------------------------------
rmdir /S /Q "%TMP%" >nul 2>&1
del /F /Q "%ZIP%" >nul 2>&1

if not exist "%ADB_EXE%" (
    echo.
    echo ERROR: platform-tools installation failed.
    pause
    endlocal & exit /B 1
)

echo.
echo platform-tools installed successfully at:
echo   %PT_DIR%
echo.

REM ---------------------------------------------------------------------------
REM 2) Patch the toolkit if it still uses the legacy folder
REM ---------------------------------------------------------------------------
:patch_toolkit
if not exist "%TOOLKIT%" goto :done

findstr /C:"ADB and Fastboot++ v1.1.1 Portable" "%TOOLKIT%" >nul 2>&1
if errorlevel 1 goto :done

echo Updating "%TOOLKIT%" to the new layout (platform-tools)...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$f = '%TOOLKIT%';" ^
  "$c = Get-Content -LiteralPath $f -Raw -Encoding UTF8;" ^
  "$c = $c.Replace('ADB and Fastboot++ v1.1.1 Portable','platform-tools');" ^
  "[System.IO.File]::WriteAllText($f, $c, [System.Text.UTF8Encoding]::new($false))"

if errorlevel 1 (
    echo WARNING: could not patch the toolkit automatically.
    echo Please edit it manually and replace:
    echo   set "path=%path%;%%~dp0ADB and Fastboot++ v1.1.1 Portable"
    echo with:
    echo   set "path=%path%;%%~dp0platform-tools"
    echo.
)

:done
endlocal
exit /B 0
