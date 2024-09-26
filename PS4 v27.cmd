@echo off
color 1F
title PS4 - AIO

set mypath=%cd%
set pubCmd=%cd%\tools\PS4-Fake-PKG-Tools-3.87-main\orbis-pub-cmd.exe
set gengp4p=%cd%\tools\PS4-Fake-PKG-Tools-3.87-main\gengp4_patch.exe
set gengp4a=%cd%\tools\PS4-Fake-PKG-Tools-3.87-main\gengp4_app.exe
set game=%cd%\Game
set update=%cd%\Update
set backport=%cd%\Backport
set BackportedFiles=%cd%\Backported Files
set work=%cd%\tools\Work
set updateunpack=%cd%\tools\Work\Update-pkg
set gameunpack=%cd%\tools\Work\Game-pkg
set sfo=%cd%\tools\sfo.exe
set dlc=%cd%\DLC
set dlcunpack=%cd%\tools\Work\DLC-pkg
set pkgtool=%cd%\tools\PkgTool.exe
set fnr=%cd%\tools\fnr.exe


if not exist "%game%" mkdir "%game%"
if not exist "%update%" mkdir "%update%"
if not exist "%backport%" mkdir "%backport%"
if not exist "%BackportedFiles%" mkdir "%BackportedFiles%"
if not exist "%work%" mkdir "%work%"
if not exist "%dlc%" mkdir "%dlc%"

if exist "%cd%\tools\*.txt" del "%cd%\tools\*.txt"
FOR /D %%p IN ("%work%\*") DO rmdir "%%p" /s /q
del /q "%work%\*.*"
if exist "%cd%\*.gp4" del /q "%cd%\*.gp4"
FOR /D %%p IN ("%cd%\CUSA*-patch") DO rmdir "%%p" /s /q

if not exist "%updateunpack%" mkdir "%updateunpack%"
if not exist "%gameunpack%" mkdir "%gameunpack%"
if not exist "%cd%\tools\Work\ps4pub" mkdir "%cd%\tools\Work\ps4pub"
if not exist "%dlcunpack%" mkdir "%dlcunpack%"
if not exist "%cd%\tools\Finished" mkdir "%cd%\tools\Finished"


if exist "%cd%\tools\*.choice" goto tasklist
) else (
goto choice0
)

:choice0
echo          Choose Temp Folder:
echo.
echo   Yes - Temp folder will be this folder.
echo   No  - Default Temp Folder - Nothing changed
echo.
set /P c=Are you want to change Temp Folder? [Yes/No]?

if /I "%c%" EQU "Yes" goto choice1
if /I "%c%" EQU "No" goto choice2

echo Invalid selection. Exiting.
pause
exit

:choice1
fsutil file createnew "%cd%\tools\Yes.choice" 0
IF EXIST "%TEMP%\ps4pub" goto Junction1 (
) ELSE (
goto Junction2
)

:Junction1
FOR /D %%p IN ("%TEMP%\ps4pub") DO rmdir "%%p" /s /q

:Junction2
mklink /j "%TEMP%\ps4pub" "%cd%\tools\Work\ps4pub"
cls
goto tasklist


:choice2
fsutil file createnew "%cd%\tools\No.choice" 0
cls

:tasklist
ECHO. ___________________________________
ECHO.
ECHO.           Select a Task:
ECHO. ___________________________________
ECHO.
ECHO 1. Remarry Game + Update
ECHO 2. Merge Game + Update
ECHO 3. Backup Backported Files
ECHO 4. PS4 Rebuild PKG - Backport
ECHO 5. Merge Game + Update + Backport
ECHO 6. Fix Game Info
ECHO 7. DLC - Change Region
ECHO 8. PS4 DLC Unlocker
ECHO 9. Without Data DLC to Data DLC
ECHO 10. Data DLC to Without Data DLC
ECHO 11. Update - Change Region
ECHO 12. Save sharing between US/EU Games
ECHO. ___________________________________
ECHO.
ECHO 13. Clear Temp Folder Choice
ECHO 14. Exit
ECHO.

SET /P M=Enter your Choice:

IF %M%==1 GOTO Remarry Game + Update
IF %M%==2 GOTO Merge Game + Update
IF %M%==3 GOTO Backup Backported Files
IF %M%==4 GOTO PS4 Rebuild PKG - Backport
IF %M%==5 GOTO Game + Update + Backport
IF %M%==6 GOTO Fix Game Info
IF %M%==7 GOTO DLC - Change Region
IF %M%==8 GOTO PS4-DLC Unlocker
IF %M%==9 GOTO Without Data DLC to Data DLC
IF %M%==10 GOTO Data DLC to Without Data DLC
IF %M%==11 GOTO Update - Change Region
IF %M%==12 GOTO Save sharing between US/EU Games
IF %M%==13 GOTO Clear Temp Folder Choice
IF %M%==14 Exit


:Clear Temp Folder Choice

del /q "%cd%\tools\*.choice"
start "PS4 - AIO" "%~f0"
exit



:Remarry Game + Update
color 2F

:: Stop if no game pkg found.
if not exist "%game%\*.pkg" echo - Folder GAME does not contains game pkg file.
if not exist "%update%\*.pkg" echo - Folder UPDATE does not contains update pkg file.
if not exist "%game%\*.pkg" pause
if not exist "%game%\*.pkg" exit
if not exist "%update%\*.pkg" pause
if not exist "%update%\*.pkg" exit


IF EXIST "%cd%/tools/PS4-Fake-PKG-Tools-3.87-main" goto Merge2 (
) ELSE (
"%cd%/tools/wget.exe" "https://github.com/CyB1K/PS4-Fake-PKG-Tools-3.87/archive/refs/heads/main.zip"
"%cd%/tools/7za.exe" x "%cd%/main.zip" -o"%cd%/tools"
del main.zip
)

:Merge2
for /f "usebackq tokens=* delims=" %%P in (`dir /b "%game%" `) do set "G=%%P"
tools\sfk partcopy "%game%\%G%" 0x047 0x9 tools\id.txt -yes
for /f "tokens=* delims=," %%t in (tools\id.txt) do set FOLDER=%%t-patch
del tools\id.txt


echo --------------------------------------------------------------------------------------
echo - Unpacking Update
echo - Please wait...
echo --------------------------------------------------------------------------------------

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%update%" `) do set "Up=%%P"
"%pubCmd%" img_extract --passcode 00000000000000000000000000000000  "%update%\%Up%" "%updateunpack%"

xcopy /e "%updateunpack%\Sc0\*" "%updateunpack%\Image0\sce_sys\"
rmdir /s /q "%updateunpack%\Sc0\"

echo --------------------------------------------------------------------------------------
echo - Remarring Game and Update
echo - Please wait...
echo --------------------------------------------------------------------------------------

move "%updateunpack%\Image0" "%work%"

rmdir /s /q "%updateunpack%"

Ren "%work%\Image0"  %FOLDER%

"%gengp4p%" "%work%\%FOLDER%"

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%game%" `) do set "Ga=%%P"

"%pubCmd%" gp4_proj_update --app_path "%game%\%ga%" "%work%\%FOLDER%.gp4"

echo --------------------------------------------------------------------------------------
echo - Building Update
echo - Please wait...
echo --------------------------------------------------------------------------------------

"%pubCmd%" img_create --oformat pkg  "%work%\%FOLDER%.gp4" "%cd%"


FOR /D %%p IN ("%work%\*") DO rmdir "%%p" /s /q
del /q "%work%\*.gp4"
del /q *compare_delta.log
EXIT


:Merge Game + Update
color 3F

:: Stop if no game pkg found.
if not exist "%game%\*.pkg" echo - Folder GAME does not contains game pkg file.
if not exist "%update%\*.pkg" echo - Folder UPDATE does not contains update pkg file.
if not exist "%game%\*.pkg" pause
if not exist "%game%\*.pkg" exit
if not exist "%update%\*.pkg" pause
if not exist "%update%\*.pkg" exit

IF EXIST "%cd%/tools/PS4-Fake-PKG-Tools-3.87-main" goto Merge2 (
) ELSE (
"%cd%/tools/wget.exe" "https://github.com/CyB1K/PS4-Fake-PKG-Tools-3.87/archive/refs/heads/main.zip"
"%cd%/tools/7za.exe" x "%cd%/main.zip" -o"%cd%/tools"
del main.zip
)

:Merge2
echo --------------------------------------------------------------------------------------
echo - Unpacking Game
echo - Please wait...
echo --------------------------------------------------------------------------------------

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%game%" `) do set "Ga=%%P"
"%pubCmd%" img_extract --passcode 00000000000000000000000000000000  "%game%\%ga%" "%gameunpack%"

xcopy /e "%gameunpack%\Sc0\*" "%gameunpack%\Image0\sce_sys\"
rmdir /s /q "%gameunpack%\Sc0\"

echo --------------------------------------------------------------------------------------
echo - Unpacking Update
echo - Please wait...
echo --------------------------------------------------------------------------------------

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%update%" `) do set "Up=%%P"
"%pubCmd%" img_extract --passcode 00000000000000000000000000000000  "%update%\%Up%" "%updateunpack%"

xcopy /e "%updateunpack%\Sc0\*" "%updateunpack%\Image0\sce_sys\"
rmdir /s /q "%updateunpack%\Sc0\"

echo --------------------------------------------------------------------------------------
echo - Merging Game and Update
echo - Please wait...
echo --------------------------------------------------------------------------------------

move "%gameunpack%\Image0" "%work%"

xcopy /e /y "%updateunpack%\*" "%work%"

rmdir /s /q "%gameunpack%"
rmdir /s /q "%updateunpack%"

Ren "%work%\Image0" Game-app

"%gengp4a%" "%work%\Game-app"

echo --------------------------------------------------------------------------------------
echo - Building FPKG
echo - Please wait...
echo --------------------------------------------------------------------------------------

"%pubCmd%" img_create --oformat pkg  "%work%\Game-app.gp4" "%cd%"


FOR /D %%p IN ("%work%\*") DO rmdir "%%p" /s /q
del /q "%work%\*.gp4"
del /q *compare_delta.log
EXIT


:Backup Backported Files
color 4F
setlocal enabledelayedexpansion

:: Stop if no game pkg found.
if not exist "%backport%\*.pkg" echo - Folder BACKPORT does not contains backported pkg file.
if not exist "%backport%\*.pkg" pause
if not exist "%backport%\*.pkg" exit

IF EXIST "%cd%/tools/PS4-Fake-PKG-Tools-3.87-main" goto Merge2 (
) ELSE (
"%cd%/tools/wget.exe" "https://github.com/CyB1K/PS4-Fake-PKG-Tools-3.87/archive/refs/heads/main.zip"
"%cd%/tools/7za.exe" x "%cd%/main.zip" -o"%cd%/tools"
del main.zip
)

:Merge2
for /f "usebackq tokens=* delims=" %%P in (`dir /b "%backport%"`) do set "Bp=%%P"
tools\sfk partcopy "%backport%\%Bp%" 0x047 0x9 tools\id.txt -yes
for /f "tokens=* delims=," %%t in (tools\id.txt) do set FOLDER=%%t

mkdir %FOLDER%


"%pubCmd%" img_file_list --passcode "00000000000000000000000000000000" "%backport%\%Bp%" > tools\tmp_list.txt
findstr /l ".prx .sprx eboot.bin" tools\tmp_list.txt > tools\list.txt


for /F "usebackq delims=" %%i in (tools\list.txt) do md "%%~pi"

for /f "usebackq tokens=* delims=" %%L in ("tools\list.txt") do (
"%pubCmd%" img_extract --passcode "00000000000000000000000000000000" "%backport%\%Bp%":"%%L" "%%L"
"%pubCmd%" img_extract --passcode "00000000000000000000000000000000" "%backport%\%Bp%":"Sc0/param.sfo" "Image0\sce_sys"
)

move "Image0" "%FOLDER%"

tools\7za.exe a %FOLDER%.zip .\%FOLDER%\*

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%backport%"`) do set "Bprt=%%~nP"
ren %FOLDER%.zip "%Bprt% - Backport".zip


del tools\id.txt
del tools\tmp_list.txt
del tools\list.txt
FOR /D %%x IN ("%cd%\CUSA*") DO rmdir "%%x" /s /q
FOR /D %%z IN ("%cd%\Image0*") DO rmdir "%%z" /s /q
EXIT


:PS4 Rebuild PKG - Backport
color 5F

:: Stop if no game pkg found.
if not exist "%game%\*.pkg" echo - Folder GAME does not contains Game pkg file.
if not exist "%update%\*.pkg" echo - Folder UPDATE does not contains Update pkg file.
if not exist "%BackportedFiles%\*.zip" echo - Folder BACKPORTED FILES does not contains backup file.
if not exist "%game%\*.pkg" pause
if not exist "%game%\*.pkg" exit
if not exist "%update%\*.pkg" pause
if not exist "%update%\*.pkg" exit
if not exist "%BackportedFiles%\*.zip" pause
if not exist "%BackportedFiles%\*.zip" exit


IF EXIST "%cd%/tools/PS4-Fake-PKG-Tools-3.87-main" goto Merge2 (
) ELSE (
"%cd%/tools/wget.exe" "https://github.com/CyB1K/PS4-Fake-PKG-Tools-3.87/archive/refs/heads/main.zip"
"%cd%/tools/7za.exe" x "%cd%/main.zip" -o"%cd%/tools"
del main.zip
)

:Merge2
for /f "usebackq tokens=* delims=" %%P in (`dir /b "%game%" `) do set "G=%%P"
tools\sfk partcopy "%game%\%G%" 0x047 0x9 tools\id.txt -yes
for /f "tokens=* delims=," %%t in (tools\id.txt) do set FOLDER=%%t-patch
del tools\id.txt


echo --------------------------------------------------------------------------------------
echo - Unpacking Update
echo - Please wait...
echo --------------------------------------------------------------------------------------

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%update%" `) do set "Up=%%P"
"%pubCmd%" img_extract --passcode 00000000000000000000000000000000  "%update%\%Up%" "%updateunpack%"

xcopy /e "%updateunpack%\Sc0\*" "%updateunpack%\Image0\sce_sys\"
rmdir /s /q "%updateunpack%\Sc0\"

move "%updateunpack%\Image0" "%work%"

rmdir /s /q "%updateunpack%\"

echo --------------------------------------------------------------------------------------
echo - Extracting Backported Files
echo - Please wait...
echo --------------------------------------------------------------------------------------

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%BackportedFiles%"`) do set "Bp=%%P"
tools\7za.exe x "%BackportedFiles%\%Bp%"  -aoa -o"%work%"

Ren "%work%\Image0"  %FOLDER%

"%gengp4p%" "%work%\%FOLDER%"

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%game%" `) do set "Ga=%%P"

"%pubCmd%" gp4_proj_update --app_path "%game%\%ga%" "%work%\%FOLDER%.gp4"

echo --------------------------------------------------------------------------------------
echo - Building Update
echo - Please wait...
echo --------------------------------------------------------------------------------------

