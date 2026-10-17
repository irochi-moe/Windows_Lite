@echo off

rem Windows Lite Self Edition by Irochi (https://irochi.moe)

set "supported_build=26300"
set "wimlib=resources\wimlib\wimlib-imagex.exe"

cd /d "%~dp0" || call :fail "네트워크 경로에서는 실행할 수 없습니다." "WinLite 폴더를 로컬 드라이브로 옮겨주세요."
whoami /groups | findstr /i "S-1-16-12288" >nul || call :fail "관리자 권한이 필요합니다." "WinLite.bat 파일을 우클릭해 관리자 권한으로 실행해주세요."
if not exist "install.wim" call :fail "install.wim을(를) 찾을 수 없습니다." "순정 윈도우 이미지에서 파일을 가져와주세요."

set "windows_build="
for /f "tokens=3 delims=." %%a in ('dism /Get-WimInfo /WimFile:install.wim /Index:1 ^| findstr /R /C:" 10\.0\.[0-9][0-9]*$"') do set "windows_build=%%a"
if "%windows_build%"=="" call :fail "install.wim 버전을(를) 찾을 수 없습니다." "순정 윈도우 이미지에서 파일을 가져와주세요."

if "%windows_build%"=="19045" (
    set "res_dir=resources\10"
    set "start_file=LayoutModification.xml"
    set "start_dir=MOUNT\Users\Default\AppData\Local\Microsoft\Windows\Shell"
) else (
    set "res_dir=resources\11"
    set "start_file=start.bin"
    set "start_dir=MOUNT\Users\Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
)
for %%f in ("%res_dir%\winlite_USER.reg" "%res_dir%\winlite_SOFTWARE.reg" "%res_dir%\winlite_SYSTEM.reg" "%res_dir%\%start_file%") do (
    if not exist "%%~f" call :fail "%%~f을(를) 찾을 수 없습니다." "파일을 정상적으로 다운로드했는지 확인해주세요."
)

:check_installation
if not exist "%wimlib%" goto download_wimlib

:check_build_version
if "%windows_build%"=="%supported_build%" goto main
if "%windows_build%"=="19045" goto main
call :banner "Build warning" "" "  install.wim 빌드: %windows_build%" "  스크립트 지원 빌드: %supported_build%" "" "  이 빌드는 더 이상 지원되지 않습니다." " 예상치 못한 문제가 발생할 수 있습니다."
choice /c YN /m "계속 진행하시겠습니까"
if errorlevel 2 exit

:main
call :banner "" "" "" " by Irochi (https://irochi.moe)" "" "              v2.7"
pause
cls
dism /Get-WimInfo /WimFile:install.wim
set "index="
set /p index=작업할 에디션의 인덱스 번호를 입력해주세요 :
call :validate_index
if "%index_ok%"=="1" goto mount
goto main

:mount
call :banner "Mounting image..." "" "" "    이미지를 마운트하는 중..."
if exist "MOUNT" (
    echo 이전 마운트 정리 중...
    dism /Unmount-Wim /MountDir:MOUNT /Discard
    timeout /t 2 >nul
    rmdir /s /q "MOUNT" >nul 2>&1
)
mkdir "MOUNT"
dism /Mount-Wim /WimFile:install.wim /Index:%index% /MountDir:MOUNT || call :fail "이미지 마운트에 실패했습니다." "install.wim 파일이 손상되었거나 인덱스가 잘못되었습니다."

:remove_apps
call :banner "Removing apps..." "" "" "     앱을 삭제하는 중..."
dism /Image:MOUNT /Get-ProvisionedAppxPackages > temp_apps.txt
for %%A in (
    Clipchamp.Clipchamp
    Microsoft.549981C3F5F10
    Microsoft.BingNews
    Microsoft.BingSearch
    Microsoft.BingWeather
    Microsoft.Copilot
    Microsoft.GamingApp
    Microsoft.GetHelp
    Microsoft.Getstarted
    Microsoft.HEIFImageExtension
    Microsoft.Microsoft3DViewer
    Microsoft.MicrosoftJournal
    Microsoft.MicrosoftOfficeHub
    Microsoft.MicrosoftPCManager
    Microsoft.MicrosoftSolitaireCollection
    Microsoft.MicrosoftStickyNotes
    Microsoft.MixedReality.Portal
    Microsoft.MSPaint
    Microsoft.Office.OneNote
    Microsoft.OfficePushNotificationUtility
    Microsoft.OutlookForWindows
    Microsoft.Paint
    Microsoft.People
    Microsoft.PowerAutomateDesktop
    Microsoft.ScreenSketch
    Microsoft.SkypeApp
    Microsoft.StartExperiencesApp
    Microsoft.Todos
    Microsoft.VP9VideoExtensions
    Microsoft.Wallet
    Microsoft.WebMediaExtensions
    Microsoft.WebpImageExtension
    Microsoft.Windows.Copilot
    Microsoft.Windows.CrossDevice
    Microsoft.Windows.DevHome
    Microsoft.Windows.Photos
    Microsoft.Windows.Teams
    Microsoft.WindowsAlarms
    Microsoft.WindowsCalculator
    Microsoft.WindowsCamera
    microsoft.windowscommunicationsapps
    Microsoft.WindowsFeedbackHub
    Microsoft.WindowsMaps
    Microsoft.WindowsSoundRecorder
    Microsoft.WindowsTerminal
    Microsoft.Xbox.TCUI
    Microsoft.XboxApp
    Microsoft.XboxGameOverlay
    Microsoft.XboxGamingOverlay
    Microsoft.XboxIdentityProvider
    Microsoft.XboxSpeechToTextOverlay
    Microsoft.YourPhone
    Microsoft.ZuneMusic
    Microsoft.ZuneVideo
    MicrosoftCorporationII.MicrosoftFamily
    MicrosoftCorporationII.QuickAssist
    MicrosoftTeams
    MicrosoftWindows.Client.WebExperience
    MSTeams
) do (
    for /f "tokens=3" %%C in ('findstr /i "%%A_" temp_apps.txt') do (
        echo 삭제 중: %%C
        dism /Image:MOUNT /Remove-ProvisionedAppxPackage /PackageName:%%C >nul 2>&1
    )
)
del "temp_apps.txt" >nul 2>&1

:remove_system_packages
call :banner "Removing system packages..." "" "" "  시스템 패키지를 삭제하는 중..."
dism /Image:MOUNT /Get-Packages > temp_system_packages.txt
for %%D in (
    Microsoft-Windows-InternetExplorer-Optional-Package
    Microsoft-Windows-MediaPlayer-Package
    Microsoft-Windows-PowerShell-ISE-FOD-Package
    Microsoft-Windows-QuickAssist-Package
    Microsoft-Windows-StepsRecorder-Package
    Microsoft-Windows-TabletPCMath-Package
    Microsoft-Windows-WordPad-FoD-Package
    OpenSSH-Client-Package
) do (
    for /f "tokens=3 delims=: " %%F in ('findstr /i "%%D" temp_system_packages.txt') do (
        echo 삭제 중: %%F
        dism /Image:MOUNT /Remove-Package /PackageName:%%F >nul 2>&1
    )
)
del "temp_system_packages.txt" >nul 2>&1
dism /Image:MOUNT /Get-FeatureInfo /FeatureName:Recall >nul 2>&1 && (
    echo 삭제 중: Recall
    dism /Image:MOUNT /Disable-Feature /FeatureName:Recall /Remove >nul 2>&1
)
call :force_delete "MOUNT\inetpub"
call :force_delete "MOUNT\PerfLogs"

:modify_registry
call :banner "Modifying registry..." "" "" "    레지스트리를 수정하는 중..."
call :import_hive USER "MOUNT\Users\Default\NTUSER.DAT"
call :import_hive SOFTWARE "MOUNT\Windows\System32\Config\SOFTWARE"
call :import_hive SYSTEM "MOUNT\Windows\System32\Config\SYSTEM"

:cleanup_startmenu
call :banner "Cleaning up Start menu..." "" "" "    시작 메뉴를 정리하는 중..."
if not exist "%start_dir%" mkdir "%start_dir%"
copy "%res_dir%\%start_file%" "%start_dir%"

:remove_onedrive
call :banner "Removing OneDrive..." "" "" "    OneDrive를 삭제하는 중..."
call :force_delete "MOUNT\Windows\System32\OneDriveSetup.exe"
call :force_delete "MOUNT\Windows\SysWOW64\OneDriveSetup.exe"
call :force_delete "MOUNT\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

:unmount
call :banner "Finishing..." "" "" "      작업을 완료하는 중..."
dism /Image:MOUNT /Cleanup-Image /StartComponentCleanup /ResetBase
dism /Unmount-Wim /MountDir:MOUNT /Commit || call :fail "이미지 언마운트에 실패했습니다." "디스크 공간이 부족하거나 파일이 사용 중일 수 있습니다."
rmdir /s /q "MOUNT" >nul 2>&1

:optimize
call :banner "Optimizing image..." "" "" "  이미지를 최적화할까요? (Y/N)"
choice /c YN /m "최적화할까요"
if not errorlevel 2 "%wimlib%" optimize install.wim --solid

:set_custom_edition
call :banner "Setting edition name..."
set "name="
set /p name=원하는 커스텀 에디션 이름을 입력해주세요:
set "descr="
set /p descr=원하는 커스텀 에디션 설명을 입력해주세요:
call :validate_text name
if "%text_ok%"=="0" goto set_custom_edition
call :validate_text descr
if "%text_ok%"=="0" goto set_custom_edition
"%wimlib%" info install.wim %index% "%name%" "%descr%" --image-property DISPLAYNAME="%name%" --image-property DISPLAYDESCRIPTION="%descr%"

:finish
color 1F
call :banner "" "" "      모든 작업이 끝났습니다!" "  install.wim 파일을 사용해주세요"
pause
exit

:download_wimlib
call :banner "Downloading wimlib..." "" "    wimlib을 찾을 수 없습니다." "" "" "      다운로드를 시도합니다."
curl -s -f -o "tmp.zip" "https://wimlib.net/downloads/wimlib-1.14.5-windows-x86_64-bin.zip" || (del "tmp.zip" >nul 2>&1 & call :fail "wimlib 다운로드에 실패했습니다." "인터넷 연결을 확인해주세요.")
if not exist "resources\wimlib" mkdir "resources\wimlib"
tar -xf "tmp.zip" -C "resources\wimlib" || (del "tmp.zip" >nul 2>&1 & call :fail "wimlib 다운로드에 실패했습니다." "인터넷 연결을 확인해주세요.")
del "tmp.zip" >nul 2>&1
if not exist "%wimlib%" call :fail "wimlib-imagex.exe을(를) 찾을 수 없습니다." "파일을 정상적으로 다운로드했는지 확인해주세요."
goto check_installation

:banner
set "banner_title=Windows Lite Self Edition by Irochi (https://irochi.moe)"
if not "%~1"=="" set "banner_title=Windows Lite Self Edition by Irochi - %~1"
title %banner_title%
cls
echo.
echo.
echo ──────────────────────────────
echo.
echo    Windows Lite Self Edition
:banner_line
shift
if [%1]==[] goto banner_end
echo.%~1
goto banner_line
:banner_end
echo.
echo ──────────────────────────────
echo.
goto :eof

:fail
color 4F
call :banner "" "" "   오류:" "" "   %~1" "   %~2"
pause
exit

:import_hive
reg load "HKLM\%~1_winlite" "%~2" || goto :eof
reg import "%res_dir%\winlite_%~1.reg"
reg unload "HKLM\%~1_winlite"
goto :eof

:force_delete
if not exist "%~1" goto :eof
takeown /F "%~1"
icacls "%~1" /grant Administrators:F
if exist "%~1\" (rmdir /s /q "%~1") else (del /f /q "%~1")
goto :eof

:validate_index
setlocal EnableDelayedExpansion
set "index_ok=1"
if "!index:~0,1!"=="0" set "index_ok=0"
if "!index!"=="" set "index_ok=0"
for /f "eol=0 delims=0123456789" %%i in ("!index!") do set "index_ok=0"
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
