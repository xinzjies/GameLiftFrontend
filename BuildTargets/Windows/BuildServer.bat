@echo off

SET SCRIPT_FULL_PATH=%~dp0
SET PROJECT_NAME=DayOne
SET UPROJECT_FILE_PATH=%SCRIPT_FULL_PATH%..\..\%PROJECT_NAME%.uproject
SET TARGET_PLATFORM=Win64
SET TARGET_CONFIG=Development

:: Build DedicatedServer
call RunUAT.bat BuildCookRun -project=%UPROJECT_FILE_PATH% -archivedirectory=%SCRIPT_FULL_PATH% -serverplatform=%TARGET_PLATFORM% -serverconfig=%TARGET_CONFIG% -nop4 -build -cook -compressed -stage -noclient -server -pak -archive -utf8output

:: Copy the necessary dependency files
echo Copy GameLift's prerequisite files to WindowsServer folder...
copy /y %SCRIPT_FULL_PATH%Prerequisites\install.bat %SCRIPT_FULL_PATH%WindowsServer\install.bat
if not exist %SCRIPT_FULL_PATH%WindowsServer\install.bat (
    echo "install.bat does not exist in WindowsServer folder."
    timeout 10
    exit /b -1
)
copy /y %SCRIPT_FULL_PATH%Prerequisites\VC_Redist_2022_x64.exe %SCRIPT_FULL_PATH%WindowsServer\VC_Redist_2022_x64.exe
if not exist %SCRIPT_FULL_PATH%WindowsServer\VC_Redist_2022_x64.exe (
    echo "VC_Redist_2022_x64.exe does not exist in WindowsServer folder."
    timeout 10
    exit /b -1
)
:: GameLift Server SDK 5.0.0 need libcrypto and libssl. You don't need there files if you are using 4.x SDK.
copy /y %SCRIPT_FULL_PATH%Prerequisites\libcrypto-3-x64.dll %SCRIPT_FULL_PATH%WindowsServer\DayOne\Binaries\Win64\libcrypto-3-x64.dll
if not exist %SCRIPT_FULL_PATH%WindowsServer\DayOne\Binaries\Win64\libcrypto-3-x64.dll (
    echo "libcrypto-3-x64.dll does not exist in WindowsServer\DayOne\Binaries\Win64 folder."
    timeout 10
    exit /b -1
)
copy /y %SCRIPT_FULL_PATH%Prerequisites\libssl-3-x64.dll %SCRIPT_FULL_PATH%WindowsServer\DayOne\Binaries\Win64\libssl-3-x64.dll
if not exist %SCRIPT_FULL_PATH%WindowsServer\DayOne\Binaries\Win64\libssl-3-x64.dll (
    echo "libssl-3-x64.dll does not exist in WindowsServer\DayOne\Binaries\Win64 folder."
    timeout 10
    exit /b -1
)