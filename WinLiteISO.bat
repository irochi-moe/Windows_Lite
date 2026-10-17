@echo off

set "oscdimg=resources\oscdimg.exe"

cd /d "%~dp0" || call :fail "네트워크 경로에서는 실행할 수 없습니다." "WinLite 폴더를 로컬 드라이브로 옮겨주세요."
if not exist "install.wim" call :fail "install.wim을(를) 찾을 수 없습니다." "WinLite.bat을 먼저 실행해주세요."
if not exist "*.iso" call :fail "ISO 파일을 찾을 수 없습니다." "원본 ISO 파일을 WinLite 폴더에 넣어주세요."

if not exist "%oscdimg%" (
    call :banner "Downloading oscdimg..." "" "    oscdimg를 찾을 수 없습니다." "" "" "      다운로드를 시도합니다."
    curl -s -f -L -o "%oscdimg%" "https://msdl.microsoft.com/download/symbols/oscdimg.exe/3D44737265000/oscdimg.exe" || (del "%oscdimg%" >nul 2>&1 & call :fail "oscdimg 다운로드에 실패했습니다." "인터넷 연결을 확인해주세요.")
)

:main
call :banner "ISO" "" "" " by Irochi (https://irochi.moe)" "" "         ISO Maker"
pause

:select_iso
set "index=1"
for /f %%c in ('dir /b *.iso ^| find /c /v ""') do if not "%%c"=="1" (
    cls
    for /f "tokens=1* delims=:" %%a in ('dir /b *.iso ^| findstr /n "^"') do echo   %%a. %%b
    set "index="
    set /p index=원본 ISO 파일의 번호를 입력해주세요 :
)
call :validate_index
if not "%index_ok%"=="1" goto select_iso
set "iso="
for /f "tokens=1* delims=:" %%a in ('dir /b *.iso ^| findstr /n "^"') do if "%%a"=="%index%" set "iso=%%b"
if "%iso%"=="" goto select_iso

:set_iso_name
set "name=WinLite"
set /p name=만들 ISO 파일 이름을 입력해주세요 (기본값: WinLite) :
call :validate_name
if not "%name_ok%"=="1" goto set_iso_name
if exist "%name%.iso" (
    choice /c YN /m "%name%.iso 파일이 이미 있습니다. 덮어쓸까요"
    if errorlevel 2 goto set_iso_name
)

:copy_files
call :banner "Copying files..." "" "" "    ISO 파일을 복사하는 중..."
rmdir /s /q "ISO_TEMP" 2>nul
set "drive="
for /f %%d in ('powershell -nop -c "(Mount-DiskImage -ImagePath '%cd%\%iso%' -PassThru | Get-Volume).DriveLetter"') do set "drive=%%d:"
if "%drive%"=="" call :fail "ISO 마운트에 실패했습니다." "%iso% 파일이 손상되었을 수 있습니다."
robocopy %drive%\ "ISO_TEMP" /e /a-:R /xf install.wim install.esd /njh /njs /ndl /nfl >nul
powershell -nop -c "Dismount-DiskImage -ImagePath '%cd%\%iso%'" >nul
mklink /h "ISO_TEMP\sources\install.wim" "install.wim" >nul || call :fail "install.wim 교체에 실패했습니다." "WinLite 폴더가 NTFS 드라이브에 있는지 확인해주세요."

:make_iso
call :banner "Creating ISO..." "" "" "     ISO를 만드는 중..."
del /f /q "%name%.iso" 2>nul
"%oscdimg%" -m -o -u2 -udfver102 -lWinLite -bootdata:2#p0,e,bISO_TEMP\boot\etfsboot.com#pEF,e,bISO_TEMP\efi\microsoft\boot\efisys.bin ISO_TEMP "%name%.iso" || call :fail "ISO 생성에 실패했습니다." "파일 이름이나 디스크 공간을 확인해주세요."
rmdir /s /q "ISO_TEMP"

:finish
color 1F
call :banner "" "" "      모든 작업이 끝났습니다!" "  %name%.iso 파일을 사용해주세요"
pause
exit

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

:validate_index
setlocal EnableDelayedExpansion
set "index_ok=1"
if "!index:~0,1!"=="0" set "index_ok=0"
if "!index!"=="" set "index_ok=0"
for /f "eol=0 delims=0123456789" %%i in ("!index!") do set "index_ok=0"
endlocal & set "index_ok=%index_ok%"
goto :eof

:validate_name
setlocal EnableDelayedExpansion
set "name_ok=1"
set "probe=!name!#"
set "stripped=!probe:"=!"
if not "!stripped!"=="!probe!" set "name_ok=0"
if "!name_ok!"=="1" for /f "tokens=1* delims=\/:*?<>|" %%a in ("#!name!#") do if not "%%b"=="" set "name_ok=0"
endlocal & set "name_ok=%name_ok%"
goto :eof
