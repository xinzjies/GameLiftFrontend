@echo off

SET SCRIPT_FULL_PATH=%~dp0
SET UPROJECT_FILE_PATH=%SCRIPT_FULL_PATH%..\..\DayOne.uproject
SET TARGET_PLATFORM=Win64
SET TARGET_CONFIG=Development

:: Build Client
call RunUAT.bat BuildCookRun -project=%UPROJECT_FILE_PATH% -archivedirectory=%SCRIPT_FULL_PATH% -platform=%TARGET_PLATFORM% -clientconfig=%TARGET_CONFIG% -nop4 -build -cook -compressed -stage -pak -archive -utf8output
