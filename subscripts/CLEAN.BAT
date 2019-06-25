@echo off

:: ************************
:: Script: A sub script of Sneaky Win Intruder Type I
::         After working with a PC, erase the traces
:: Refer to Swi.bat and Readme.txt
:: ************************

:: Supports offline clean up since Swi 1.5

if not "%OS%"=="Windows_NT" echo "Windows version not supported" && goto :EOF

SETLOCAL ENABLEDELAYEDEXPANSION

:: debugging options
:: set debug=1
:: set debug2=1
if defined debug echo :: Debugging mode 1 is ON.
if defined debug2 echo on&set debug=1&echo :: Debugging mode 2 is ON.

:: change directory 1 (required when used online since _choiceMulti.bat is in \Swi)
set userwindir=%windir%
cd /d "%userwindir%\system32"
set PATH=%PATH%;%cd%\Swi
set PATHEXT=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC

:start
cls
echo.
echo                          =================
echo                             Swi Removal
echo                          =================
echo.
echo :: This script will clean up what is left by Sneaky Win Intruder
echo.
echo :: Please take note of the following before continuing:
echo.
echo    - Do NOT run this by sethc.exe (or utilman.exe)
echo    - For Vista and later OS with UAC, run this as administrator
echo    - Both online and offline clean-up modes are supported
echo      . Only ONLINE mode deletes user account and profile
echo      . Use OFFLINE when only 'swi' but not 'adduser' is applied
echo _____________________________________________________________________
echo.
echo :: You have 2 choices:
echo.
echo    1  Target Windows directory is %userwindir% [Change]
echo.
echo    2. Start clean-up
echo.
_choiceMulti.bat /msg "Please select: [1,2] " /errorlevel
if %errorlevel%==1 goto start2
if %errorlevel%==0 goto _menuChooseWin

:start2

echo.
echo #  Comparing target Windows and local Windows
echo.
if /i "%windir:\=%" EQU "%userwindir:\=%" (
	set online=1
	echo _____________________________________________________________________________
	echo 
	echo #  INFO: You've specified an ONLINE Windows: %userwindir%
) else (
	set offline=1
	echo _____________________________________________________________________________
	echo 
	echo #  INFO: You've specified an OFFLINE Windows: %userwindir%
)


:: detects which Swi type has user applied on target.
if exist "%userwindir%\Swi\typeI" set typeI=1
if exist "%userwindir%\Swi\typeII" set typeII=1

echo.
if not defined typeII (
	if defined typeI (
		call _choiceYN ":: Swi: Type I detected. Apply clean-up? [Y,N] " N 60
	) else (
		call _choiceYN ":: Swi doesn't seem applied on target. Are you sure it is correct? [Y,N] " N 60
	)
) else (
	if defined typeI (
		call _choiceYN ":: Swi: Type I and II detected. Apply clean-up? [Y,N] " N 60
	)
)
if %errorlevel% NEQ 0 goto start

:: change directory 2 (in case user specified another windows, an offline one)
cd /d "%userwindir%\system32"

echo.
echo #  Checking if required executables exists.
echo.

attrib >nul 2>&1 
if %errorlevel% EQU 9009 (
	echo _____________________________________________________________________________	
	echo.
	echo #  INFO: attrib.exe not in PATH. Permission check won't be accurate.
	echo.
	echo #  To be continued in a few secs...
	echo.
	(timeout /T 6 >nul 2>&1) || (ping -n 6 -l 2 127.0.0.1 >nul 2>&1)
)

find >nul 2>&1 
if %errorlevel% EQU 9009 (
	echo _____________________________________________________________________________	
	echo.
	echo #  INFO: find.exe not in PATH. Permission check won't be accurate.
	echo.
	echo #  To be continued in a few secs...
	echo.
	(timeout /T 6 >nul 2>&1) || (ping -n 6 -l 2 127.0.0.1 >nul 2>&1)
)
echo.
echo #  Checking for administrator rights.
echo.
:: this check is always userwindir, not userwindir!
attrib %windir%\system32 -h | find /i "system32"
if %errorlevel% EQU 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  FATAL ERROR: Not an administrator on current Windows.
	echo                 For Vista/7 with UAC, run this as administrator.
	echo.
	echo #  Alternatively, run this from Windows PE.
	echo.
	goto end
)