"%pubCmd%" img_create --oformat pkg  "%work%\%FOLDER%.gp4" "%cd%"

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%update%" `) do set "Ue=%%~nP"
ren "*.pkg"  "%Ue% - Backport.pkg"


FOR /D %%p IN ("%work%\*") DO rmdir "%%p" /s /q
del /q "%work%\*.gp4"
del /q *compare_delta.log
EXIT


:Game + Update + Backport
color 0d

:: Stop if no game pkg found.
if not exist "%game%\*.pkg" echo - Folder GAME does not contains game pkg file.
if not exist "%update%\*.pkg" echo - Folder UPDATE does not contains update pkg file.
if not exist "%BackportedFiles%\*.zip" echo - Folder BACKPORTED FILES does not contains Backported Files.
if not exist "%game%\*.pkg" pause
if not exist "%game%\*.pkg" exit
if not exist "%update%\*.pkg" pause
if not exist "%update%\*.pkg" exit
if not exist "%BackportedFiles%\*.zip" pause
if not exist "%BackportedFiles%\*.zip" exit


IF EXIST "%cd%/tools/PS4-Fake-PKG-Tools-3.87-main" goto Merge2 (
) ELSE (
"%cd%/tools/wget.exe" "https://github.com/CyB1K/PS4-Fake-PKG-Tools-3.87/archive/refs/heads/main.zip"
"%cd%/tools/7za.exe" x "%cd%/main.zip" -o"%cd%/tools"
del main.zip
)

:Merge2
echo --------------------------------------------------------------------------------------
echo - Unpacking Game
echo - Please wait...
echo --------------------------------------------------------------------------------------

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%game%" `) do set "Ga=%%P"
"%pubCmd%" img_extract --passcode 00000000000000000000000000000000  "%game%\%ga%" "%gameunpack%"

xcopy /e "%gameunpack%\Sc0\*" "%gameunpack%\Image0\sce_sys\"
rmdir /s /q "%gameunpack%\Sc0\"

echo --------------------------------------------------------------------------------------
echo - Unpacking Update
echo - Please wait...
echo --------------------------------------------------------------------------------------

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%update%" `) do set "Up=%%P"
"%pubCmd%" img_extract --passcode 00000000000000000000000000000000  "%update%\%Up%" "%updateunpack%"

xcopy /e "%updateunpack%\Sc0\*" "%updateunpack%\Image0\sce_sys\"
rmdir /s /q "%updateunpack%\Sc0\"

echo --------------------------------------------------------------------------------------
echo - Merging Game and Update
echo - Please wait...
echo --------------------------------------------------------------------------------------

move "%gameunpack%\Image0" "%work%"

xcopy /e /y "%updateunpack%\*" "%work%"

rmdir /s /q "%gameunpack%"
rmdir /s /q "%updateunpack%"

echo --------------------------------------------------------------------------------------
echo - Extracting Backported Files
echo - Please wait...
echo --------------------------------------------------------------------------------------

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%BackportedFiles%"`) do set "Bp=%%P"
tools\7za.exe x "%BackportedFiles%\%Bp%"  -aoa -o"%work%"

Ren "%work%\Image0" Game-app

"%gengp4a%" "%work%\Game-app"

echo --------------------------------------------------------------------------------------
echo - Building FPKG
echo - Please wait...
echo --------------------------------------------------------------------------------------

"%pubCmd%" img_create --oformat pkg  "%work%\Game-app.gp4" "%cd%"


FOR /D %%p IN ("%work%\*") DO rmdir "%%p" /s /q
del /q "%work%\*.gp4"
del /q *compare_delta.log
EXIT



:Fix Game Info
color 0a

:: Stop if no game pkg found.
if not exist "%game%\*.pkg" echo - Folder GAME does not contains game pkg file.
if not exist "%game%\*.pkg" pause
if not exist "%game%\*.pkg" exit

IF EXIST "%cd%/tools/PS4-Fake-PKG-Tools-3.87-main" goto Merge2 (
) ELSE (
"%cd%/tools/wget.exe" "https://github.com/CyB1K/PS4-Fake-PKG-Tools-3.87/archive/refs/heads/main.zip"
"%cd%/tools/7za.exe" x "%cd%/main.zip" -o"%cd%/tools"
del main.zip
)

:Merge2
for /f "usebackq tokens=* delims=" %%P in (`dir /b "%game%" `) do set "G=%%P"
tools\sfk partcopy "%game%\%G%" 0x047 0x9 tools\id.txt -yes
for /f "tokens=* delims=," %%t in (tools\id.txt) do set FOLDER=%%t-patch
del tools\id.txt

mkdir "%FOLDER%\sce_sys"
set fix=%FOLDER%\sce_sys

echo --------------------------------------------------------------------------------------
echo - Unpacking Game
echo - Please wait...
echo --------------------------------------------------------------------------------------


for /f "usebackq tokens=* delims=" %%P in (`dir /b "%game%" `) do set "Ga=%%P"
"%pubCmd%" img_extract --passcode "00000000000000000000000000000000" "%game%\%Ga%":"Sc0" "%fix%"

del /q "%fix%\pic*.*"

"%sfo%" -q version "%game%\%Ga%" >"%work%\version.txt"
set /p GameVersion=<"%work%\version.txt"
if %GameVersion% == 01.00 goto Gversion (
) else (
"%sfo%" -e app_ver %GameVersion% "%fix%\param.sfo"
"%sfo%" -e version 01.00 "%fix%\param.sfo"
"%sfo%" -e category gp "%fix%\param.sfo"
goto gfix2
)

:Gversion
set /p GameVersion=Game Version (Format must be xx.xx): 

"%sfo%" -e app_ver %GameVersion% "%fix%\param.sfo"
"%sfo%" -e version 01.00 "%fix%\param.sfo"
"%sfo%" -e category gp "%fix%\param.sfo"

:gfix1
"%gengp4p%" "%FOLDER%"

"%pubCmd%" gp4_proj_update --app_path "%game%\%ga%" "%FOLDER%.gp4"

echo --------------------------------------------------------------------------------------
echo - Building FPKG
echo - Please wait...
echo --------------------------------------------------------------------------------------

"%pubCmd%" img_create --oformat pkg --skip_digest "%FOLDER%.gp4" "%cd%"

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%game%" `) do set "Gm=%%~nP"
ren "*.pkg"  "%Gm% - %GameVersion% Update (Game Fix Info).pkg"
goto gfix3

:gfix2
"%gengp4p%" "%FOLDER%"

"%pubCmd%" gp4_proj_update --app_path "%game%\%ga%" "%FOLDER%.gp4"

echo --------------------------------------------------------------------------------------
echo - Building FPKG
echo - Please wait...
echo --------------------------------------------------------------------------------------

"%pubCmd%" img_create --oformat pkg --skip_digest "%FOLDER%.gp4" "%cd%"

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%game%" `) do set "Gm=%%~nP"
ren "*.pkg"  "%Gm% - %GameVersion% Update (Game Fix Info).pkg"

:gfix3
del /q "%work%\*.*"
FOR /D %%p IN ("%work%\*") DO rmdir "%%p" /s /q
del /q "%cd%\*.gp4"
FOR /D %%p IN ("%FOLDER%") DO rmdir "%%p" /s /q
del /q *compare_delta.log
EXIT



:DLC - Change Region
color 0a
setlocal ENABLEDELAYEDEXPANSION


IF EXIST "%cd%/tools/PS4-Fake-PKG-Tools-3.87-main" goto Merge2 (
) ELSE (
"%cd%/tools/wget.exe" "https://github.com/CyB1K/PS4-Fake-PKG-Tools-3.87/archive/refs/heads/main.zip"
"%cd%/tools/7za.exe" x "%cd%/main.zip" -o"%cd%/tools"
del main.zip
)

:Merge2
FOR /R "%dlc%" %%i IN (*.pkg) DO MOVE "%%i" "%dlc%"
FOR /d %%d IN ("%dlc%\DLC_*") DO @IF EXIST "%%d" rd /s /q "%%d"

set "Num=1"
for %%i in ("%dlc%\*.pkg") do (if not exist "%dlc%\%%~ni" ( mkdir "%dlc%\DLC_!Num!" && move "%%~i" "%dlc%\DLC_!Num!" & set /A Num+=1))

if exist "%game%\*.pkg" goto test2
if not exist "%game%\*.pkg" goto test1


:test1

set /p XX=Input EP for Europe or UP for USA:
set /p CUSA=Input CUSA Number:CUSA
IF EXIST "%dlc%\DLC_1" (goto :dlc1) else goto :finish

:dlc1
echo --------------------------------------------------------------------------------------
echo - Unpacking DLC
echo - Please wait...
echo --------------------------------------------------------------------------------------

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%dlc%\DLC_1" `) do set "Dc=%%P"
"%pkgtool%" pkg_makegp4 --passcode "00000000000000000000000000000000" "%dlc%\DLC_1\%Dc%" "%dlcunpack%"

"%sfo%" -q content_id "%dlc%\DLC_1\%Dc%" >"%work%\123.txt"
set /p VAR=<"%work%\123.txt"
set fin=%VAR:~2,5%
set fen=%VAR:~16%

set ContentID=%XX%%fin%CUSA%CUSA%%fen%
"%sfo%" -e content_id %ContentID% "%dlcunpack%\sce_sys\param.sfo"

set titleId=%contentId:~7,9%

"%sfo%" -e title_id %TitleID% "%dlcunpack%\sce_sys\param.sfo"

"%pubCmd%" gp4_proj_update --content_id %ContentID% "%dlcunpack%\Project.gp4"

echo --------------------------------------------------------------------------------------
echo - Building FPKG
echo - Please wait...
echo --------------------------------------------------------------------------------------

"%pubCmd%" img_create --oformat pkg "%dlcunpack%\Project.gp4" "%cd%"

for /r "%dlc%\DLC_1" %%d in (*.*) do move "%%d" "%cd%\tools\Finished"

