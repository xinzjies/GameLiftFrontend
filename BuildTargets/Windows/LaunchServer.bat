@echo off

SET SCRIPT_FULL_PATH=%~dp0
:: Read GameLiftConfig.ini and import variables
call %SCRIPT_FULL_PATH%GameLiftConfigReader.bat

if not "%FLEET_ID%"=="None" (
    start %SCRIPT_FULL_PATH%WindowsServer\DayOneServer.exe -authtoken=%AUTH_TOKEN% -hostid=%COMPUTE_NAME% -fleetid=%FLEET_ID% -websocketurl=%WEBSOCKET_URL% -log -port=%GAMESERVER_PORT%
) else (
    echo Fleet %FLEET_NAME% does not exists
)