echo.
echo #  Detecting if sethc.backup exists
echo.
dir /tc /od sethc.backup.*
if %errorlevel% NEQ 0 (
	echo.
	echo #  INFO: sethc.backup.* not found in %userwindir%\system32.
	echo.
	echo #  Are you sure Sneaky Win Intruder was applied?
	echo.
) else (
	echo.
	echo #  Pick the earliest created sethc.backup in case there's more than 1
	echo.
	@for /f "usebackq" %%i in (`dir /b /tc /od sethc.ba*`) do (ren "%%i" sethc.backup >nul 2>&1)
)

:: utilman
echo.
echo #  Detecting if utilman.backup exists
echo.
dir /tc /od utilman.backup.*
if %errorlevel% EQU 0 (
	set utilman=1
	echo.
	echo #  Pick the earliest created utilman.backup in case there's more than 1
	echo.
	@for /f "usebackq" %%i in (`dir /b /tc /od utilman.ba*`) do (ren "%%i" utilman.backup >nul 2>&1)
)


echo.
echo #  Detecting if either taskkill.exe or wkill.exe exists.
echo.

taskkill >nul 2>&1
if %errorlevel% EQU 9009 (
	echo.
	echo #  INFO: taskkill.exe not found in PATH.
	echo.
	goto wkill
)

echo.
echo #  Stopping all instances of sethc.exe with taskkill.exe
echo.
taskkill /F /im sethc.exe
if %errorlevel% NEQ 0 (
	echo.
	echo #  INFO: Please make sure sethc.exe is NOT running for proper operation.
	echo.
)

if defined utilman (
	echo.
	echo #  Stopping all instances of utilman.exe with taskkill.exe
	echo.
	taskkill /F /im utilman.exe
	@if !errorlevel! NEQ 0 (
		echo.
		echo #  INFO: Please make sure sethc.exe is NOT running for proper operation.
		echo.
	)
)

goto restore

:wkill
wkill >nul 2>&1
if %errorlevel% EQU 9009 (
	echo _____________________________________________________________________________
	echo 
	echo #  WARNING: wkill.exe also not found in PATH.
	echo.
	echo #  ERROR: You don't have either taskkill.exe or wkill.exe in PATH.
	echo.
	echo    Get taskkill.exe from XP Pro, or download wkill.exe from http://alter.org.ua/en/
	echo.
	echo    You may exit and fix the problem first, or continue executing despite this error.
	echo.
	pause
	goto restore
)
echo.
echo #  Stopping all instances of sethc.exe with wkill.exe
echo.
:: The reason to use wkill instead of pskill is it can delete multiple instances
wkill -a -n sethc.exe

if defined utilman (
	echo.
	echo #  Stopping all instances of utilman.exe with wkill.exe
	echo.
	wkill -a -n utilman.exe
)

:restore

echo.
echo #  Restoring sethc.exe
echo.
del "%userwindir%\System32\sethc.exe" /q /f

if defined utilman del "%userwindir%\System32\utilman.exe" /q /f

echo.
echo #  First try the XP way
echo.
if exist "%userwindir%\System32\dllcache\sethc.exe" (
	copy "%userwindir%\System32\dllcache\sethc.exe" "%userwindir%\System32\sethc.exe" /y
	@if not defined utilman goto delet
)

if defined utilman (
	@if exist "%userwindir%\System32\dllcache\utilman.exe" (
		copy "%userwindir%\System32\dllcache\utilman.exe" "%userwindir%\System32\utilman.exe" /y
		goto delet
	)
)

