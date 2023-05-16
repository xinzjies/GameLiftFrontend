@echo off

SET FLEET_ID="fleet-62ee99e4-f997-4964-b61b-0f95b27ca6d6"
SET COMPUTE_NAME="BJS-UE-DEV"
SET WEBSOCKET_URL="wss://ap-northeast-1.api.amazongamelift.com"
SET DS_PORT=1123

SET AUTH_TOKEN=""
FOR /F "tokens=* USEBACKQ" %%F IN (`aws gamelift get-compute-auth-token --fleet-id %FLEET_ID% --compute-name %COMPUTE_NAME% --output text --query "AuthToken"`) DO (
    SET AUTH_TOKEN=%%F
)

start WindowsServer\DayOneServer.exe -authtoken=%AUTH_TOKEN% -hostid=%COMPUTE_NAME% -fleetid=%FLEET_ID% -websocketurl=%WEBSOCKET_URL% -log -port=%DS_PORT%