:dlc2
IF EXIST "%dlc%\DLC_2" (for /r "%dlc%\DLC_2" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc3
rd "%dlc%\DLC_2"
goto :dlc1 

:dlc3
IF EXIST "%dlc%\DLC_3" (for /r "%dlc%\DLC_3" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc4
rd "%dlc%\DLC_3"
goto :dlc1 

:dlc4
IF EXIST "%dlc%\DLC_4" (for /r "%dlc%\DLC_4" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc5
rd "%dlc%\DLC_4"
goto :dlc1 

:dlc5
IF EXIST "%dlc%\DLC_5" (for /r "%dlc%\DLC_5" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc6
rd "%dlc%\DLC_5"
goto :dlc1 

:dlc6
IF EXIST "%dlc%\DLC_6" (for /r "%dlc%\DLC_6" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc7
rd "%dlc%\DLC_6"
goto :dlc1 

:dlc7
IF EXIST "%dlc%\DLC_7" (for /r "%dlc%\DLC_7" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc8
rd "%dlc%\DLC_7"
goto :dlc1 

:dlc8
IF EXIST "%dlc%\DLC_8" (for /r "%dlc%\DLC_8" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc9
rd "%dlc%\DLC_8"
goto :dlc1 

:dlc9
IF EXIST "%dlc%\DLC_9" (for /r "%dlc%\DLC_9" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc10
rd "%dlc%\DLC_9"
goto :dlc1 

:dlc10
IF EXIST "%dlc%\DLC_10" (for /r "%dlc%\DLC_10" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc11
rd "%dlc%\DLC_10"
goto :dlc1 

:dlc11
IF EXIST "%dlc%\DLC_11" (for /r "%dlc%\DLC_11" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc12
rd "%dlc%\DLC_11"
goto :dlc1 

:dlc12
IF EXIST "%dlc%\DLC_12" (for /r "%dlc%\DLC_12" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc13
rd "%dlc%\DLC_12"
goto :dlc1 

:dlc13
IF EXIST "%dlc%\DLC_13" (for /r "%dlc%\DLC_13" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc14
rd "%dlc%\DLC_13"
goto :dlc1 

:dlc14
IF EXIST "%dlc%\DLC_14" (for /r "%dlc%\DLC_14" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc15
rd "%dlc%\DLC_14"
goto :dlc1 

:dlc15
IF EXIST "%dlc%\DLC_15" (for /r "%dlc%\DLC_15" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc16
rd "%dlc%\DLC_15"
goto :dlc1 

:dlc16
IF EXIST "%dlc%\DLC_16" (for /r "%dlc%\DLC_16" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc17
rd "%dlc%\DLC_16"
goto :dlc1 

:dlc17
IF EXIST "%dlc%\DLC_17" (for /r "%dlc%\DLC_17" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc18
rd "%dlc%\DLC_17"
goto :dlc1 

:dlc18
IF EXIST "%dlc%\DLC_18" (for /r "%dlc%\DLC_18" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc19
rd "%dlc%\DLC_18"
goto :dlc1 

:dlc19
IF EXIST "%dlc%\DLC_19" (for /r "%dlc%\DLC_19" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc20
rd "%dlc%\DLC_19"
goto :dlc1 

:dlc20
IF EXIST "%dlc%\DLC_20" (for /r "%dlc%\DLC_20" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc21
rd "%dlc%\DLC_20"
goto :dlc1 

:dlc21
IF EXIST "%dlc%\DLC_21" (for /r "%dlc%\DLC_21" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc22
rd "%dlc%\DLC_21"
goto :dlc1 

:dlc22
IF EXIST "%dlc%\DLC_22" (for /r "%dlc%\DLC_22" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc23
rd "%dlc%\DLC_22"
goto :dlc1 

:dlc23
IF EXIST "%dlc%\DLC_23" (for /r "%dlc%\DLC_23" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc24
rd "%dlc%\DLC_23"
goto :dlc1 

:dlc24
IF EXIST "%dlc%\DLC_24" (for /r "%dlc%\DLC_24" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc25
rd "%dlc%\DLC_24"
goto :dlc1 

:dlc25
IF EXIST "%dlc%\DLC_25" (for /r "%dlc%\DLC_25" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc26
rd "%dlc%\DLC_25"
goto :dlc1 

:dlc26
IF EXIST "%dlc%\DLC_26" (for /r "%dlc%\DLC_26" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc27
rd "%dlc%\DLC_26"
goto :dlc1 

:dlc27
IF EXIST "%dlc%\DLC_27" (for /r "%dlc%\DLC_27" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc28
rd "%dlc%\DLC_27"
goto :dlc1 

:dlc28
IF EXIST "%dlc%\DLC_28" (for /r "%dlc%\DLC_28" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc29
rd "%dlc%\DLC_28"
goto :dlc1

:dlc29
IF EXIST "%dlc%\DLC_29" (for /r "%dlc%\DLC_29" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc30
rd "%dlc%\DLC_29"
goto :dlc1 

:dlc30
IF EXIST "%dlc%\DLC_30" (for /r "%dlc%\DLC_30" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc31
rd "%dlc%\DLC_30"
goto :dlc1

:dlc31
IF EXIST "%dlc%\DLC_31" (for /r "%dlc%\DLC_31" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc32
rd "%dlc%\DLC_31"
goto :dlc1 

:dlc32
IF EXIST "%dlc%\DLC_32" (for /r "%dlc%\DLC_32" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc33
rd "%dlc%\DLC_32"
goto :dlc1 

:dlc33
IF EXIST "%dlc%\DLC_33" (for /r "%dlc%\DLC_33" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc34
rd "%dlc%\DLC_33"
goto :dlc1 

:dlc34
IF EXIST "%dlc%\DLC_34" (for /r "%dlc%\DLC_34" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc35
rd "%dlc%\DLC_34"
goto :dlc1 

:dlc35
IF EXIST "%dlc%\DLC_35" (for /r "%dlc%\DLC_35" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc36
rd "%dlc%\DLC_35"
goto :dlc1 

:dlc36
IF EXIST "%dlc%\DLC_36" (for /r "%dlc%\DLC_36" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc37
rd "%dlc%\DLC_36"
goto :dlc1 

:dlc37
IF EXIST "%dlc%\DLC_37" (for /r "%dlc%\DLC_37" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc38
rd "%dlc%\DLC_37"
goto :dlc1 

:dlc38
IF EXIST "%dlc%\DLC_38" (for /r "%dlc%\DLC_38" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc39
rd "%dlc%\DLC_38"
goto :dlc1

:dlc39
IF EXIST "%dlc%\DLC_39" (for /r "%dlc%\DLC_39" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc40
rd "%dlc%\DLC_39"
goto :dlc1

:dlc40
IF EXIST "%dlc%\DLC_40" (for /r "%dlc%\DLC_40" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc41
rd "%dlc%\DLC_40"
goto :dlc1

:dlc41
IF EXIST "%dlc%\DLC_41" (for /r "%dlc%\DLC_41" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc42
rd "%dlc%\DLC_41"
goto :dlc1 

:dlc42
IF EXIST "%dlc%\DLC_42" (for /r "%dlc%\DLC_42" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc43
rd "%dlc%\DLC_42"
goto :dlc1 

:dlc43
IF EXIST "%dlc%\DLC_43" (for /r "%dlc%\DLC_43" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc44
rd "%dlc%\DLC_43"
goto :dlc1 

:dlc44
IF EXIST "%dlc%\DLC_44" (for /r "%dlc%\DLC_44" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc45
rd "%dlc%\DLC_44"
goto :dlc1 

:dlc45
IF EXIST "%dlc%\DLC_45" (for /r "%dlc%\DLC_45" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc46
rd "%dlc%\DLC_45"
goto :dlc1 

:dlc46
IF EXIST "%dlc%\DLC_46" (for /r "%dlc%\DLC_46" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc47
rd "%dlc%\DLC_46"
goto :dlc1 

:dlc47
IF EXIST "%dlc%\DLC_47" (for /r "%dlc%\DLC_47" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc48
rd "%dlc%\DLC_47"
goto :dlc1 

:dlc48
IF EXIST "%dlc%\DLC_48" (for /r "%dlc%\DLC_48" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc49
rd "%dlc%\DLC_48"
goto :dlc1

:dlc49
IF EXIST "%dlc%\DLC_49" (for /r "%dlc%\DLC_49" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc50
rd "%dlc%\DLC_49"
goto :dlc1 

:dlc50
IF EXIST "%dlc%\DLC_50" (for /r "%dlc%\DLC_50" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc51
rd "%dlc%\DLC_50"
goto :dlc1 

:dlc51
IF EXIST "%dlc%\DLC_51" (for /r "%dlc%\DLC_51" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc52
rd "%dlc%\DLC_51"
goto :dlc1 

:dlc52
IF EXIST "%dlc%\DLC_52" (for /r "%dlc%\DLC_52" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc53
rd "%dlc%\DLC_52"
goto :dlc1 

:dlc53
IF EXIST "%dlc%\DLC_53" (for /r "%dlc%\DLC_53" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc54
rd "%dlc%\DLC_53"
goto :dlc1 

:dlc54
IF EXIST "%dlc%\DLC_54" (for /r "%dlc%\DLC_54" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc55
rd "%dlc%\DLC_54"
goto :dlc1 

:dlc55
IF EXIST "%dlc%\DLC_55" (for /r "%dlc%\DLC_55" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc56
rd "%dlc%\DLC_55"
goto :dlc1 

:dlc56
IF EXIST "%dlc%\DLC_56" (for /r "%dlc%\DLC_56" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc57
rd "%dlc%\DLC_56"
goto :dlc1 

:dlc57
IF EXIST "%dlc%\DLC_57" (for /r "%dlc%\DLC_57" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc58
rd "%dlc%\DLC_57"
goto :dlc1 

:dlc58
IF EXIST "%dlc%\DLC_58" (for /r "%dlc%\DLC_58" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc59
rd "%dlc%\DLC_58"
goto :dlc1

:dlc59
IF EXIST "%dlc%\DLC_59" (for /r "%dlc%\DLC_59" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc60
rd "%dlc%\DLC_59"
goto :dlc1 

:dlc60
IF EXIST "%dlc%\DLC_60" (for /r "%dlc%\DLC_60" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc61
rd "%dlc%\DLC_60"
goto :dlc1 

:dlc61
IF EXIST "%dlc%\DLC_61" (for /r "%dlc%\DLC_61" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc62
rd "%dlc%\DLC_61"
goto :dlc1 

:dlc62
IF EXIST "%dlc%\DLC_62" (for /r "%dlc%\DLC_62" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc63
rd "%dlc%\DLC_62"
goto :dlc1 

:dlc63
IF EXIST "%dlc%\DLC_63" (for /r "%dlc%\DLC_63" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc64
rd "%dlc%\DLC_63"
goto :dlc1 

:dlc64
IF EXIST "%dlc%\DLC_64" (for /r "%dlc%\DLC_64" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc65
rd "%dlc%\DLC_64"
goto :dlc1 

:dlc65
IF EXIST "%dlc%\DLC_65" (for /r "%dlc%\DLC_65" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc66
rd "%dlc%\DLC_65"
goto :dlc1 

:dlc66
IF EXIST "%dlc%\DLC_66" (for /r "%dlc%\DLC_66" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc67
rd "%dlc%\DLC_66"
goto :dlc1 

:dlc67
IF EXIST "%dlc%\DLC_67" (for /r "%dlc%\DLC_67" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc68
rd "%dlc%\DLC_67"
goto :dlc1 

:dlc68
IF EXIST "%dlc%\DLC_68" (for /r "%dlc%\DLC_68" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc69
rd "%dlc%\DLC_68"
goto :dlc1

:dlc69
IF EXIST "%dlc%\DLC_69" (for /r "%dlc%\DLC_69" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc70
rd "%dlc%\DLC_69"
goto :dlc1 

:dlc70
IF EXIST "%dlc%\DLC_70" (for /r "%dlc%\DLC_70" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc71
rd "%dlc%\DLC_70"
goto :dlc1 

:dlc71
IF EXIST "%dlc%\DLC_71" (for /r "%dlc%\DLC_71" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc72
rd "%dlc%\DLC_71"
goto :dlc1 

:dlc72
IF EXIST "%dlc%\DLC_72" (for /r "%dlc%\DLC_72" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc73
rd "%dlc%\DLC_72"
goto :dlc1 

:dlc73
IF EXIST "%dlc%\DLC_73" (for /r "%dlc%\DLC_73" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc74
rd "%dlc%\DLC_73"
goto :dlc1 

:dlc74
IF EXIST "%dlc%\DLC_74" (for /r "%dlc%\DLC_74" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc75
rd "%dlc%\DLC_74"
goto :dlc1 

:dlc75
IF EXIST "%dlc%\DLC_75" (for /r "%dlc%\DLC_75" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc76
rd "%dlc%\DLC_75"
goto :dlc1 

:dlc76
IF EXIST "%dlc%\DLC_76" (for /r "%dlc%\DLC_76" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc77
rd "%dlc%\DLC_76"
goto :dlc1 

:dlc77
IF EXIST "%dlc%\DLC_77" (for /r "%dlc%\DLC_77" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc78
rd "%dlc%\DLC_77"
goto :dlc1 

:dlc78
IF EXIST "%dlc%\DLC_78" (for /r "%dlc%\DLC_78" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc79
rd "%dlc%\DLC_78"
goto :dlc1

:dlc79
IF EXIST "%dlc%\DLC_79" (for /r "%dlc%\DLC_79" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc80
rd "%dlc%\DLC_79"
goto :dlc1 

:dlc80
IF EXIST "%dlc%\DLC_80" (for /r "%dlc%\DLC_80" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc81
rd "%dlc%\DLC_80"
goto :dlc1 

:dlc81
IF EXIST "%dlc%\DLC_81" (for /r "%dlc%\DLC_81" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc82
rd "%dlc%\DLC_81"
goto :dlc1 

:dlc82
IF EXIST "%dlc%\DLC_82" (for /r "%dlc%\DLC_82" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc83
rd "%dlc%\DLC_82"
goto :dlc1 

:dlc83
IF EXIST "%dlc%\DLC_83" (for /r "%dlc%\DLC_83" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc84
rd "%dlc%\DLC_83"
goto :dlc1 

:dlc84
IF EXIST "%dlc%\DLC_84" (for /r "%dlc%\DLC_84" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc85
rd "%dlc%\DLC_84"
goto :dlc1 

:dlc85
IF EXIST "%dlc%\DLC_85" (for /r "%dlc%\DLC_85" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc86
rd "%dlc%\DLC_85"
goto :dlc1 

:dlc86
IF EXIST "%dlc%\DLC_86" (for /r "%dlc%\DLC_86" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc87
rd "%dlc%\DLC_86"
goto :dlc1 

:dlc87
IF EXIST "%dlc%\DLC_87" (for /r "%dlc%\DLC_87" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc88
rd "%dlc%\DLC_87"
goto :dlc1 

:dlc88
IF EXIST "%dlc%\DLC_88" (for /r "%dlc%\DLC_88" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc89
rd "%dlc%\DLC_88"
goto :dlc1

:dlc89
IF EXIST "%dlc%\DLC_89" (for /r "%dlc%\DLC_89" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc90
rd "%dlc%\DLC_89"
goto :dlc1 

:dlc90
IF EXIST "%dlc%\DLC_90" (for /r "%dlc%\DLC_90" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc91
rd "%dlc%\DLC_90"
goto :dlc1 

:dlc91
IF EXIST "%dlc%\DLC_91" (for /r "%dlc%\DLC_91" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc92
rd "%dlc%\DLC_91"
goto :dlc1 

:dlc92
IF EXIST "%dlc%\DLC_92" (for /r "%dlc%\DLC_92" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc93
rd "%dlc%\DLC_92"
goto :dlc1 

:dlc93
IF EXIST "%dlc%\DLC_93" (for /r "%dlc%\DLC_93" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc94
rd "%dlc%\DLC_93"
goto :dlc1 

:dlc94
IF EXIST "%dlc%\DLC_94" (for /r "%dlc%\DLC_94" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc95
rd "%dlc%\DLC_94"
goto :dlc1 

:dlc95
IF EXIST "%dlc%\DLC_95" (for /r "%dlc%\DLC_95" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc96
rd "%dlc%\DLC_95"
goto :dlc1 

:dlc96
IF EXIST "%dlc%\DLC_96" (for /r "%dlc%\DLC_96" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc97
rd "%dlc%\DLC_96"
goto :dlc1 

:dlc97
IF EXIST "%dlc%\DLC_97" (for /r "%dlc%\DLC_97" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc98
rd "%dlc%\DLC_97"
goto :dlc1 

:dlc98
IF EXIST "%dlc%\DLC_98" (for /r "%dlc%\DLC_98" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc99
rd "%dlc%\DLC_98"
goto :dlc1

:dlc99
IF EXIST "%dlc%\DLC_99" (for /r "%dlc%\DLC_99" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc100
rd "%dlc%\DLC_99"
goto :dlc1 

:dlc100
IF EXIST "%dlc%\DLC_100" (for /r "%dlc%\DLC_100" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :finish
rd "%dlc%\DLC_100"
goto :dlc1 


goto finish


:test2

IF EXIST "%dlc%\DLC_1" (goto :dlc_1) else goto :finish

:dlc_1
echo --------------------------------------------------------------------------------------
echo - Unpacking DLC
echo - Please wait...
echo --------------------------------------------------------------------------------------

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%dlc%\DLC_1" `) do set "Dc=%%P"
"%pkgtool%" pkg_makegp4 --passcode "00000000000000000000000000000000" "%dlc%\DLC_1\%Dc%" "%dlcunpack%"

for /f "usebackq tokens=* delims=" %%G in (`dir /b "%game%" `) do set "Ga=%%G"
"%sfo%" -q content_id "%game%\%Ga%" >"%work%\123.txt"
set /p VAR=<"%work%\123.txt"
set fin=%VAR:~0,16%

"%sfo%" -q content_id "%dlc%\DLC_1\%Dc%" >"%work%\456.txt"
set /p VAR2=<"%work%\456.txt"
set fen=%VAR2:~16%

set ContentID=%fin%%fen%
"%sfo%" -e content_id %ContentID% "%dlcunpack%\sce_sys\param.sfo"

set titleId=%contentId:~7,9%

"%sfo%" -e title_id %TitleID% "%dlcunpack%\sce_sys\param.sfo"

"%pubCmd%" gp4_proj_update --content_id %ContentID% "%dlcunpack%\Project.gp4"

echo --------------------------------------------------------------------------------------
echo - Building FPKG
echo - Please wait...
echo --------------------------------------------------------------------------------------

"%pubCmd%" img_create --oformat pkg "%dlcunpack%\Project.gp4" "%cd%"


for /r "%dlc%\DLC_1" %%d in (*.*) do move "%%d" "%cd%\tools\Finished"

:dlc_2
IF EXIST "%dlc%\DLC_2" (for /r "%dlc%\DLC_2" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_3
rd "%dlc%\DLC_2"
goto :dlc_1 

:dlc_3
IF EXIST "%dlc%\DLC_3" (for /r "%dlc%\DLC_3" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_4
rd "%dlc%\DLC_3"
goto :dlc_1 

:dlc_4
IF EXIST "%dlc%\DLC_4" (for /r "%dlc%\DLC_4" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_5
rd "%dlc%\DLC_4"
goto :dlc_1 

:dlc_5
IF EXIST "%dlc%\DLC_5" (for /r "%dlc%\DLC_5" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_6
rd "%dlc%\DLC_5"
goto :dlc_1 

:dlc_6
IF EXIST "%dlc%\DLC_6" (for /r "%dlc%\DLC_6" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_7
rd "%dlc%\DLC_6"
goto :dlc_1 

:dlc_7
IF EXIST "%dlc%\DLC_7" (for /r "%dlc%\DLC_7" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_8
rd "%dlc%\DLC_7"
goto :dlc_1 

:dlc_8
IF EXIST "%dlc%\DLC_8" (for /r "%dlc%\DLC_8" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_9
rd "%dlc%\DLC_8"
goto :dlc_1 

:dlc_9
IF EXIST "%dlc%\DLC_9" (for /r "%dlc%\DLC_9" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_10
rd "%dlc%\DLC_9"
goto :dlc_1 

:dlc_10
IF EXIST "%dlc%\DLC_10" (for /r "%dlc%\DLC_10" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_11
rd "%dlc%\DLC_10"
goto :dlc_1 

:dlc_11
IF EXIST "%dlc%\DLC_11" (for /r "%dlc%\DLC_11" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_12
rd "%dlc%\DLC_11"
goto :dlc_1 

:dlc_12
IF EXIST "%dlc%\DLC_12" (for /r "%dlc%\DLC_12" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_13
rd "%dlc%\DLC_12"
goto :dlc_1 

:dlc_13
IF EXIST "%dlc%\DLC_13" (for /r "%dlc%\DLC_13" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_14
rd "%dlc%\DLC_13"
goto :dlc_1 

:dlc_14
IF EXIST "%dlc%\DLC_14" (for /r "%dlc%\DLC_14" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_15
rd "%dlc%\DLC_14"
goto :dlc_1 

:dlc_15
IF EXIST "%dlc%\DLC_15" (for /r "%dlc%\DLC_15" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_16
rd "%dlc%\DLC_15"
goto :dlc_1 

:dlc_16
IF EXIST "%dlc%\DLC_16" (for /r "%dlc%\DLC_16" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_17
rd "%dlc%\DLC_16"
goto :dlc_1 

:dlc_17
IF EXIST "%dlc%\DLC_17" (for /r "%dlc%\DLC_17" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_18
rd "%dlc%\DLC_17"
goto :dlc_1 

:dlc_18
IF EXIST "%dlc%\DLC_18" (for /r "%dlc%\DLC_18" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_19
rd "%dlc%\DLC_18"
goto :dlc_1 

:dlc_19
IF EXIST "%dlc%\DLC_19" (for /r "%dlc%\DLC_19" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_20
rd "%dlc%\DLC_19"
goto :dlc_1 

:dlc_20
IF EXIST "%dlc%\DLC_20" (for /r "%dlc%\DLC_20" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_21
rd "%dlc%\DLC_20"
goto :dlc_1 

:dlc_21
IF EXIST "%dlc%\DLC_21" (for /r "%dlc%\DLC_21" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_22
rd "%dlc%\DLC_21"
goto :dlc_1 

:dlc_22
IF EXIST "%dlc%\DLC_22" (for /r "%dlc%\DLC_22" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_23
rd "%dlc%\DLC_22"
goto :dlc_1 

:dlc_23
IF EXIST "%dlc%\DLC_23" (for /r "%dlc%\DLC_23" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_24
rd "%dlc%\DLC_23"
goto :dlc_1 

:dlc_24
IF EXIST "%dlc%\DLC_24" (for /r "%dlc%\DLC_24" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_25
rd "%dlc%\DLC_24"
goto :dlc_1 

:dlc_25
IF EXIST "%dlc%\DLC_25" (for /r "%dlc%\DLC_25" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_26
rd "%dlc%\DLC_25"
goto :dlc_1 

:dlc_26
IF EXIST "%dlc%\DLC_26" (for /r "%dlc%\DLC_26" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_27
rd "%dlc%\DLC_26"
goto :dlc_1 

:dlc_27
IF EXIST "%dlc%\DLC_27" (for /r "%dlc%\DLC_27" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_28
rd "%dlc%\DLC_27"
goto :dlc_1 

:dlc_28
IF EXIST "%dlc%\DLC_28" (for /r "%dlc%\DLC_28" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_29
rd "%dlc%\DLC_28"
goto :dlc_1

:dlc_29
IF EXIST "%dlc%\DLC_29" (for /r "%dlc%\DLC_29" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_30
rd "%dlc%\DLC_29"
goto :dlc_1 

:dlc_30
IF EXIST "%dlc%\DLC_30" (for /r "%dlc%\DLC_30" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_31
rd "%dlc%\DLC_30"
goto :dlc_1

:dlc_31
IF EXIST "%dlc%\DLC_31" (for /r "%dlc%\DLC_31" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_32
rd "%dlc%\DLC_31"
goto :dlc_1 

:dlc_32
IF EXIST "%dlc%\DLC_32" (for /r "%dlc%\DLC_32" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_33
rd "%dlc%\DLC_32"
goto :dlc_1 

:dlc_33
IF EXIST "%dlc%\DLC_33" (for /r "%dlc%\DLC_33" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_34
rd "%dlc%\DLC_33"
goto :dlc_1 

:dlc_34
IF EXIST "%dlc%\DLC_34" (for /r "%dlc%\DLC_34" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_35
rd "%dlc%\DLC_34"
goto :dlc_1 

:dlc_35
IF EXIST "%dlc%\DLC_35" (for /r "%dlc%\DLC_35" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_36
rd "%dlc%\DLC_35"
goto :dlc_1 

:dlc_36
IF EXIST "%dlc%\DLC_36" (for /r "%dlc%\DLC_36" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_37
rd "%dlc%\DLC_36"
goto :dlc_1 

:dlc_37
IF EXIST "%dlc%\DLC_37" (for /r "%dlc%\DLC_37" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_38
rd "%dlc%\DLC_37"
goto :dlc_1 

:dlc_38
IF EXIST "%dlc%\DLC_38" (for /r "%dlc%\DLC_38" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_39
rd "%dlc%\DLC_38"
goto :dlc_1

:dlc_39
IF EXIST "%dlc%\DLC_39" (for /r "%dlc%\DLC_39" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_40
rd "%dlc%\DLC_39"
goto :dlc_1

:dlc_40
IF EXIST "%dlc%\DLC_40" (for /r "%dlc%\DLC_40" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_41
rd "%dlc%\DLC_40"
goto :dlc_1

:dlc_41
IF EXIST "%dlc%\DLC_41" (for /r "%dlc%\DLC_41" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_42
rd "%dlc%\DLC_41"
goto :dlc_1 

:dlc_42
IF EXIST "%dlc%\DLC_42" (for /r "%dlc%\DLC_42" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_43
rd "%dlc%\DLC_42"
goto :dlc_1 

:dlc_43
IF EXIST "%dlc%\DLC_43" (for /r "%dlc%\DLC_43" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_44
rd "%dlc%\DLC_43"
goto :dlc_1 

:dlc_44
IF EXIST "%dlc%\DLC_44" (for /r "%dlc%\DLC_44" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_45
rd "%dlc%\DLC_44"
goto :dlc_1 

:dlc_45
IF EXIST "%dlc%\DLC_45" (for /r "%dlc%\DLC_45" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_46
rd "%dlc%\DLC_45"
goto :dlc_1 

:dlc_46
IF EXIST "%dlc%\DLC_46" (for /r "%dlc%\DLC_46" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_47
rd "%dlc%\DLC_46"
goto :dlc_1 

:dlc_47
IF EXIST "%dlc%\DLC_47" (for /r "%dlc%\DLC_47" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_48
rd "%dlc%\DLC_47"
goto :dlc_1 

:dlc_48
IF EXIST "%dlc%\DLC_48" (for /r "%dlc%\DLC_48" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_49
rd "%dlc%\DLC_48"
goto :dlc_1

:dlc_49
IF EXIST "%dlc%\DLC_49" (for /r "%dlc%\DLC_49" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_50
rd "%dlc%\DLC_49"
goto :dlc_1 

:dlc_50
IF EXIST "%dlc%\DLC_50" (for /r "%dlc%\DLC_50" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_51
rd "%dlc%\DLC_50"
goto :dlc_1 


:dlc_51
IF EXIST "%dlc%\DLC_51" (for /r "%dlc%\DLC_51" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_52
rd "%dlc%\DLC_51"
goto :dlc_1 

:dlc_52
IF EXIST "%dlc%\DLC_52" (for /r "%dlc%\DLC_52" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_53
rd "%dlc%\DLC_52"
goto :dlc_1 

:dlc_53
IF EXIST "%dlc%\DLC_53" (for /r "%dlc%\DLC_53" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_54
rd "%dlc%\DLC_53"
goto :dlc_1 

:dlc_54
IF EXIST "%dlc%\DLC_54" (for /r "%dlc%\DLC_54" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_55
rd "%dlc%\DLC_54"
goto :dlc_1 

:dlc_55
IF EXIST "%dlc%\DLC_55" (for /r "%dlc%\DLC_55" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_56
rd "%dlc%\DLC_55"
goto :dlc_1 

:dlc_56
IF EXIST "%dlc%\DLC_56" (for /r "%dlc%\DLC_56" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_57
rd "%dlc%\DLC_56"
goto :dlc_1 

:dlc_57
IF EXIST "%dlc%\DLC_57" (for /r "%dlc%\DLC_57" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_58
rd "%dlc%\DLC_57"
goto :dlc_1 

:dlc_58
IF EXIST "%dlc%\DLC_58" (for /r "%dlc%\DLC_58" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_59
rd "%dlc%\DLC_58"
goto :dlc_1

:dlc_59
IF EXIST "%dlc%\DLC_59" (for /r "%dlc%\DLC_59" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_60
rd "%dlc%\DLC_59"
goto :dlc_1 

:dlc_60
IF EXIST "%dlc%\DLC_60" (for /r "%dlc%\DLC_60" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_61
rd "%dlc%\DLC_60"
goto :dlc_1 

:dlc_61
IF EXIST "%dlc%\DLC_61" (for /r "%dlc%\DLC_61" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_62
rd "%dlc%\DLC_61"
goto :dlc_1 

:dlc_62
IF EXIST "%dlc%\DLC_62" (for /r "%dlc%\DLC_62" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_63
rd "%dlc%\DLC_62"
goto :dlc_1 

:dlc_63
IF EXIST "%dlc%\DLC_63" (for /r "%dlc%\DLC_63" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_64
rd "%dlc%\DLC_63"
goto :dlc_1 

:dlc_64
IF EXIST "%dlc%\DLC_64" (for /r "%dlc%\DLC_64" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_65
rd "%dlc%\DLC_64"
goto :dlc_1 

:dlc_65
IF EXIST "%dlc%\DLC_65" (for /r "%dlc%\DLC_65" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_66
rd "%dlc%\DLC_65"
goto :dlc_1 

:dlc_66
IF EXIST "%dlc%\DLC_66" (for /r "%dlc%\DLC_66" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_67
rd "%dlc%\DLC_66"
goto :dlc_1 

:dlc_67
IF EXIST "%dlc%\DLC_67" (for /r "%dlc%\DLC_67" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_68
rd "%dlc%\DLC_67"
goto :dlc_1 

:dlc_68
IF EXIST "%dlc%\DLC_68" (for /r "%dlc%\DLC_68" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_69
rd "%dlc%\DLC_68"
goto :dlc_1

:dlc_69
IF EXIST "%dlc%\DLC_69" (for /r "%dlc%\DLC_69" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_70
rd "%dlc%\DLC_69"
goto :dlc_1 

:dlc_70
IF EXIST "%dlc%\DLC_70" (for /r "%dlc%\DLC_70" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_71
rd "%dlc%\DLC_70"
goto :dlc_1 

:dlc_71
IF EXIST "%dlc%\DLC_71" (for /r "%dlc%\DLC_71" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_72
rd "%dlc%\DLC_71"
goto :dlc_1 

:dlc_72
IF EXIST "%dlc%\DLC_72" (for /r "%dlc%\DLC_72" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_73
rd "%dlc%\DLC_72"
goto :dlc_1 

:dlc_73
IF EXIST "%dlc%\DLC_73" (for /r "%dlc%\DLC_73" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_74
rd "%dlc%\DLC_73"
goto :dlc_1 

:dlc_74
IF EXIST "%dlc%\DLC_74" (for /r "%dlc%\DLC_74" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_75
rd "%dlc%\DLC_74"
goto :dlc_1 

:dlc_75
IF EXIST "%dlc%\DLC_75" (for /r "%dlc%\DLC_75" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_76
rd "%dlc%\DLC_75"
goto :dlc_1 

:dlc_76
IF EXIST "%dlc%\DLC_76" (for /r "%dlc%\DLC_76" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_77
rd "%dlc%\DLC_76"
goto :dlc_1 

:dlc_77
IF EXIST "%dlc%\DLC_77" (for /r "%dlc%\DLC_77" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_78
rd "%dlc%\DLC_77"
goto :dlc_1 

:dlc_78
IF EXIST "%dlc%\DLC_78" (for /r "%dlc%\DLC_78" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_79
rd "%dlc%\DLC_78"
goto :dlc_1

:dlc_79
IF EXIST "%dlc%\DLC_79" (for /r "%dlc%\DLC_79" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_80
rd "%dlc%\DLC_79"
goto :dlc_1 

:dlc_80
IF EXIST "%dlc%\DLC_80" (for /r "%dlc%\DLC_80" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_81
rd "%dlc%\DLC_80"
goto :dlc_1 

:dlc_81
IF EXIST "%dlc%\DLC_81" (for /r "%dlc%\DLC_81" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_82
rd "%dlc%\DLC_81"
goto :dlc_1 

:dlc_82
IF EXIST "%dlc%\DLC_82" (for /r "%dlc%\DLC_82" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_83
rd "%dlc%\DLC_82"
goto :dlc_1 

:dlc_83
IF EXIST "%dlc%\DLC_83" (for /r "%dlc%\DLC_83" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_84
rd "%dlc%\DLC_83"
goto :dlc_1 

:dlc_84
IF EXIST "%dlc%\DLC_84" (for /r "%dlc%\DLC_84" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_85
rd "%dlc%\DLC_84"
goto :dlc_1 

:dlc_85
IF EXIST "%dlc%\DLC_85" (for /r "%dlc%\DLC_85" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_86
rd "%dlc%\DLC_85"
goto :dlc_1 

:dlc_86
IF EXIST "%dlc%\DLC_86" (for /r "%dlc%\DLC_86" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_87
rd "%dlc%\DLC_86"
goto :dlc_1 

:dlc_87
IF EXIST "%dlc%\DLC_87" (for /r "%dlc%\DLC_87" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_88
rd "%dlc%\DLC_87"
goto :dlc_1 

:dlc_88
IF EXIST "%dlc%\DLC_88" (for /r "%dlc%\DLC_88" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_89
rd "%dlc%\DLC_88"
goto :dlc_1

:dlc_89
IF EXIST "%dlc%\DLC_89" (for /r "%dlc%\DLC_89" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_90
rd "%dlc%\DLC_89"
goto :dlc_1 

:dlc_90
IF EXIST "%dlc%\DLC_90" (for /r "%dlc%\DLC_90" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_91
rd "%dlc%\DLC_90"
goto :dlc_1 

:dlc_91
IF EXIST "%dlc%\DLC_91" (for /r "%dlc%\DLC_91" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_92
rd "%dlc%\DLC_91"
goto :dlc_1 

:dlc_92
IF EXIST "%dlc%\DLC_92" (for /r "%dlc%\DLC_92" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_93
rd "%dlc%\DLC_92"
goto :dlc_1 

:dlc_93
IF EXIST "%dlc%\DLC_93" (for /r "%dlc%\DLC_93" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_94
rd "%dlc%\DLC_93"
goto :dlc_1 

:dlc_94
IF EXIST "%dlc%\DLC_94" (for /r "%dlc%\DLC_94" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_95
rd "%dlc%\DLC_94"
goto :dlc_1 

:dlc_95
IF EXIST "%dlc%\DLC_95" (for /r "%dlc%\DLC_95" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_96
rd "%dlc%\DLC_95"
goto :dlc_1 

:dlc_96
IF EXIST "%dlc%\DLC_96" (for /r "%dlc%\DLC_96" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_97
rd "%dlc%\DLC_96"
goto :dlc_1 

:dlc_97
IF EXIST "%dlc%\DLC_97" (for /r "%dlc%\DLC_97" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_98
rd "%dlc%\DLC_97"
goto :dlc_1 

:dlc_98
IF EXIST "%dlc%\DLC_98" (for /r "%dlc%\DLC_98" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_99
rd "%dlc%\DLC_98"
goto :dlc_1

:dlc_99
IF EXIST "%dlc%\DLC_99" (for /r "%dlc%\DLC_99" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :dlc_100
rd "%dlc%\DLC_99"
goto :dlc_1 

:dlc_100
IF EXIST "%dlc%\DLC_100" (for /r "%dlc%\DLC_100" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :finish
rd "%dlc%\DLC_100"
goto :dlc_1 


:finish
for /r "%cd%\tools\Finished" %%d in (*.*) do move "%%d" "%dlc%"
for /f %%x In ("%cd%") Do "%cd%\tools\pkgrename.exe" --yes-to-all --pattern "(%%title_id%%) - %%dlc%% - %%title%%" 
for /d %%p IN ("%dlc%\*") DO rmdir "%%p" /s /q
del /q "%work%\*.*"
FOR /D %%p IN ("%work%\*") DO rmdir "%%p" /s /q
EXIT



:PS4-DLC Unlocker

IF EXIST "%cd%/tools/PS4-Fake-PKG-Tools-3.87-main" goto Merge2 (
) ELSE (
"%cd%/tools/wget.exe" "https://github.com/CyB1K/PS4-Fake-PKG-Tools-3.87/archive/refs/heads/main.zip"
"%cd%/tools/7za.exe" x "%cd%/main.zip" -o"%cd%/tools"
del main.zip
)

:Merge2
IF EXIST "%cd%\tools\PS4-Fake-PKG-Tools-3.87-main\psDLC.exe" goto step1 (
) ELSE (
xcopy "%cd%\tools\psDLC.exe" "%cd%\tools\PS4-Fake-PKG-Tools-3.87-main"
)

:step1
cls
echo.
echo  - If you want custom picture for DLC put that picture in root of this folder.
echo.
echo  - If folder GAME have game pkg inside that picture will be used.
echo.
echo  - Else DLC will have generic picture with PS4 logo.
echo.
pause

:step2
IF EXIST *.jpg (ren *.jpg icon0.jpg
"%cd%\tools\mogrify.exe" -format png *jpg
"%cd%\tools\mogrify.exe" -resize 512x512! *.png
del /q *.jpg
goto finish2
) ELSE (
goto step3
)

:step3
IF EXIST *.jpeg (ren *.jpeg icon0.jpeg
"%cd%\tools\mogrify.exe" -format png *jpeg
"%cd%\tools\mogrify.exe" -resize 512x512! *.png
del /q *.jpeg
goto finish2
) ELSE (
goto step4
)

:step4
IF EXIST *.bmp (ren *.bmp icon0.bmp
"%cd%\tools\mogrify.exe" -format png *bmp
"%cd%\tools\mogrify.exe" -resize 512x512! *.png
del /q *.bmp
goto finish2
) ELSE (
goto step5
)

:step5
IF EXIST *.png (ren *.png icon0.png
"%cd%\tools\mogrify.exe" -format png *png
"%cd%\tools\mogrify.exe" -resize 512x512! *.png
goto finish2
) ELSE (
goto step6
)

:step6
IF EXIST *.webp (ren *.webp icon0.webp
"%cd%\tools\mogrify.exe" -format png *webp
"%cd%\tools\mogrify.exe" -resize 512x512! *.png
del /q *.webp
goto finish2
) ELSE (
goto finish0
)


:finish0
for /f "usebackq tokens=* delims=" %%P in (`dir /b "%game%"`) do set "Gm=%%P"
if exist "%game%\*.pkg" (
"%pubCmd%" img_extract --passcode "00000000000000000000000000000000" "%game%\%Gm%":"Sc0/icon0.png" "%cd%"
goto finish2
) else (
goto finish1
)


:finish1
xcopy /y "%cd%\tools\icon0.png" "%cd%\tools\PS4-Fake-PKG-Tools-3.87-main"
cd "%cd%\tools\PS4-Fake-PKG-Tools-3.87-main" 
start /wait psDLC.exe

cd fake_dlc_pkg

If Exist *.pkg move *.pkg "..\..\.."
cd ..\..\..
"%cd%\tools\pkgrename.exe" --yes-to-all --pattern "(%%title_id%%) - %%dlc%% - %%title%%" 
) ELSE (
Exit
)
Exit


:finish2
move /y "%cd%\icon0.png" "%cd%\tools\PS4-Fake-PKG-Tools-3.87-main"
cd "%cd%\tools\PS4-Fake-PKG-Tools-3.87-main" 
start /wait psDLC.exe

cd fake_dlc_pkg

If Exist *.pkg move *.pkg "..\..\.."
del /q *.png
cd ..\..\..
"%cd%\tools\pkgrename.exe" --yes-to-all --pattern "(%%title_id%%) - %%dlc%% - %%title%%"
) ELSE (
Exit
)
Exit


:Without Data DLC to Data DLC
color 0a
setlocal ENABLEDELAYEDEXPANSION

:: Stop if no game pkg found.
if not exist "%dlc%\*.pkg" echo - Folder DLC does not contains DLC pkg file.
if not exist "%dlc%\*.pkg" pause
if not exist "%dlc%\*.pkg" exit

IF EXIST "%cd%/tools/PS4-Fake-PKG-Tools-3.87-main" goto pic2 (
) ELSE (
"%cd%/tools/wget.exe" "https://github.com/CyB1K/PS4-Fake-PKG-Tools-3.87/archive/refs/heads/main.zip"
"%cd%/tools/7za.exe" x "%cd%/main.zip" -o"%cd%/tools"
del main.zip
)

:pic2
cls
echo.
echo  - If you want custom picture for DLC put that picture in root of this folder.
echo.
echo  - If folder GAME have game pkg inside that picture will be used.
echo.
echo  - Else DLC will have generic picture with PS4 logo.
echo.
pause

IF EXIST *.jpg (ren *.jpg icon0.jpg
"%cd%\tools\mogrify.exe" -format png *jpg
"%cd%\tools\mogrify.exe" -resize 512x512! *.png
del /q *.jpg
goto Merge2
) ELSE (
goto pic3
)

:pic3
IF EXIST *.jpeg (ren *.jpeg icon0.jpeg
"%cd%\tools\mogrify.exe" -format png *jpeg
"%cd%\tools\mogrify.exe" -resize 512x512! *.png
del /q *.jpeg
goto Merge2
) ELSE (
goto pic4
)

:pic4
IF EXIST *.bmp (ren *.bmp icon0.bmp
"%cd%\tools\mogrify.exe" -format png *bmp
"%cd%\tools\mogrify.exe" -resize 512x512! *.png
del /q *.bmp
goto Merge2
) ELSE (
goto pic5
)

:pic5
IF EXIST *.png (ren *.png icon0.png
"%cd%\tools\mogrify.exe" -format png *png
"%cd%\tools\mogrify.exe" -resize 512x512! *.png
goto Merge2
) ELSE (
goto pic6
)

:pic6
IF EXIST *.webp (ren *.webp icon0.webp
"%cd%\tools\mogrify.exe" -format png *webp
"%cd%\tools\mogrify.exe" -resize 512x512! *.png
del /q *.webp
goto Merge2
) ELSE (
goto Merge2
)



:Merge2
set "Num=1"
for %%i in ("%dlc%\*.pkg") do (if not exist "%dlc%\%%~ni" ( mkdir "%dlc%\DLC_!Num!" && move "%%~i" "%dlc%\DLC_!Num!" & set /A Num+=1))

:cld1
for /f "usebackq tokens=* delims=" %%P in (`dir /b "%dlc%\DLC_1\" `) do set "Dc=%%P"
"%cd%\tools\sfo.exe" "%dlc%\DLC_1\%Dc%" -q title_id >"%cd%\tools\id.txt"
"%cd%\tools\sfo.exe" "%dlc%\DLC_1\%Dc%" -q content_id >"%cd%\tools\id2.txt"
for /f "tokens=* delims=," %%t in (tools\id.txt) do set FOLDER=%%t-ac_data
for /f "tokens=* delims=," %%a in (tools\id2.txt) do set contentID=%%a

mkdir "%FOLDER%"

echo --------------------------------------------------------------------------------------
echo - Unpacking DLC
echo - Please wait...
echo --------------------------------------------------------------------------------------


for /f "usebackq tokens=* delims=" %%P in (`dir /b "%dlc%\DLC_1\*.pkg" `) do set "Dl=%%P"
"%pubCmd%" img_extract --passcode 00000000000000000000000000000000 "%dlc%\DLC_1\%Dl%":"Sc0/param.sfo" "%FOLDER%"

for /f "usebackq tokens=* delims=" %%L in (`dir /b "%game%"`) do set "Ge=%%L"
if exist "%game%\*.pkg" (
"%pubCmd%" img_extract --passcode 00000000000000000000000000000000 "%game%\%Ge%":"Sc0/icon0.png" "%FOLDER%"
goto without2
) else (
goto without1
)

:without0
mkdir "%FOLDER%\sce_sys"
move "%cd%\icon0.png" "%FOLDER%\sce_sys"
move "%FOLDER%\param.sfo" "%FOLDER%\sce_sys"
xcopy /y "%cd%\tools\template.gp4" "%work%"
goto without3

:without1
if exist "%cd%\icon0.png" ( goto without0
) else (
mkdir "%FOLDER%\sce_sys"
xcopy /y "%cd%\tools\icon0.png" "%FOLDER%\sce_sys"
move "%FOLDER%\param.sfo" "%FOLDER%\sce_sys"
xcopy /y "%cd%\tools\template.gp4" "%work%"
goto without3
)

:without2
mkdir "%FOLDER%\sce_sys"
move "%FOLDER%\icon0.png" "%FOLDER%\sce_sys"
move "%FOLDER%\param.sfo" "%FOLDER%\sce_sys"
xcopy /y "%cd%\tools\template.gp4" "%work%"
goto without3

:without3
"%pubCmd%" gp4_proj_update --content_id %contentID% "%work%\template.gp4"
"%pubCmd%" gp4_proj_update --passcode 00000000000000000000000000000000 "%work%\template.gp4"

"%cd%\tools\fnr.exe" --cl --dir "%work%" --fileMask "*.gp4" --excludeFileMask "*.dll, *.exe" --includeSubDirectories --find ".." --replace "%cd%\%FOLDER%"

echo --------------------------------------------------------------------------------------
echo - Building Update
echo - Please wait...
echo --------------------------------------------------------------------------------------


"%pubCmd%" img_create --oformat pkg  "%work%\template.gp4" "%cd%"


for /r "%dlc%\DLC_1" %%d in (*.*) do move "%%d" "%cd%\tools\Finished"
del tools\id.txt
del tools\id2.txt
FOR /D %%p IN ("%FOLDER%") DO rmdir "%%p" /s /q
xcopy /y "%cd%\tools\template.gp4" "%work%"



:cld2
IF EXIST "%dlc%\DLC_2" (for /r "%dlc%\DLC_2" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld3
rd "%dlc%\DLC_2"
goto :cld1 


:cld3
IF EXIST "%dlc%\DLC_3" (for /r "%dlc%\DLC_3" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld4
rd "%dlc%\DLC_3"
goto :cld1 

:cld4
IF EXIST "%dlc%\DLC_4" (for /r "%dlc%\DLC_4" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld5
rd "%dlc%\DLC_4"
goto :cld1 

:cld5
IF EXIST "%dlc%\DLC_5" (for /r "%dlc%\DLC_5" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld6
rd "%dlc%\DLC_5"
goto :cld1 

:cld6
IF EXIST "%dlc%\DLC_6" (for /r "%dlc%\DLC_6" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld7
rd "%dlc%\DLC_6"
goto :cld1 

:cld7
IF EXIST "%dlc%\DLC_7" (for /r "%dlc%\DLC_7" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld8
rd "%dlc%\DLC_7"
goto :cld1 

:cld8
IF EXIST "%dlc%\DLC_8" (for /r "%dlc%\DLC_8" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld9
rd "%dlc%\DLC_8"
goto :cld1 

:cld9
IF EXIST "%dlc%\DLC_9" (for /r "%dlc%\DLC_9" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld10
rd "%dlc%\DLC_9"
goto :cld1 

:cld10
IF EXIST "%dlc%\DLC_10" (for /r "%dlc%\DLC_10" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld11
rd "%dlc%\DLC_10"
goto :cld1 

:cld11
IF EXIST "%dlc%\DLC_11" (for /r "%dlc%\DLC_11" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld12
rd "%dlc%\DLC_11"
goto :cld1 

:cld12
IF EXIST "%dlc%\DLC_12" (for /r "%dlc%\DLC_12" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld13
rd "%dlc%\DLC_12"
goto :cld1 

:cld13
IF EXIST "%dlc%\DLC_13" (for /r "%dlc%\DLC_13" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld14
rd "%dlc%\DLC_13"
goto :cld1 

:cld14
IF EXIST "%dlc%\DLC_14" (for /r "%dlc%\DLC_14" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld15
rd "%dlc%\DLC_14"
goto :cld1 

:cld15
IF EXIST "%dlc%\DLC_15" (for /r "%dlc%\DLC_15" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld16
rd "%dlc%\DLC_15"
goto :cld1 

:cld16
IF EXIST "%dlc%\DLC_16" (for /r "%dlc%\DLC_16" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld17
rd "%dlc%\DLC_16"
goto :cld1 

:cld17
IF EXIST "%dlc%\DLC_17" (for /r "%dlc%\DLC_17" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld18
rd "%dlc%\DLC_17"
goto :cld1 

:cld18
IF EXIST "%dlc%\DLC_18" (for /r "%dlc%\DLC_18" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld19
rd "%dlc%\DLC_18"
goto :cld1 

:cld19
IF EXIST "%dlc%\DLC_19" (for /r "%dlc%\DLC_19" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld20
rd "%dlc%\DLC_19"
goto :cld1 

:cld20
IF EXIST "%dlc%\DLC_20" (for /r "%dlc%\DLC_20" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld21
rd "%dlc%\DLC_20"
goto :cld1 

:cld21
IF EXIST "%dlc%\DLC_21" (for /r "%dlc%\DLC_21" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld22
rd "%dlc%\DLC_21"
goto :cld1 

:cld22
IF EXIST "%dlc%\DLC_22" (for /r "%dlc%\DLC_22" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld23
rd "%dlc%\DLC_22"
goto :cld1 

:cld23
IF EXIST "%dlc%\DLC_23" (for /r "%dlc%\DLC_23" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld24
rd "%dlc%\DLC_23"
goto :cld1 

:cld24
IF EXIST "%dlc%\DLC_24" (for /r "%dlc%\DLC_24" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld25
rd "%dlc%\DLC_24"
goto :cld1 

:cld25
IF EXIST "%dlc%\DLC_25" (for /r "%dlc%\DLC_25" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld26
rd "%dlc%\DLC_25"
goto :cld1 

:cld26
IF EXIST "%dlc%\DLC_26" (for /r "%dlc%\DLC_26" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld27
rd "%dlc%\DLC_26"
goto :cld1 

:cld27
IF EXIST "%dlc%\DLC_27" (for /r "%dlc%\DLC_27" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld28
rd "%dlc%\DLC_27"
goto :cld1 

:cld28
IF EXIST "%dlc%\DLC_28" (for /r "%dlc%\DLC_28" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld29
rd "%dlc%\DLC_28"
goto :cld1

:cld29
IF EXIST "%dlc%\DLC_29" (for /r "%dlc%\DLC_29" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld30
rd "%dlc%\DLC_29"
goto :cld1 

:cld30
IF EXIST "%dlc%\DLC_30" (for /r "%dlc%\DLC_30" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld31
rd "%dlc%\DLC_30"
goto :cld1

:cld31
IF EXIST "%dlc%\DLC_31" (for /r "%dlc%\DLC_31" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld32
rd "%dlc%\DLC_31"
goto :cld1 

:cld32
IF EXIST "%dlc%\DLC_32" (for /r "%dlc%\DLC_32" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld33
rd "%dlc%\DLC_32"
goto :cld1 

:cld33
IF EXIST "%dlc%\DLC_33" (for /r "%dlc%\DLC_33" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld34
rd "%dlc%\DLC_33"
goto :cld1 

:cld34
IF EXIST "%dlc%\DLC_34" (for /r "%dlc%\DLC_34" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld35
rd "%dlc%\DLC_34"
goto :cld1 

:cld35
IF EXIST "%dlc%\DLC_35" (for /r "%dlc%\DLC_35" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld36
rd "%dlc%\DLC_35"
goto :cld1 

:cld36
IF EXIST "%dlc%\DLC_36" (for /r "%dlc%\DLC_36" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld37
rd "%dlc%\DLC_36"
goto :cld1 

:cld37
IF EXIST "%dlc%\DLC_37" (for /r "%dlc%\DLC_37" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld38
rd "%dlc%\DLC_37"
goto :cld1 

:cld38
IF EXIST "%dlc%\DLC_38" (for /r "%dlc%\DLC_38" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld39
rd "%dlc%\DLC_38"
goto :cld1

:cld39
IF EXIST "%dlc%\DLC_39" (for /r "%dlc%\DLC_39" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld40
rd "%dlc%\DLC_39"
goto :cld1

:cld40
IF EXIST "%dlc%\DLC_40" (for /r "%dlc%\DLC_40" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld41
rd "%dlc%\DLC_40"
goto :cld1

:cld41
IF EXIST "%dlc%\DLC_41" (for /r "%dlc%\DLC_41" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld42
rd "%dlc%\DLC_41"
goto :cld1 

:cld42
IF EXIST "%dlc%\DLC_42" (for /r "%dlc%\DLC_42" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld43
rd "%dlc%\DLC_42"
goto :cld1 

:cld43
IF EXIST "%dlc%\DLC_43" (for /r "%dlc%\DLC_43" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld44
rd "%dlc%\DLC_43"
goto :cld1 

:cld44
IF EXIST "%dlc%\DLC_44" (for /r "%dlc%\DLC_44" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld45
rd "%dlc%\DLC_44"
goto :cld1 

:cld45
IF EXIST "%dlc%\DLC_45" (for /r "%dlc%\DLC_45" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld46
rd "%dlc%\DLC_45"
goto :cld1 

:cld46
IF EXIST "%dlc%\DLC_46" (for /r "%dlc%\DLC_46" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld47
rd "%dlc%\DLC_46"
goto :cld1 

:cld47
IF EXIST "%dlc%\DLC_47" (for /r "%dlc%\DLC_47" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld48
rd "%dlc%\DLC_47"
goto :cld1 

:cld48
IF EXIST "%dlc%\DLC_48" (for /r "%dlc%\DLC_48" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld49
rd "%dlc%\DLC_48"
goto :cld1

:cld49
IF EXIST "%dlc%\DLC_49" (for /r "%dlc%\DLC_49" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld50
rd "%dlc%\DLC_49"
goto :cld1 

:cld50
IF EXIST "%dlc%\DLC_50" (for /r "%dlc%\DLC_50" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld51
rd "%dlc%\DLC_50"
goto :cld1 

:cld51
IF EXIST "%dlc%\DLC_51" (for /r "%dlc%\DLC_51" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld52
rd "%dlc%\DLC_51"
goto :cld1 

:cld52
IF EXIST "%dlc%\DLC_52" (for /r "%dlc%\DLC_52" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld53
rd "%dlc%\DLC_52"
goto :cld1 

:cld53
IF EXIST "%dlc%\DLC_53" (for /r "%dlc%\DLC_53" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld54
rd "%dlc%\DLC_53"
goto :cld1 

:cld54
IF EXIST "%dlc%\DLC_54" (for /r "%dlc%\DLC_54" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld55
rd "%dlc%\DLC_54"
goto :cld1 

:cld55
IF EXIST "%dlc%\DLC_55" (for /r "%dlc%\DLC_55" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld56
rd "%dlc%\DLC_55"
goto :cld1 

:cld56
IF EXIST "%dlc%\DLC_56" (for /r "%dlc%\DLC_56" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld57
rd "%dlc%\DLC_56"
goto :cld1 

:cld57
IF EXIST "%dlc%\DLC_57" (for /r "%dlc%\DLC_57" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld58
rd "%dlc%\DLC_57"
goto :cld1 

:cld58
IF EXIST "%dlc%\DLC_58" (for /r "%dlc%\DLC_58" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld59
rd "%dlc%\DLC_58"
goto :cld1

:cld59
IF EXIST "%dlc%\DLC_59" (for /r "%dlc%\DLC_59" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld60
rd "%dlc%\DLC_59"
goto :cld1 

:cld60
IF EXIST "%dlc%\DLC_60" (for /r "%dlc%\DLC_60" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld61
rd "%dlc%\DLC_60"
goto :cld1 

:cld61
IF EXIST "%dlc%\DLC_61" (for /r "%dlc%\DLC_61" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld62
rd "%dlc%\DLC_61"
goto :cld1 

:cld62
IF EXIST "%dlc%\DLC_62" (for /r "%dlc%\DLC_62" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld63
rd "%dlc%\DLC_62"
goto :cld1 

:cld63
IF EXIST "%dlc%\DLC_63" (for /r "%dlc%\DLC_63" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld64
rd "%dlc%\DLC_63"
goto :cld1 

:cld64
IF EXIST "%dlc%\DLC_64" (for /r "%dlc%\DLC_64" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld65
rd "%dlc%\DLC_64"
goto :cld1 

:cld65
IF EXIST "%dlc%\DLC_65" (for /r "%dlc%\DLC_65" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld66
rd "%dlc%\DLC_65"
goto :cld1 

:cld66
IF EXIST "%dlc%\DLC_66" (for /r "%dlc%\DLC_66" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld67
rd "%dlc%\DLC_66"
goto :cld1 

:cld67
IF EXIST "%dlc%\DLC_67" (for /r "%dlc%\DLC_67" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld68
rd "%dlc%\DLC_67"
goto :cld1 

:cld68
IF EXIST "%dlc%\DLC_68" (for /r "%dlc%\DLC_68" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld69
rd "%dlc%\DLC_68"
goto :cld1

:cld69
IF EXIST "%dlc%\DLC_69" (for /r "%dlc%\DLC_69" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld70
rd "%dlc%\DLC_69"
goto :cld1 

:cld70
IF EXIST "%dlc%\DLC_70" (for /r "%dlc%\DLC_70" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld71
rd "%dlc%\DLC_70"
goto :cld1 

:cld71
IF EXIST "%dlc%\DLC_71" (for /r "%dlc%\DLC_71" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld72
rd "%dlc%\DLC_71"
goto :cld1 

:cld72
IF EXIST "%dlc%\DLC_72" (for /r "%dlc%\DLC_72" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld73
rd "%dlc%\DLC_72"
goto :cld1 

:cld73
IF EXIST "%dlc%\DLC_73" (for /r "%dlc%\DLC_73" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld74
rd "%dlc%\DLC_73"
goto :cld1 

:cld74
IF EXIST "%dlc%\DLC_74" (for /r "%dlc%\DLC_74" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld75
rd "%dlc%\DLC_74"
goto :cld1 

:cld75
IF EXIST "%dlc%\DLC_75" (for /r "%dlc%\DLC_75" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld76
rd "%dlc%\DLC_75"
goto :cld1 

:cld76
IF EXIST "%dlc%\DLC_76" (for /r "%dlc%\DLC_76" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld77
rd "%dlc%\DLC_76"
goto :cld1 

:cld77
IF EXIST "%dlc%\DLC_77" (for /r "%dlc%\DLC_77" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld78
rd "%dlc%\DLC_77"
goto :cld1 

:cld78
IF EXIST "%dlc%\DLC_78" (for /r "%dlc%\DLC_78" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld79
rd "%dlc%\DLC_78"
goto :cld1

:cld79
IF EXIST "%dlc%\DLC_79" (for /r "%dlc%\DLC_79" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld80
rd "%dlc%\DLC_79"
goto :cld1 

:cld80
IF EXIST "%dlc%\DLC_80" (for /r "%dlc%\DLC_80" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld81
rd "%dlc%\DLC_80"
goto :cld1 

:cld81
IF EXIST "%dlc%\DLC_81" (for /r "%dlc%\DLC_81" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld82
rd "%dlc%\DLC_81"
goto :cld1 

:cld82
IF EXIST "%dlc%\DLC_82" (for /r "%dlc%\DLC_82" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld83
rd "%dlc%\DLC_82"
goto :cld1 

:cld83
IF EXIST "%dlc%\DLC_83" (for /r "%dlc%\DLC_83" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld84
rd "%dlc%\DLC_83"
goto :cld1 

:cld84
IF EXIST "%dlc%\DLC_84" (for /r "%dlc%\DLC_84" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld85
rd "%dlc%\DLC_84"
goto :cld1 

:cld85
IF EXIST "%dlc%\DLC_85" (for /r "%dlc%\DLC_85" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld86
rd "%dlc%\DLC_85"
goto :cld1 

:cld86
IF EXIST "%dlc%\DLC_86" (for /r "%dlc%\DLC_86" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld87
rd "%dlc%\DLC_86"
goto :cld1 

:cld87
IF EXIST "%dlc%\DLC_87" (for /r "%dlc%\DLC_87" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld88
rd "%dlc%\DLC_87"
goto :cld1 

:cld88
IF EXIST "%dlc%\DLC_88" (for /r "%dlc%\DLC_88" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld89
rd "%dlc%\DLC_88"
goto :cld1

:cld89
IF EXIST "%dlc%\DLC_89" (for /r "%dlc%\DLC_89" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld90
rd "%dlc%\DLC_89"
goto :cld1 

:cld90
IF EXIST "%dlc%\DLC_90" (for /r "%dlc%\DLC_90" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld91
rd "%dlc%\DLC_90"
goto :cld1 

:cld91
IF EXIST "%dlc%\DLC_91" (for /r "%dlc%\DLC_91" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld92
rd "%dlc%\DLC_91"
goto :cld1 

:cld92
IF EXIST "%dlc%\DLC_92" (for /r "%dlc%\DLC_92" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld93
rd "%dlc%\DLC_92"
goto :cld1 

:cld93
IF EXIST "%dlc%\DLC_93" (for /r "%dlc%\DLC_93" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld94
rd "%dlc%\DLC_93"
goto :cld1 

:cld94
IF EXIST "%dlc%\DLC_94" (for /r "%dlc%\DLC_94" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld95
rd "%dlc%\DLC_94"
goto :cld1 

:cld95
IF EXIST "%dlc%\DLC_95" (for /r "%dlc%\DLC_95" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld96
rd "%dlc%\DLC_95"
goto :cld1 

:cld96
IF EXIST "%dlc%\DLC_96" (for /r "%dlc%\DLC_96" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld97
rd "%dlc%\DLC_96"
goto :cld1 

:cld97
IF EXIST "%dlc%\DLC_97" (for /r "%dlc%\DLC_97" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld98
rd "%dlc%\DLC_97"
goto :cld1 

:cld98
IF EXIST "%dlc%\DLC_98" (for /r "%dlc%\DLC_98" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld99
rd "%dlc%\DLC_98"
goto :cld1

:cld99
IF EXIST "%dlc%\DLC_99" (for /r "%dlc%\DLC_99" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :cld100
rd "%dlc%\DLC_99"
goto :cld1 

:cld100
IF EXIST "%dlc%\DLC_100" (for /r "%dlc%\DLC_100" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :finish
rd "%dlc%\DLC_100"
goto :cld1 


goto finish

:finish
for /r "%cd%\tools\Finished" %%d in (*.*) do move "%%d" "%dlc%"
for /f %%x In ("%cd%") Do "%cd%\tools\pkgrename.exe" --yes-to-all --pattern "(%%title_id%%) - %%dlc%% - %%title%%" 
for /d %%p IN ("%dlc%\*") DO rmdir "%%p" /s /q
del /q "%work%\*.*"
FOR /D %%p IN ("%work%\*") DO rmdir "%%p" /s /q
EXIT



:Data DLC to Without Data DLC
color 0a
setlocal ENABLEDELAYEDEXPANSION

:: Stop if no game pkg found.
if not exist "%dlc%\*.pkg" echo - Folder DLC does not contains DLC pkg file.
if not exist "%dlc%\*.pkg" pause
if not exist "%dlc%\*.pkg" exit

IF EXIST "%cd%/tools/PS4-Fake-PKG-Tools-3.87-main" goto Merge2 (
) ELSE (
"%cd%/tools/wget.exe" "https://github.com/CyB1K/PS4-Fake-PKG-Tools-3.87/archive/refs/heads/main.zip"
"%cd%/tools/7za.exe" x "%cd%/main.zip" -o"%cd%/tools"
del main.zip
)


:Merge2
set "Num=1"
for %%i in ("%dlc%\*.pkg") do (if not exist "%dlc%\%%~ni" ( mkdir "%dlc%\DLC_!Num!" && move "%%~i" "%dlc%\DLC_!Num!" & set /A Num+=1))

:lcd1
for /f "usebackq tokens=* delims=" %%P in (`dir /b "%dlc%\DLC_1\" `) do set "Dc=%%P"
"%cd%\tools\sfo.exe" "%dlc%\DLC_1\%Dc%" -q title_id >"%cd%\tools\id.txt"
"%cd%\tools\sfo.exe" "%dlc%\DLC_1\%Dc%" -q content_id >"%cd%\tools\id2.txt"
for /f "tokens=* delims=," %%t in (tools\id.txt) do set FOLDER=%%t-ac_nodata
for /f "tokens=* delims=," %%a in (tools\id2.txt) do set contentID=%%a

mkdir "%FOLDER%"

echo --------------------------------------------------------------------------------------
echo - Unpacking DLC
echo - Please wait...
echo --------------------------------------------------------------------------------------

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%dlc%\DLC_1\*.pkg" `) do set "Dl=%%P"
"%pubCmd%" img_extract --passcode 00000000000000000000000000000000 "%dlc%\DLC_1\%Dl%":"Sc0/param.sfo" "%FOLDER%"
"%pubCmd%" img_extract --passcode 00000000000000000000000000000000 "%dlc%\DLC_1\%Dl%":"Sc0/icon0.png" "%FOLDER%"
goto with1


:with1
mkdir "%FOLDER%\sce_sys"
move "%FOLDER%\icon0.png" "%FOLDER%\sce_sys"
move "%FOLDER%\param.sfo" "%FOLDER%\sce_sys"
xcopy /y "%cd%\tools\template2.gp4" "%work%"
"%pubCmd%" gp4_proj_update --content_id %contentID% "%work%\template2.gp4"
"%pubCmd%" gp4_proj_update --passcode 00000000000000000000000000000000 "%work%\template2.gp4"
"%cd%\tools\fnr.exe" --cl --dir "%work%" --fileMask "*.gp4" --excludeFileMask "*.dll, *.exe" --includeSubDirectories --find ".." --replace "%cd%\%FOLDER%"

echo --------------------------------------------------------------------------------------
echo - Building Update
echo - Please wait...
echo --------------------------------------------------------------------------------------


"%pubCmd%" img_create --oformat pkg  "%work%\template2.gp4" "%cd%"


for /r "%dlc%\DLC_1" %%d in (*.*) do move "%%d" "%cd%\tools\Finished"
del tools\id.txt
del tools\id2.txt
FOR /D %%p IN ("%FOLDER%") DO rmdir "%%p" /s /q
xcopy /y "%cd%\tools\template.gp4" "%work%"



:lcd2
IF EXIST "%dlc%\DLC_2" (for /r "%dlc%\DLC_2" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd3
rd "%dlc%\DLC_2"
goto :lcd1 


:lcd3
IF EXIST "%dlc%\DLC_3" (for /r "%dlc%\DLC_3" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd4
rd "%dlc%\DLC_3"
goto :lcd1 

:lcd4
IF EXIST "%dlc%\DLC_4" (for /r "%dlc%\DLC_4" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd5
rd "%dlc%\DLC_4"
goto :lcd1 

:lcd5
IF EXIST "%dlc%\DLC_5" (for /r "%dlc%\DLC_5" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd6
rd "%dlc%\DLC_5"
goto :lcd1 

:lcd6
IF EXIST "%dlc%\DLC_6" (for /r "%dlc%\DLC_6" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd7
rd "%dlc%\DLC_6"
goto :lcd1 

:lcd7
IF EXIST "%dlc%\DLC_7" (for /r "%dlc%\DLC_7" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd8
rd "%dlc%\DLC_7"
goto :lcd1 

:lcd8
IF EXIST "%dlc%\DLC_8" (for /r "%dlc%\DLC_8" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd9
rd "%dlc%\DLC_8"
goto :lcd1 

:lcd9
IF EXIST "%dlc%\DLC_9" (for /r "%dlc%\DLC_9" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd10
rd "%dlc%\DLC_9"
goto :lcd1 

:lcd10
IF EXIST "%dlc%\DLC_10" (for /r "%dlc%\DLC_10" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd11
rd "%dlc%\DLC_10"
goto :lcd1 

:lcd11
IF EXIST "%dlc%\DLC_11" (for /r "%dlc%\DLC_11" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd12
rd "%dlc%\DLC_11"
goto :lcd1 

:lcd12
IF EXIST "%dlc%\DLC_12" (for /r "%dlc%\DLC_12" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd13
rd "%dlc%\DLC_12"
goto :lcd1 

:lcd13
IF EXIST "%dlc%\DLC_13" (for /r "%dlc%\DLC_13" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd14
rd "%dlc%\DLC_13"
goto :lcd1 

:lcd14
IF EXIST "%dlc%\DLC_14" (for /r "%dlc%\DLC_14" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd15
rd "%dlc%\DLC_14"
goto :lcd1 

:lcd15
IF EXIST "%dlc%\DLC_15" (for /r "%dlc%\DLC_15" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd16
rd "%dlc%\DLC_15"
goto :lcd1 

:lcd16
IF EXIST "%dlc%\DLC_16" (for /r "%dlc%\DLC_16" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd17
rd "%dlc%\DLC_16"
goto :lcd1 

:lcd17
IF EXIST "%dlc%\DLC_17" (for /r "%dlc%\DLC_17" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd18
rd "%dlc%\DLC_17"
goto :lcd1 

:lcd18
IF EXIST "%dlc%\DLC_18" (for /r "%dlc%\DLC_18" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd19
rd "%dlc%\DLC_18"
goto :lcd1 

:lcd19
IF EXIST "%dlc%\DLC_19" (for /r "%dlc%\DLC_19" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd20
rd "%dlc%\DLC_19"
goto :lcd1 

:lcd20
IF EXIST "%dlc%\DLC_20" (for /r "%dlc%\DLC_20" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd21
rd "%dlc%\DLC_20"
goto :lcd1 

:lcd21
IF EXIST "%dlc%\DLC_21" (for /r "%dlc%\DLC_21" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd22
rd "%dlc%\DLC_21"
goto :lcd1 

:lcd22
IF EXIST "%dlc%\DLC_22" (for /r "%dlc%\DLC_22" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd23
rd "%dlc%\DLC_22"
goto :lcd1 

:lcd23
IF EXIST "%dlc%\DLC_23" (for /r "%dlc%\DLC_23" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd24
rd "%dlc%\DLC_23"
goto :lcd1 

:lcd24
IF EXIST "%dlc%\DLC_24" (for /r "%dlc%\DLC_24" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd25
rd "%dlc%\DLC_24"
goto :lcd1 

:lcd25
IF EXIST "%dlc%\DLC_25" (for /r "%dlc%\DLC_25" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd26
rd "%dlc%\DLC_25"
goto :lcd1 

:lcd26
IF EXIST "%dlc%\DLC_26" (for /r "%dlc%\DLC_26" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd27
rd "%dlc%\DLC_26"
goto :lcd1 

:lcd27
IF EXIST "%dlc%\DLC_27" (for /r "%dlc%\DLC_27" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd28
rd "%dlc%\DLC_27"
goto :lcd1 

:lcd28
IF EXIST "%dlc%\DLC_28" (for /r "%dlc%\DLC_28" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd29
rd "%dlc%\DLC_28"
goto :lcd1

:lcd29
IF EXIST "%dlc%\DLC_29" (for /r "%dlc%\DLC_29" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd30
rd "%dlc%\DLC_29"
goto :lcd1 

:lcd30
IF EXIST "%dlc%\DLC_30" (for /r "%dlc%\DLC_30" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd31
rd "%dlc%\DLC_30"
goto :lcd1

:lcd31
IF EXIST "%dlc%\DLC_31" (for /r "%dlc%\DLC_31" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd32
rd "%dlc%\DLC_31"
goto :lcd1 

:lcd32
IF EXIST "%dlc%\DLC_32" (for /r "%dlc%\DLC_32" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd33
rd "%dlc%\DLC_32"
goto :lcd1 

:lcd33
IF EXIST "%dlc%\DLC_33" (for /r "%dlc%\DLC_33" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd34
rd "%dlc%\DLC_33"
goto :lcd1 

:lcd34
IF EXIST "%dlc%\DLC_34" (for /r "%dlc%\DLC_34" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd35
rd "%dlc%\DLC_34"
goto :lcd1 

:lcd35
IF EXIST "%dlc%\DLC_35" (for /r "%dlc%\DLC_35" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd36
rd "%dlc%\DLC_35"
goto :lcd1 

:lcd36
IF EXIST "%dlc%\DLC_36" (for /r "%dlc%\DLC_36" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd37
rd "%dlc%\DLC_36"
goto :lcd1 

:lcd37
IF EXIST "%dlc%\DLC_37" (for /r "%dlc%\DLC_37" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd38
rd "%dlc%\DLC_37"
goto :lcd1 

:lcd38
IF EXIST "%dlc%\DLC_38" (for /r "%dlc%\DLC_38" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd39
rd "%dlc%\DLC_38"
goto :lcd1

:lcd39
IF EXIST "%dlc%\DLC_39" (for /r "%dlc%\DLC_39" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd40
rd "%dlc%\DLC_39"
goto :lcd1

:lcd40
IF EXIST "%dlc%\DLC_40" (for /r "%dlc%\DLC_40" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd41
rd "%dlc%\DLC_40"
goto :lcd1

:lcd41
IF EXIST "%dlc%\DLC_41" (for /r "%dlc%\DLC_41" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd42
rd "%dlc%\DLC_41"
goto :lcd1 

:lcd42
IF EXIST "%dlc%\DLC_42" (for /r "%dlc%\DLC_42" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd43
rd "%dlc%\DLC_42"
goto :lcd1 

:lcd43
IF EXIST "%dlc%\DLC_43" (for /r "%dlc%\DLC_43" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd44
rd "%dlc%\DLC_43"
goto :lcd1 

:lcd44
IF EXIST "%dlc%\DLC_44" (for /r "%dlc%\DLC_44" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd45
rd "%dlc%\DLC_44"
goto :lcd1 

:lcd45
IF EXIST "%dlc%\DLC_45" (for /r "%dlc%\DLC_45" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd46
rd "%dlc%\DLC_45"
goto :lcd1 

:lcd46
IF EXIST "%dlc%\DLC_46" (for /r "%dlc%\DLC_46" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd47
rd "%dlc%\DLC_46"
goto :lcd1 

:lcd47
IF EXIST "%dlc%\DLC_47" (for /r "%dlc%\DLC_47" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd48
rd "%dlc%\DLC_47"
goto :lcd1 

:lcd48
IF EXIST "%dlc%\DLC_48" (for /r "%dlc%\DLC_48" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd49
rd "%dlc%\DLC_48"
goto :lcd1

:lcd49
IF EXIST "%dlc%\DLC_49" (for /r "%dlc%\DLC_49" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd50
rd "%dlc%\DLC_49"
goto :lcd1 

:lcd50
IF EXIST "%dlc%\DLC_50" (for /r "%dlc%\DLC_50" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd51
rd "%dlc%\DLC_50"
goto :lcd1 

:lcd51
IF EXIST "%dlc%\DLC_51" (for /r "%dlc%\DLC_51" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd52
rd "%dlc%\DLC_51"
goto :lcd1 

:lcd52
IF EXIST "%dlc%\DLC_52" (for /r "%dlc%\DLC_52" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd53
rd "%dlc%\DLC_52"
goto :lcd1 

:lcd53
IF EXIST "%dlc%\DLC_53" (for /r "%dlc%\DLC_53" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd54
rd "%dlc%\DLC_53"
goto :lcd1 

:lcd54
IF EXIST "%dlc%\DLC_54" (for /r "%dlc%\DLC_54" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd55
rd "%dlc%\DLC_54"
goto :lcd1 

:lcd55
IF EXIST "%dlc%\DLC_55" (for /r "%dlc%\DLC_55" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd56
rd "%dlc%\DLC_55"
goto :lcd1 

:lcd56
IF EXIST "%dlc%\DLC_56" (for /r "%dlc%\DLC_56" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd57
rd "%dlc%\DLC_56"
goto :lcd1 

:lcd57
IF EXIST "%dlc%\DLC_57" (for /r "%dlc%\DLC_57" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd58
rd "%dlc%\DLC_57"
goto :lcd1 

:lcd58
IF EXIST "%dlc%\DLC_58" (for /r "%dlc%\DLC_58" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd59
rd "%dlc%\DLC_58"
goto :lcd1

:lcd59
IF EXIST "%dlc%\DLC_59" (for /r "%dlc%\DLC_59" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd60
rd "%dlc%\DLC_59"
goto :lcd1 

:lcd60
IF EXIST "%dlc%\DLC_60" (for /r "%dlc%\DLC_60" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd61
rd "%dlc%\DLC_60"
goto :lcd1 

:lcd61
IF EXIST "%dlc%\DLC_61" (for /r "%dlc%\DLC_61" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd62
rd "%dlc%\DLC_61"
goto :lcd1 

:lcd62
IF EXIST "%dlc%\DLC_62" (for /r "%dlc%\DLC_62" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd63
rd "%dlc%\DLC_62"
goto :lcd1 

:lcd63
IF EXIST "%dlc%\DLC_63" (for /r "%dlc%\DLC_63" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd64
rd "%dlc%\DLC_63"
goto :lcd1 

:lcd64
IF EXIST "%dlc%\DLC_64" (for /r "%dlc%\DLC_64" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd65
rd "%dlc%\DLC_64"
goto :lcd1 

:lcd65
IF EXIST "%dlc%\DLC_65" (for /r "%dlc%\DLC_65" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd66
rd "%dlc%\DLC_65"
goto :lcd1 

:lcd66
IF EXIST "%dlc%\DLC_66" (for /r "%dlc%\DLC_66" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd67
rd "%dlc%\DLC_66"
goto :lcd1 

:lcd67
IF EXIST "%dlc%\DLC_67" (for /r "%dlc%\DLC_67" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd68
rd "%dlc%\DLC_67"
goto :lcd1 

:lcd68
IF EXIST "%dlc%\DLC_68" (for /r "%dlc%\DLC_68" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd69
rd "%dlc%\DLC_68"
goto :lcd1

:lcd69
IF EXIST "%dlc%\DLC_69" (for /r "%dlc%\DLC_69" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd70
rd "%dlc%\DLC_69"
goto :lcd1 

:lcd70
IF EXIST "%dlc%\DLC_70" (for /r "%dlc%\DLC_70" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd71
rd "%dlc%\DLC_70"
goto :lcd1 

:lcd71
IF EXIST "%dlc%\DLC_71" (for /r "%dlc%\DLC_71" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd72
rd "%dlc%\DLC_71"
goto :lcd1 

:lcd72
IF EXIST "%dlc%\DLC_72" (for /r "%dlc%\DLC_72" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd73
rd "%dlc%\DLC_72"
goto :lcd1 

:lcd73
IF EXIST "%dlc%\DLC_73" (for /r "%dlc%\DLC_73" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd74
rd "%dlc%\DLC_73"
goto :lcd1 

:lcd74
IF EXIST "%dlc%\DLC_74" (for /r "%dlc%\DLC_74" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd75
rd "%dlc%\DLC_74"
goto :lcd1 

:lcd75
IF EXIST "%dlc%\DLC_75" (for /r "%dlc%\DLC_75" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd76
rd "%dlc%\DLC_75"
goto :lcd1 

:lcd76
IF EXIST "%dlc%\DLC_76" (for /r "%dlc%\DLC_76" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd77
rd "%dlc%\DLC_76"
goto :lcd1 

:lcd77
IF EXIST "%dlc%\DLC_77" (for /r "%dlc%\DLC_77" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd78
rd "%dlc%\DLC_77"
goto :lcd1 

:lcd78
IF EXIST "%dlc%\DLC_78" (for /r "%dlc%\DLC_78" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd79
rd "%dlc%\DLC_78"
goto :lcd1

:lcd79
IF EXIST "%dlc%\DLC_79" (for /r "%dlc%\DLC_79" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd80
rd "%dlc%\DLC_79"
goto :lcd1 

:lcd80
IF EXIST "%dlc%\DLC_80" (for /r "%dlc%\DLC_80" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd81
rd "%dlc%\DLC_80"
goto :lcd1 

:lcd81
IF EXIST "%dlc%\DLC_81" (for /r "%dlc%\DLC_81" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd82
rd "%dlc%\DLC_81"
goto :lcd1 

:lcd82
IF EXIST "%dlc%\DLC_82" (for /r "%dlc%\DLC_82" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd83
rd "%dlc%\DLC_82"
goto :lcd1 

:lcd83
IF EXIST "%dlc%\DLC_83" (for /r "%dlc%\DLC_83" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd84
rd "%dlc%\DLC_83"
goto :lcd1 

:lcd84
IF EXIST "%dlc%\DLC_84" (for /r "%dlc%\DLC_84" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd85
rd "%dlc%\DLC_84"
goto :lcd1 

:lcd85
IF EXIST "%dlc%\DLC_85" (for /r "%dlc%\DLC_85" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd86
rd "%dlc%\DLC_85"
goto :lcd1 

:lcd86
IF EXIST "%dlc%\DLC_86" (for /r "%dlc%\DLC_86" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd87
rd "%dlc%\DLC_86"
goto :lcd1 

:lcd87
IF EXIST "%dlc%\DLC_87" (for /r "%dlc%\DLC_87" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd88
rd "%dlc%\DLC_87"
goto :lcd1 

:lcd88
IF EXIST "%dlc%\DLC_88" (for /r "%dlc%\DLC_88" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd89
rd "%dlc%\DLC_88"
goto :lcd1

:lcd89
IF EXIST "%dlc%\DLC_89" (for /r "%dlc%\DLC_89" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd90
rd "%dlc%\DLC_89"
goto :lcd1 

:lcd90
IF EXIST "%dlc%\DLC_90" (for /r "%dlc%\DLC_90" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd91
rd "%dlc%\DLC_90"
goto :lcd1 

:lcd91
IF EXIST "%dlc%\DLC_91" (for /r "%dlc%\DLC_91" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd92
rd "%dlc%\DLC_91"
goto :lcd1 

:lcd92
IF EXIST "%dlc%\DLC_92" (for /r "%dlc%\DLC_92" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd93
rd "%dlc%\DLC_92"
goto :lcd1 

:lcd93
IF EXIST "%dlc%\DLC_93" (for /r "%dlc%\DLC_93" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd94
rd "%dlc%\DLC_93"
goto :lcd1 

:lcd94
IF EXIST "%dlc%\DLC_94" (for /r "%dlc%\DLC_94" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd95
rd "%dlc%\DLC_94"
goto :lcd1 

:lcd95
IF EXIST "%dlc%\DLC_95" (for /r "%dlc%\DLC_95" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd96
rd "%dlc%\DLC_95"
goto :lcd1 

:lcd96
IF EXIST "%dlc%\DLC_96" (for /r "%dlc%\DLC_96" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd97
rd "%dlc%\DLC_96"
goto :lcd1 

:lcd97
IF EXIST "%dlc%\DLC_97" (for /r "%dlc%\DLC_97" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd98
rd "%dlc%\DLC_97"
goto :lcd1 

:lcd98
IF EXIST "%dlc%\DLC_98" (for /r "%dlc%\DLC_98" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd99
rd "%dlc%\DLC_98"
goto :lcd1

:lcd99
IF EXIST "%dlc%\DLC_99" (for /r "%dlc%\DLC_99" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :lcd100
rd "%dlc%\DLC_99"
goto :lcd1 

:lcd100
IF EXIST "%dlc%\DLC_100" (for /r "%dlc%\DLC_100" %%d in (*.*) do move "%%d" "%dlc%\DLC_1") else goto :finish
rd "%dlc%\DLC_100"
goto :lcd1 


goto finish

:finish
for /r "%cd%\tools\Finished" %%d in (*.*) do move "%%d" "%dlc%"
for /f %%x In ("%cd%") Do "%cd%\tools\pkgrename.exe" --yes-to-all --pattern "(%%title_id%%) - %%dlc%% - %%title%%" 
for /d %%p IN ("%dlc%\*") DO rmdir "%%p" /s /q
del /q "%work%\*.*"
FOR /D %%p IN ("%work%\*") DO rmdir "%%p" /s /q
EXIT


:Update - Change Region

:: Stop if no game pkg found.
if not exist "%game%\*.pkg" echo - Folder GAME does not contains game pkg file.
if not exist "%update%\*.pkg" echo - Folder UPDATE does not contains update pkg file.
if not exist "%game%\*.pkg" pause
if not exist "%game%\*.pkg" exit
if not exist "%update%\*.pkg" pause
if not exist "%update%\*.pkg" exit


IF EXIST "%cd%/tools/PS4-Fake-PKG-Tools-3.87-main" goto Merge2 (
) ELSE (
"%cd%/tools/wget.exe" "https://github.com/CyB1K/PS4-Fake-PKG-Tools-3.87/archive/refs/heads/main.zip"
"%cd%/tools/7za.exe" x "%cd%/main.zip" -o"%cd%/tools"
del main.zip
)

:Merge2
for /f "usebackq tokens=* delims=" %%P in (`dir /b "%game%" `) do set "G=%%P"
tools\sfk partcopy "%game%\%G%" 0x047 0x9 tools\id.txt -yes
for /f "tokens=* delims=," %%t in (tools\id.txt) do set FOLDER=%%t-patch
del tools\id.txt

for /f "usebackq tokens=* delims=" %%L in (`dir /b "%game%" `) do set "Gm=%%L"
"%pubCmd%" img_extract --passcode "00000000000000000000000000000000" "%game%\%Gm%":"Sc0/npbind.dat" "%work%"
"%pubCmd%" img_extract --passcode "00000000000000000000000000000000" "%game%\%Gm%":"Sc0/nptitle.dat" "%work%"
if not exist "%work%\np" mkdir "%work%\np"
xcopy "%work%\npbind.dat" "%work%\np\"
move "%work%\nptitle.dat" "%work%\np\"
"%pubCmd%" img_extract --passcode "00000000000000000000000000000000" "%game%\%Gm%":"Sc0/trophy/trophy00.trp" "%work%"


tools\sfk partcopy "%work%\npbind.dat" -fromto 0x84 0x8D "%work%\npbindgame.txt" -yes
del /q "%work%\npbind.dat"

echo --------------------------------------------------------------------------------------
echo - Unpacking Update
echo - Please wait...
echo --------------------------------------------------------------------------------------

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%update%" `) do set "Up=%%P"
"%pubCmd%" img_extract --passcode 00000000000000000000000000000000  "%update%\%Up%" "%updateunpack%"

"%pubCmd%" img_extract --passcode "00000000000000000000000000000000" "%update%\%Up%":"Sc0/npbind.dat" "%work%"
tools\sfk partcopy "%work%\npbind.dat" -fromto 0x84 0x8D "%work%\npbindupdate.txt" -yes
del /q "%work%\npbind.dat"

xcopy /e "%updateunpack%\Sc0\*" "%updateunpack%\Image0\sce_sys\"
rmdir /s /q "%updateunpack%\Sc0\"
fsutil file createnew "%updateunpack%\Image0\sce_sys\region.changed" 0

for /f "usebackq tokens=* delims=" %%G in (`dir /b "%game%" `) do set "Ga=%%G"
"%sfo%" -q content_id "%game%\%Ga%" >"%work%\123.txt"
set /p VAR=<"%work%\123.txt"

"%sfo%" -e content_id %VAR% "%updateunpack%\Image0\sce_sys\param.sfo"

"%sfo%" -q TITLE_ID "%update%\%Up%" >"%work%\789.txt"
set /p VAR3=<"%work%\789.txt"

"%sfo%" -q TITLE_ID "%game%\%Ga%" >"%work%\987.txt"
set /p VAR4=<"%work%\987.txt"

"%sfo%" -e title_id %VAR4% "%updateunpack%\Image0\sce_sys\param.sfo"

"%cd%\tools\gsar.exe" -o -s%VAR3% -r%VAR4% "%updateunpack%\Image0\sce_sys\nptitle.dat"

set /p VAR5=<"%work%\npbindgame.txt"
set /p VAR6=<"%work%\npbindupdate.txt"

if %VAR5% == %VAR6% goto NPWR1 (
) else ( goto NPWR2
)


:NPWR2
move /Y "%work%\np\npbind.dat" "%updateunpack%\Image0\sce_sys\"
move /Y "%work%\np\nptitle.dat" "%updateunpack%\Image0\sce_sys\"
move /Y "%work%\trophy00.trp" "%updateunpack%\Image0\sce_sys\trophy\"

:NPWR1
echo --------------------------------------------------------------------------------------
echo - Changing Region
echo - Please wait...
echo --------------------------------------------------------------------------------------

move "%updateunpack%\Image0" "%work%"

rmdir /s /q "%updateunpack%"

Ren "%work%\Image0"  %FOLDER%

"%gengp4p%" "%work%\%FOLDER%"

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%game%" `) do set "Ga=%%P"

"%pubCmd%" gp4_proj_update --app_path "%game%\%ga%" "%work%\%FOLDER%.gp4"


echo --------------------------------------------------------------------------------------
echo - Building Update
echo - Please wait...
echo --------------------------------------------------------------------------------------

"%pubCmd%" img_create --oformat pkg  "%work%\%FOLDER%.gp4" "%cd%"

FOR /D %%p IN ("%work%\*") DO rmdir "%%p" /s /q
del /q "%work%\*.gp4"
del /q *compare_delta.log
EXIT




:Save sharing between US/EU Games

for /f "usebackq tokens=* delims=" %%x in (`dir /b "%update%"`) do set "Up=%%x"
for /f "usebackq tokens=* delims=" %%y in (`dir /b "%game%"`) do set "Gm=%%y"

if exist "%update%\*.pkg" (
"%pubCmd%" img_extract --passcode 00000000000000000000000000000000 "%update%\%Up%":"Sc0/param.sfo" "%work%"
"%sfo%" -q INSTALL_DIR_SAVEDATA "%work%\param.sfo" >"%work%\save.txt"
goto param1
) else (
"%pubCmd%" img_extract --passcode 00000000000000000000000000000000 "%game%\%Gm%":"Sc0/param.sfo" "%work%"
"%sfo%" -q INSTALL_DIR_SAVEDATA "%work%\param.sfo" >"%work%\save.txt"
goto param2
)

:param1
FOR %%I in ("%work%\save.txt") do set save=%%~zI

if %save% == 0 goto save1 (
) else (
goto save2
)

:save1
set /p CUSA="->CUSA"
"%sfo%" -a str INSTALL_DIR_SAVEDATA CUSA%CUSA% "%work%\param.sfo"
goto unupdate

:save2
set /p CUSA="->CUSA"
"%sfo%" -e INSTALL_DIR_SAVEDATA CUSA%CUSA% "%work%\param.sfo"

:unupdate
echo --------------------------------------------------------------------------------------
echo - Unpacking Update
echo - Please wait...
echo --------------------------------------------------------------------------------------

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%update%" `) do set "Up=%%P"
"%pubCmd%" img_extract --passcode 00000000000000000000000000000000  "%update%\%Up%" "%updateunpack%"

xcopy /e "%updateunpack%\Sc0\*" "%updateunpack%\Image0\sce_sys\"
rmdir /s /q "%updateunpack%\Sc0\"

move /y "%work%\param.sfo" "%updateunpack%\Image0\sce_sys\"


for /f "usebackq tokens=* delims=" %%P in (`dir /b "%update%" `) do set "U=%%P"
tools\sfk partcopy "%update%\%U%" 0x047 0x9 tools\id.txt -yes
for /f "tokens=* delims=," %%t in (tools\id.txt) do set FOLDER=%%t-patch
del tools\id.txt


move "%updateunpack%\Image0" "%work%"
Ren "%work%\Image0"  %FOLDER%

"%gengp4p%" "%work%\%FOLDER%"

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%game%" `) do set "Ga=%%P"

"%pubCmd%" gp4_proj_update --app_path "%game%\%ga%" "%work%\%FOLDER%.gp4"

echo --------------------------------------------------------------------------------------
echo - Building Update
echo - Please wait...
echo --------------------------------------------------------------------------------------

"%pubCmd%" img_create --oformat pkg  "%work%\%FOLDER%.gp4" "%cd%"

goto finish

:param2
FOR %%J in ("%work%\save.txt") do set save=%%~zJ

if %save% == 0 goto save1 (
) else (
goto save2
)

:save1
set /p CUSA="->CUSA"
"%sfo%" -a str INSTALL_DIR_SAVEDATA CUSA%CUSA% "%work%\param.sfo"
goto ungame

:save2
set /p CUSA="->CUSA"
"%sfo%" -e INSTALL_DIR_SAVEDATA CUSA%CUSA% "%work%\param.sfo"

:ungame
echo --------------------------------------------------------------------------------------
echo - Unpacking Game
echo - Please wait...
echo --------------------------------------------------------------------------------------

for /f "usebackq tokens=* delims=" %%P in (`dir /b "%game%" `) do set "Ga=%%P"
"%pubCmd%" img_extract --passcode 00000000000000000000000000000000  "%game%\%ga%" "%gameunpack%"

xcopy /e "%gameunpack%\Sc0\*" "%gameunpack%\Image0\sce_sys\"
rmdir /s /q "%gameunpack%\Sc0\"

move /y "%work%\param.sfo" "%gameunpack%\Image0\sce_sys\"

for /f "usebackq tokens=* delims=" %%R in (`dir /b "%game%" `) do set "G=%%R"
tools\sfk partcopy "%game%\%G%" 0x047 0x9 tools\id.txt -yes
for /f "tokens=* delims=," %%t in (tools\id.txt) do set FOLDER=%%t-app
del tools\id.txt

move "%gameunpack%\Image0" "%work%"
Ren "%work%\Image0"  %FOLDER%

"%gengp4p%" "%work%\%FOLDER%"

echo --------------------------------------------------------------------------------------
echo - Building Game
echo - Please wait...
echo --------------------------------------------------------------------------------------

"%pubCmd%" img_create --oformat pkg  "%work%\%FOLDER%.gp4" "%cd%"

:finish
del /q "%work%\*.*"
if exist *compare_delta.log del /q *compare_delta.log
FOR /D %%p IN ("%work%\*") DO rmdir "%%p" /s /q
EXIT
