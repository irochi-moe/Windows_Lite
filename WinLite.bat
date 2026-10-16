@echo off

rem Windows Lite Self Edition by Irochi (https://irochi.moe)
rem v2.7

cd /d "%~dp0" || (
    set "ErrorStr1=WinLite.batÀ»(¸¦) Ã£À» ¼ö ¾ø½À´Ï´Ù."
    set "ErrorStr2=ÆÄÀÏÀ» Á¤»óÀûÀ¸·Î ´Ù¿î·ÎµåÇß´ÂÁö È®ÀÎÇØÁÖ¼¼¿ä."
    goto error
)
whoami /groups | findstr /i "S-1-16-12288" >nul
if "%errorlevel%" NEQ "0" (
    set "ErrorStr1=°ü¸®ÀÚ ±ÇÇÑÀÌ ÇÊ¿äÇÕ´Ï´Ù."
    set "ErrorStr2=WinLite.bat ÆÄÀÏÀ» ¿ìÅ¬¸¯ÇØ °ü¸®ÀÚ ±ÇÇÑÀ¸·Î ½ÇÇàÇØÁÖ¼¼¿ä."
    goto error
)

if not exist "install.wim" (
    set "ErrorStr1=install.wimÀ»(¸¦) Ã£À» ¼ö ¾ø½À´Ï´Ù."
    set "ErrorStr2=¼øÁ¤ À©µµ¿ì ÀÌ¹ÌÁö¿¡¼­ ÆÄÀÏÀ» °¡Á®¿ÍÁÖ¼¼¿ä."
    goto error
)

set "windows_build="
for /f "tokens=4 delims=. " %%a in ('dism /Get-WimInfo /WimFile:install.wim /index:1 ^| findstr "¹öÀü" ^| find /N /V "" ^| find "[2]"') do set "windows_build=%%a"

if "%windows_build%"=="" (
    set "ErrorStr1=install.wim ¹öÀüÀ»(¸¦) Ã£À» ¼ö ¾ø½À´Ï´Ù."
    set "ErrorStr2=¼øÁ¤ À©µµ¿ì ÀÌ¹ÌÁö¿¡¼­ ÆÄÀÏÀ» °¡Á®¿ÍÁÖ¼¼¿ä."
    goto error
)

if "%windows_build%"=="19045" (
    set "RequiredResources=resources\winlite_USER.reg resources\winlite_SOFTWARE.reg resources\LayoutModification.xml"
) else (
    set "RequiredResources=resources\start.bin resources\winlite_11_SOFTWARE.reg resources\winlite_11_USER.reg"
)
for %%f in (%RequiredResources%) do (
    if not exist "%%f" (
        set "ErrorStr1=%%fÀ»(¸¦) Ã£À» ¼ö ¾ø½À´Ï´Ù."
        set "ErrorStr2=ÆÄÀÏÀ» Á¤»óÀûÀ¸·Î ´Ù¿î·ÎµåÇß´ÂÁö È®ÀÎÇØÁÖ¼¼¿ä."
        goto error
    )
)

:check_installation
if not exist "resources\wimlib\wimlib-imagex.exe" goto download_wimlib

:check_build_version
if not "%windows_build%"=="26200" (
    title Windows Lite Self Edition by Irochi - Build Warning
    cls
    echo.
    echo.
    echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
    echo.
    echo    Windows Lite Self Edition
    echo.
    echo   install.wim ºôµå: %windows_build%
    echo   ½ºÅ©¸³Æ® Áö¿ø ºôµå: 26200
    echo.
    echo   ÀÌ ºôµå´Â ´õ ÀÌ»ó Áö¿øµÇÁö ¾Ê½À´Ï´Ù.
    echo  ¿¹»óÄ¡ ¸øÇÑ ¹®Á¦°¡ ¹ß»ýÇÒ ¼ö ÀÖ½À´Ï´Ù.
    echo.
    echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
    echo.
    choice /c YN /m "°è¼Ó ÁøÇàÇÏ½Ã°Ú½À´Ï±î"
    if errorlevel 2 exit
    color 07
)

:main
title Windows Lite Self Edition by Irochi (https://irochi.moe)
cls
echo.
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo  by Irochi (https://irochi.moe)
echo.
echo               v2.7
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
pause
cls
dism /Get-WimInfo /wimfile:install.wim
set "index="
set /p index=ÀÛ¾÷ÇÒ ¿¡µð¼ÇÀÇ ÀÎµ¦½º ¹øÈ£¸¦ ÀÔ·ÂÇØÁÖ¼¼¿ä :
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
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo     ÀÌ¹ÌÁö¸¦ ¸¶¿îÆ®ÇÏ´Â Áß...
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
if exist "MOUNT" (
    echo ÀÌÀü ¸¶¿îÆ® Á¤¸® Áß...
    dism /unmount-wim /mountdir:MOUNT /discard
    timeout /t 2 >nul
    rmdir /s /q MOUNT >nul 2>&1
)
mkdir MOUNT
dism /mount-wim /wimfile:install.wim /index:%index% /mountdir:MOUNT
if %errorlevel% neq 0 (
    set "ErrorStr1=ÀÌ¹ÌÁö ¸¶¿îÆ®¿¡ ½ÇÆÐÇß½À´Ï´Ù."
    set "ErrorStr2=install.wim ÆÄÀÏÀÌ ¼Õ»óµÇ¾ú°Å³ª ÀÎµ¦½º°¡ Àß¸øµÇ¾ú½À´Ï´Ù."
    goto error
)
goto remove_apps

:remove_apps
title Windows Lite Self Edition by Irochi - Removing apps...
cls
echo.
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo      ¾ÛÀ» »èÁ¦ÇÏ´Â Áß...
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
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
        echo »èÁ¦ Áß: %%C
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
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo   ½Ã½ºÅÛ ÆÐÅ°Áö¸¦ »èÁ¦ÇÏ´Â Áß...
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
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
        echo »èÁ¦ Áß: %%F
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
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo     ·¹Áö½ºÆ®¸®¸¦ ¼öÁ¤ÇÏ´Â Áß...
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
reg load HKLM\winlite_USER MOUNT\Users\Default\NTUSER.DAT
if %errorlevel% equ 0 (
   if "%windows_build%"=="19045" (
       reg import resources\winlite_USER.reg
   ) else (
       reg import resources\winlite_11_USER.reg
   )
   reg unload HKLM\winlite_USER
)
reg load HKLM\winlite_SOFTWARE MOUNT\Windows\System32\Config\SOFTWARE
if %errorlevel% equ 0 (
   if "%windows_build%"=="19045" (
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
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo     ½ÃÀÛ ¸Þ´º¸¦ Á¤¸®ÇÏ´Â Áß...
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
if "%windows_build%"=="19045" (
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
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo     OneDrive¸¦ »èÁ¦ÇÏ´Â Áß...
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
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
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo       ÀÛ¾÷À» ¿Ï·áÇÏ´Â Áß...
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
dism /cleanup-image /image:MOUNT /startcomponentcleanup /resetbase
dism /unmount-wim /mountdir:MOUNT /commit
if %errorlevel% neq 0 (
    set "ErrorStr1=ÀÌ¹ÌÁö ¾ð¸¶¿îÆ®¿¡ ½ÇÆÐÇß½À´Ï´Ù."
    set "ErrorStr2=µð½ºÅ© °ø°£ÀÌ ºÎÁ·ÇÏ°Å³ª ÆÄÀÏÀÌ »ç¿ë ÁßÀÏ ¼ö ÀÖ½À´Ï´Ù."
    goto error
)
rmdir /q /s MOUNT >nul 2>&1
goto optimize

:optimize
cls
echo.
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
echo    Windows Lite Self Edition
echo.
echo.
echo   ÀÌ¹ÌÁö¸¦ ÃÖÀûÈ­ÇÒ±î¿ä? (Y/N)
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.

choice /c YN /m "ÃÖÀûÈ­ÇÒ±î¿ä"
if errorlevel 2 goto set_custom_edition
if errorlevel 1 "resources\wimlib\wimlib-imagex.exe" optimize install.wim --solid

:set_custom_edition
cls
echo.
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
echo    Windows Lite Self Edition
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
set "name="
set /p name=¿øÇÏ´Â Ä¿½ºÅÒ ¿¡µð¼Ç ÀÌ¸§À» ÀÔ·ÂÇØÁÖ¼¼¿ä:
set "descr="
set /p descr=¿øÇÏ´Â Ä¿½ºÅÒ ¿¡µð¼Ç ¼³¸íÀ» ÀÔ·ÂÇØÁÖ¼¼¿ä:
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
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
echo    Windows Lite Self Edition
echo.
echo       ¸ðµç ÀÛ¾÷ÀÌ ³¡³µ½À´Ï´Ù!
echo   install.wim ÆÄÀÏÀ» »ç¿ëÇØÁÖ¼¼¿ä
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
pause
exit

:error
title Windows Lite Self Edition by Irochi (https://irochi.moe)
cls
color 4F
echo.
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
echo    Windows Lite Self Edition
echo.
echo    ¿À·ù:
echo.
echo    %ErrorStr1%
echo    %ErrorStr2%
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
pause
exit

:download_wimlib
title Windows Lite Self Edition by Irochi (https://irochi.moe)
cls
echo.
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.
echo     wimlibÀ» Ã£À» ¼ö ¾ø½À´Ï´Ù.
echo.
echo.
echo       ´Ù¿î·Îµå¸¦ ½ÃµµÇÕ´Ï´Ù.
echo.
echo ¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡¦¡
echo.

curl -s -f -o "tmp.zip" "https://wimlib.net/downloads/wimlib-1.14.4-windows-x86_64-bin.zip"
if %errorlevel% neq 0 (
    del "tmp.zip" >nul 2>&1
    set "ErrorStr1=wimlib ´Ù¿î·Îµå¿¡ ½ÇÆÐÇß½À´Ï´Ù."
    set "ErrorStr2=ÀÎÅÍ³Ý ¿¬°áÀ» È®ÀÎÇØÁÖ¼¼¿ä."
    goto error
)
if not exist "resources\wimlib" mkdir resources\wimlib
tar -xf "tmp.zip" -C resources\wimlib
if %errorlevel% neq 0 (
    del "tmp.zip" >nul 2>&1
    set "ErrorStr1=wimlib ´Ù¿î·Îµå¿¡ ½ÇÆÐÇß½À´Ï´Ù."
    set "ErrorStr2=ÀÎÅÍ³Ý ¿¬°áÀ» È®ÀÎÇØÁÖ¼¼¿ä."
    goto error
)
if not exist "resources\wimlib\wimlib-imagex.exe" (
    del "tmp.zip" >nul 2>&1
    set "ErrorStr1=wimlib-imagex.exeÀ»(¸¦) Ã£À» ¼ö ¾ø½À´Ï´Ù."
    set "ErrorStr2=ÆÄÀÏÀ» Á¤»óÀûÀ¸·Î ´Ù¿î·ÎµåÇß´ÂÁö È®ÀÎÇØÁÖ¼¼¿ä."
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