echo.
echo #  Secondly try the Vista/7 way (Please wait...)
echo.
for /f "usebackq delims==" %%i in (`dir /b /s %userwindir%\winsxs\*sethc.exe`) do (
	:: copy "%%i" "%userwindir%\System32\sethc.exe" /y
	fsutil hardlink create "%userwindir%\System32\sethc.exe" "%%i"
	@if exist "%userwindir%\System32\sethc.exe" @if not defined utilman goto delet
)

if defined utilman (
	for /f "usebackq delims==" %%i in (`dir /b /s %userwindir%\winsxs\*utilman.exe`) do (
	:: copy "%%i" "%userwindir%\System32\utilman.exe" /y
	fsutil hardlink create "%userwindir%\System32\utilman.exe" "%%i"
	@if exist "%userwindir%\System32\utilman.exe" goto delet
	)
)


echo.
echo #  If all fails, restore from backup
echo.
ren "%userwindir%\System32\sethc.backup" "sethc.exe"
if defined utilman ren "%userwindir%\System32\utilman.backup" "utilman.exe"

:delet

:: ensure all *.backup.xxxx files are deleted, if case main script was run more than 1 time.

del sethc.bac* /f /q > nul 2>&1
if defined utilman del utilman.bac* /f /q > nul 2>&1

:: below is for online only, skipped if OFFLINE mode is set
:: OFFLINE doesn't delete user account or use profile; just files.

if defined offline goto offlineContinue

echo.
echo #  Deleting temporary user account
echo.
net user temp /del
if %errorlevel% NEQ 0 (
	echo.
	echo #  INFO: Cannot delete user.
	echo.
	echo #  Showing a list of users. If it doesn't list "temp" then it was deleted:
	echo.
	net user
	echo.
	pause
)

:: auto logon should not be enabled otherwise this batch wouldnt be needed to break into target system
echo.
echo #  Deleting last logon user information if auto logon is not configured
echo.

for /f "usebackq tokens=3" %%i in (`reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon 2^>nul`) do set result=%%i
if not "%result%" GEQ "1" (reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\WinLogon" /v "DefaultUserName" /t REG_SZ /d "" /f)

echo.
echo #  Scheduling session manager to clean up part of user profile at next boot
echo.

:: accept eula of movefile
reg add "HKCU\Software\Sysinternals\Movefile" /v "EulaAccepted" /t REG_DWORD /d 0x1 /f

:: most files are deleted this way, only leaving out directories and irconcache, etc.
pushd "%userprofile%" >nul 2>&1
cd.. >nul 2>&1
cd temp >nul 2>&1
for /f "usebackq tokens=* delims=" %%i in (`dir /a /b /s`) do movefile "%%i" "" >nul 2>&1
popd

:: with the help of startx /b (hidden)
echo.
echo #  Setting up RunOnce to delete leftovers in the background at next logon
echo.
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v "temp1" /t REG_SZ /d "\"%userwindir%\System32\startx.exe\" \"\" /b \"%userwindir%\System32\clean_next_boot.bat\"" /f

echo.
echo #  Deleting scripts and leftovers
echo.
:: 'if exist' to prevent error due to user may run either type I or type II only and some batch may not be copied
if exist "%userwindir%\system32\adduser.bat" del "%userwindir%\system32\adduser.bat" /f /q
if exist "%userwindir%\system32\adduser1.bat" del "%userwindir%\system32\adduser1.bat" /f /q
rd "%userwindir%\Swi" /q /s
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                          ==============================
echo                             OPERATON ALMOST COMPLETE
echo                          ==============================
echo.
echo #  Swi removal is ALMOST complete. So far, user account was deleted, sethc.exe
echo    [utilman.exe] restored, last logon user erased (if AutoAdminLogon exists)
echo.
echo #  The rest will carry on in the background at the next logon of the user (not
echo    you). By then, UAC will be re-enabled (only if it was initially on), user
echo    profile and the rest of files that was left over will be deleted.
echo.
echo #  If he is not administrator part of it that uses RunOnce would fail:
echo.
echo     - In case it fails, these will be left: clean_next_boot.bat, startx.exe in
echo       system32; a small residue of 'temp' user profile -- the rest deleted.
echo.
echo #  Script is going to delete itself now. (Any error means success.)
echo.
pause
(del clean.bat /f /q >nul 2>&1) & (del clean1.bat /f /q >nul 2>&1)
goto end

