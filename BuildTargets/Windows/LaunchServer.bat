@echo off

SET SCRIPT_FULL_PATH=%~dp0
:: Read GameLiftConfig.ini and import variables
call %SCRIPT_FULL_PATH%GameLiftConfigReader.bat

if not "%FLEET_ID%"=="None" (
    SET AUTH_TOKEN=
    FOR /F "tokens=* USEBACKQ" %%F IN (`aws gamelift get-compute-auth-token --fleet-id %FLEET_ID% --compute-name %COMPUTE_NAME% --region %AWS_REGION% --query "AuthToken" --output text`) DO (
        SET AUTH_TOKEN=%%F
    )

    start %SCRIPT_FULL_PATH%WindowsServer\DayOneServer.exe -authtoken=%AUTH_TOKEN% -hostid=%COMPUTE_NAME% -fleetid=%FLEET_ID% -websocketurl=%WEBSOCKET_URL% -log -port=%GAMESERVER_PORT%

) else (
    echo Fleet %FLEET_NAME% does not exists
)
