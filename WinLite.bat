@echo off

rem Windows Lite Self Edition by Irochi (https://irochi.moe)
rem v2.7

cd /d "%~dp0" || (
    set "ErrorStr1=WinLite.bat을(를) 찾을 수 없습니다."
    set "ErrorStr2=파일을 정상적으로 다운로드했는지 확인해주세요."
    goto error
)
whoami /groups | findstr /i "S-1-16-12288" >nul
if %errorlevel% neq 0 (
    set "ErrorStr1=관리자 권한이 필요합니다."
    set "ErrorStr2=WinLite.bat 파일을 우클릭해 관리자 권한으로 실행해주세요."
    goto error
)

if not exist "install.wim" (
    set "ErrorStr1=install.wim을(를) 찾을 수 없습니다."
    set "ErrorStr2=순정 윈도우 이미지에서 파일을 가져와주세요."
    goto error
)

set "supported_build=26300"
set "win10_build=19045"
set "windows_build="
for /f "tokens=4 delims=. " %%a in ('dism /Get-WimInfo /WimFile:install.wim /index:1 ^| findstr "버전" ^| find /N /V "" ^| find "[2]"') do set "windows_build=%%a"

if "%windows_build%"=="" (
    set "ErrorStr1=install.wim 버전을(를) 찾을 수 없습니다."
    set "ErrorStr2=순정 윈도우 이미지에서 파일을 가져와주세요."
    goto error
)

if "%windows_build%"=="%win10_build%" (
    set "RequiredResources=resources\winlite_USER.reg resources\winlite_SOFTWARE.reg resources\LayoutModification.xml"
) else (
    set "RequiredResources=resources\start.bin resources\winlite_11_SOFTWARE.reg resources\winlite_11_USER.reg"
)
for %%f in (%RequiredResources%) do (
    if not exist "%%f" (
        set "ErrorStr1=%%f을(를) 찾을 수 없습니다."
        set "ErrorStr2=파일을 정상적으로 다운로드했는지 확인해주세요."
        goto error
    )
)

:check_installation
if not exist "resources\wimlib\wimlib-imagex.exe" goto download_wimlib

:check_build_version
if not "%windows_build%"=="%supported_build%" (
    title Windows Lite Self Edition by Irochi - Build Warning
    cls
    echo.
    echo.
    echo ──────────────────────────────
    echo.
    echo    Windows Lite Self Edition
    echo.
    echo   install.wim 빌드: %windows_build%
    echo   스크립트 지원 빌드: %supported_build%
    echo.
    echo   이 빌드는 더 이상 지원되지 않습니다.
    echo  예상치 못한 문제가 발생할 수 있습니다.
    echo.
    echo ──────────────────────────────
    echo.
    choice /c YN /m "계속 진행하시겠습니까"
    if errorlevel 2 exit
    color 07
)

:main
title Windows Lite Self Edition by Irochi (https://irochi.moe)
cls
echo.
echo.
echo ──────────────────────────────
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo  by Irochi (https://irochi.moe)
echo.
echo               v2.7
echo.
echo ──────────────────────────────
echo.
pause
cls
dism /Get-WimInfo /wimfile:install.wim
set "index="
set /p index=작업할 에디션의 인덱스 번호를 입력해주세요 :
call :validate_index
if "%index_ok%" equ "1" (
    goto mount
) else (
    goto main
)

:mount
title Windows Lite Self Edition by Irochi - Starting...
cls
echo.
echo.
echo ──────────────────────────────
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo     이미지를 마운트하는 중...
echo.
echo ──────────────────────────────
echo.
if exist "MOUNT" (
    echo 이전 마운트 정리 중...
    dism /unmount-wim /mountdir:MOUNT /discard
    timeout /t 2 >nul
    rmdir /s /q MOUNT >nul 2>&1
)
mkdir MOUNT
dism /mount-wim /wimfile:install.wim /index:%index% /mountdir:MOUNT
if %errorlevel% neq 0 (
    set "ErrorStr1=이미지 마운트에 실패했습니다."
    set "ErrorStr2=install.wim 파일이 손상되었거나 인덱스가 잘못되었습니다."
    goto error
)
goto remove_apps

:remove_apps
title Windows Lite Self Edition by Irochi - Removing apps...
cls
echo.
echo.
echo ──────────────────────────────
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo      앱을 삭제하는 중...
echo.
echo ──────────────────────────────
echo.
dism /image:MOUNT /Get-ProvisionedAppxPackages > temp_apps.txt
for %%A in (
    Microsoft.549981C3F5F10
    Microsoft.BingWeather
    Microsoft.GetHelp
    Microsoft.Getstarted
    Microsoft.HEIFImageExtension
    Microsoft.Microsoft3DViewer
    Microsoft.MicrosoftOfficeHub
    Microsoft.MicrosoftSolitaireCollection
    Microsoft.MicrosoftStickyNotes
    Microsoft.MixedReality.Portal
    Microsoft.MSPaint
    Microsoft.Office.OneNote
    Microsoft.People
    Microsoft.ScreenSketch
    Microsoft.SkypeApp
    Microsoft.VP9VideoExtensions
    Microsoft.Wallet
    Microsoft.WebMediaExtensions
    Microsoft.WebpImageExtension
    Microsoft.Windows.Photos
    Microsoft.WindowsAlarms
    Microsoft.WindowsCalculator
    Microsoft.WindowsCamera
    microsoft.windowscommunicationsapps
    Microsoft.WindowsFeedbackHub
    Microsoft.WindowsMaps
    Microsoft.WindowsSoundRecorder
    Microsoft.Xbox.TCUI
    Microsoft.XboxApp
    Microsoft.XboxGameOverlay
    Microsoft.XboxGamingOverlay
    Microsoft.XboxIdentityProvider
    Microsoft.XboxSpeechToTextOverlay
    Microsoft.YourPhone
    Microsoft.ZuneMusic
    Microsoft.ZuneVideo
    Clipchamp.Clipchamp
    Microsoft.BingNews
    Microsoft.GamingApp
    Microsoft.PowerAutomateDesktop
    Microsoft.Todos
    MicrosoftCorporationII.MicrosoftFamily
    MicrosoftCorporationII.QuickAssist
    MicrosoftTeams
    Microsoft.OutlookForWindows
    Microsoft.BingSearch
    Microsoft.Copilot
    Microsoft.Windows.CrossDevice
    Microsoft.Getstarted
    Microsoft.MSPaint
    Microsoft.OfficePushNotificationUtility
    Microsoft.Paint
    Microsoft.StartExperiencesApp
    Microsoft.Windows.DevHome
    Microsoft.Windows.Copilot
    Microsoft.Windows.Teams
    Microsoft.WindowsTerminal
    MSTeams
) do (
    for /f "tokens=3" %%C in ('findstr /i "%%A_" temp_apps.txt') do (
        echo 삭제 중: %%C
        dism /image:MOUNT /Remove-ProvisionedAppxPackage /PackageName:%%C >nul 2>&1
    )
)
del temp_apps.txt >nul 2>&1
goto remove_system_packages

:remove_system_packages
title Windows Lite Self Edition by Irochi - Removing System Packages...
cls
echo.
echo.
echo ──────────────────────────────
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo   시스템 패키지를 삭제하는 중...
echo.
echo ──────────────────────────────
echo.
dism /image:MOUNT /Get-Packages > temp_system_packages.txt
for %%D in (
    Microsoft-Windows-PowerShell-ISE-FOD-Package
    Microsoft-Windows-InternetExplorer-Optional-Package
    Microsoft-Windows-MediaPlayer-Package
    Microsoft-Windows-QuickAssist-Package
    Microsoft-Windows-StepsRecorder-Package
    Microsoft-Windows-WordPad-FoD-Package
    OpenSSH-Client-Package
    Microsoft-Windows-TabletPCMath-Package
) do (
    for /f "tokens=3 delims=: " %%F in ('findstr /i "%%D" temp_system_packages.txt') do (
        echo 삭제 중: %%F
        dism /image:MOUNT /Remove-Package /PackageName:%%F >nul 2>&1
    )
)
del temp_system_packages.txt >nul 2>&1
takeown /F "MOUNT\inetpub"
icacls "MOUNT\inetpub" /grant Administrators:F
rmdir /s /q "MOUNT\inetpub"
takeown /F "MOUNT\PerfLogs"
icacls "MOUNT\PerfLogs" /grant Administrators:F
rmdir /s /q "MOUNT\PerfLogs"
goto modify_registry

:modify_registry
title Windows Lite Self Edition by Irochi - Modifying registry...
cls
echo.
echo.
echo ──────────────────────────────
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo     레지스트리를 수정하는 중...
echo.
echo ──────────────────────────────
echo.
reg load HKLM\winlite_USER MOUNT\Users\Default\NTUSER.DAT
if %errorlevel% equ 0 (
    if "%windows_build%"=="%win10_build%" (
        reg import resources\winlite_USER.reg
    ) else (
        reg import resources\winlite_11_USER.reg
    )
    reg unload HKLM\winlite_USER
)
reg load HKLM\winlite_SOFTWARE MOUNT\Windows\System32\Config\SOFTWARE
if %errorlevel% equ 0 (
    if "%windows_build%"=="%win10_build%" (
        reg import resources\winlite_SOFTWARE.reg
    ) else (
        reg import resources\winlite_11_SOFTWARE.reg
    )
    reg unload HKLM\winlite_SOFTWARE
)
goto cleanup_startmenu

:cleanup_startmenu
title Windows Lite Self Edition by Irochi - Removing Start Menu Bloatware Icons...
cls
echo.
echo.
echo ──────────────────────────────
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo     시작 메뉴를 정리하는 중...
echo.
echo ──────────────────────────────
echo.
if "%windows_build%"=="%win10_build%" (
    copy resources\LayoutModification.xml MOUNT\Users\Default\AppData\Local\Microsoft\Windows\Shell
) else (
    if not exist "MOUNT\Users\Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState" (
        mkdir "MOUNT\Users\Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
    )
    copy resources\start.bin "MOUNT\Users\Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
)
goto remove_onedrive

:remove_onedrive
title Windows Lite Self Edition by Irochi - Removing OneDrive...
cls
echo.
echo.
echo ──────────────────────────────
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo     OneDrive를 삭제하는 중...
echo.
echo ──────────────────────────────
echo.
if exist "MOUNT\Windows\System32\OneDriveSetup.exe" (
    takeown /F "MOUNT\Windows\System32\OneDriveSetup.exe"
    icacls "MOUNT\Windows\System32\OneDriveSetup.exe" /grant Administrators:F
    del /f /q "MOUNT\Windows\System32\OneDriveSetup.exe"
)
if exist "MOUNT\Windows\SysWOW64\OneDriveSetup.exe" (
    takeown /F "MOUNT\Windows\SysWOW64\OneDriveSetup.exe"
    icacls "MOUNT\Windows\SysWOW64\OneDriveSetup.exe" /grant Administrators:F
    del /f /q "MOUNT\Windows\SysWOW64\OneDriveSetup.exe"
)
if exist "MOUNT\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" (
    takeown /F "MOUNT\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"
    icacls "MOUNT\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" /grant Administrators:F
    del /f /q "MOUNT\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"
)
goto unmount

:unmount
title Windows Lite Self Edition by Irochi - Finishing...
cls
echo.
echo.
echo ──────────────────────────────
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo       작업을 완료하는 중...
echo.
echo ──────────────────────────────
echo.
dism /cleanup-image /image:MOUNT /startcomponentcleanup /resetbase
dism /unmount-wim /mountdir:MOUNT /commit
if %errorlevel% neq 0 (
    set "ErrorStr1=이미지 언마운트에 실패했습니다."
    set "ErrorStr2=디스크 공간이 부족하거나 파일이 사용 중일 수 있습니다."
    goto error
)
rmdir /q /s MOUNT >nul 2>&1
goto optimize

:optimize
cls
echo.
echo.
echo ──────────────────────────────
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo   이미지를 최적화할까요? (Y/N)
echo.
echo ──────────────────────────────
echo.

choice /c YN /m "최적화할까요"
if errorlevel 2 goto set_custom_edition
if errorlevel 1 "resources\wimlib\wimlib-imagex.exe" optimize install.wim --solid

:set_custom_edition
cls
echo.
echo.
echo ──────────────────────────────
echo.
echo    Windows Lite Self Edition
echo.
echo ──────────────────────────────
echo.
set "name="
set /p name=원하는 커스텀 에디션 이름을 입력해주세요:
set "descr="
set /p descr=원하는 커스텀 에디션 설명을 입력해주세요:
call :validate_text name
if "%text_ok%" equ "0" (
    goto set_custom_edition
)
call :validate_text descr
if "%text_ok%" equ "0" (
    goto set_custom_edition
)
"resources\wimlib\wimlib-imagex.exe" info install.wim %index% "%name%" "%descr%" --image-property DISPLAYNAME="%name%" --image-property DISPLAYDESCRIPTION="%descr%"
goto finish

:finish
title Windows Lite Self Edition by Irochi (https://irochi.moe)
cls
color 1F
echo.
echo.
echo ──────────────────────────────
echo.
echo    Windows Lite Self Edition
echo.
echo       모든 작업이 끝났습니다!
echo   install.wim 파일을 사용해주세요
echo.
echo ──────────────────────────────
echo.
pause
exit

:error
title Windows Lite Self Edition by Irochi (https://irochi.moe)
cls
color 4F
echo.
echo.
echo ──────────────────────────────
echo.
echo    Windows Lite Self Edition
echo.
echo    오류:
echo.
echo    %ErrorStr1%
echo    %ErrorStr2%
echo.
echo ──────────────────────────────
echo.
pause
exit

:download_wimlib
title Windows Lite Self Edition by Irochi (https://irochi.moe)
cls
echo.
echo.
echo ──────────────────────────────
echo.
echo     wimlib을 찾을 수 없습니다.
echo.
echo.
echo       다운로드를 시도합니다.
echo.
echo ──────────────────────────────
echo.

curl -s -f -o "tmp.zip" "https://wimlib.net/downloads/wimlib-1.14.4-windows-x86_64-bin.zip"
if %errorlevel% neq 0 (
    del "tmp.zip" >nul 2>&1
    set "ErrorStr1=wimlib 다운로드에 실패했습니다."
    set "ErrorStr2=인터넷 연결을 확인해주세요."
    goto error
)
if not exist "resources\wimlib" mkdir resources\wimlib
tar -xf "tmp.zip" -C resources\wimlib
if %errorlevel% neq 0 (
    del "tmp.zip" >nul 2>&1
    set "ErrorStr1=wimlib 다운로드에 실패했습니다."
    set "ErrorStr2=인터넷 연결을 확인해주세요."
    goto error
)
if not exist "resources\wimlib\wimlib-imagex.exe" (
    del "tmp.zip" >nul 2>&1
    set "ErrorStr1=wimlib-imagex.exe을(를) 찾을 수 없습니다."
    set "ErrorStr2=파일을 정상적으로 다운로드했는지 확인해주세요."
    goto error
)
del "tmp.zip" >nul 2>&1
goto check_installation

:validate_index
setlocal EnableDelayedExpansion
set "index_ok=0"
set "rest=!index!#"
set "rest=!rest:0=!"
set "rest=!rest:1=!"
set "rest=!rest:2=!"
set "rest=!rest:3=!"
set "rest=!rest:4=!"
set "rest=!rest:5=!"
set "rest=!rest:6=!"
set "rest=!rest:7=!"
set "rest=!rest:8=!"
set "rest=!rest:9=!"
if "!rest!"=="#" set "index_ok=1"
if "!index:~0,1!"=="0" set "index_ok=0"
if "!index!"=="" set "index_ok=0"
endlocal & set "index_ok=%index_ok%"
goto :eof

:validate_text
setlocal EnableDelayedExpansion
set "text_ok=1"
set "probe=!%1!#"
set "stripped=!probe:"=!"
if not "!stripped!"=="!probe!" set "text_ok=0"
endlocal & set "text_ok=%text_ok%"
goto :eof