:offlineSkip

:: OFFLINE mode is for cleaning after applying Swi before applying adduser.bat.
:: that means no user account and user profile cleaning will be provided.

if exist "%userwindir%\system32\startx.exe" del "%userwindir%\system32\startx.exe" /f /q
if exist "%userwindir%\system32\clean_next_boot.bat" del "%userwindir%\system32\clean_next_boot.bat" /f /q
if exist "%userwindir%\system32\adduser.bat" del "%userwindir%\system32\adduser.bat" /f /q
if exist "%userwindir%\system32\adduser1.bat" del "%userwindir%\system32\adduser1.bat" /f /q
if exist "%userwindir%\system32\clean.bat" del "%userwindir%\system32\clean.bat" /f /q
if exist "%userwindir%\system32\clean1.bat" del "%userwindir%\system32\clean1.bat" /f /q
rd "%userwindir%\Swi" /q /s

:end
ENDLOCAL
goto :EOF

:: subroutines and procedures

:_menuChooseWin
if not defined debug cls
echo.
echo :: Select how to specify target Windows:
echo.
echo    1. Automatically search for Windows
echo.
echo    2. Manually specify path
echo.
echo    A. Go back
echo.

call _choiceMulti.bat /msg ":: Please make a choice: [1,2,A] " /button 12A /errorlevel 3
if "%errorlevel%"=="3" goto menuMain
if "%errorlevel%"=="2" echo ______________________________________________________________&goto manual
if "%errorlevel%"=="1" goto auto

:manual
echo.
echo :: What is the target Windows directory? e.g. E:\Windows
echo.
set /p userwindir=:: Enter here, or go back (A): 

:: removing quotes
for %%i in (%userwindir%) do set userwindir=%%~i

if /i "%userwindir%"=="back" goto _menuChooseWin
if /i "%userwindir%"=="a" goto _menuChooseWin
if /i "%userwindir%"=="s" goto auto
if /i "%userwindir%"=="search" goto auto
:: some input checking
echo %userwindir% | find /i ":\" >nul 2>&1
if %errorlevel% NEQ 0 cls&goto manual
goto start2

:auto
if not defined debug cls
:: dir scan 1
set count=0
for %%i in (B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
if exist %%i:\Windows.old/Windows\nul (set /a count+=1 && set SWI!count!=!count!=%%i:\Windows.old\Windows)
if exist %%i:\WinNT\nul (set /a count+=1 && set SWI!count!=!count!=%%i:\WinNT)
if exist %%i:\Windows\nul (set /a count+=1 && set SWI!count!=!count!=%%i:\Windows)
)
:: dir scan 2
if not defined debug cls
set num=0
for /f "usebackq" %%i in (`set SWI`) do set /a num+=1
if not "%num%"=="0" goto foundWin
echo 
echo ** ERROR: Cannot find Windows installation. Please specify it manually.
echo.
pause
goto start

:foundWin
echo.
echo :: Sneaky Win Intruder has found Windows installation(s).
echo.

for /f "usebackq delims== tokens=1-3" %%i in (`set SWI`) do echo    %%j. %%k&echo.

:: make a "go back" option as the last choice number
set /a numPlus=%num%+1
echo    A. Go back
echo.

:: create %butMinus% for nothin but just the A button as Go back, instead of 1234...
for /l %%i in (1,1,%num%) do set butMinus=!butMinus!%%i
call _choiceMulti /msg ":: Please make a choice: " /button %butMinus%A /errorlevel %numPlus%

:: check if user specifies 'go back'
if "%errorlevel%" EQU "%numPlus%" goto _menuChooseWin

set chosenwin=%errorlevel%
for /f "usebackq delims== tokens=1-3" %%i in (`set SWI%chosenwin%`) do set userwindir=%%k

goto start2
