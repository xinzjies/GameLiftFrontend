@echo off

:: Read GameLiftConfig.ini and fill variables

SET SCRIPT_FULL_PATH=%~dp0

SET AWS_REGION=
FOR /F "tokens=* USEBACKQ" %%F IN (`call %SCRIPT_FULL_PATH%INIReader.bat /s Global /i Region %SCRIPT_FULL_PATH%GameLiftConfig.ini`) DO (
    SET AWS_REGION=%%F
)

SET FLEET_NAME=
FOR /F "tokens=* USEBACKQ" %%F IN (`call %SCRIPT_FULL_PATH%INIReader.bat /s GameLift /i FleetName %SCRIPT_FULL_PATH%GameLiftConfig.ini`) DO (
    SET FLEET_NAME=%%F
)

SET LOCATION_NAME=
FOR /F "tokens=* USEBACKQ" %%F IN (`call %SCRIPT_FULL_PATH%INIReader.bat /s GameLift/Anywhere /i LocationName %SCRIPT_FULL_PATH%GameLiftConfig.ini`) DO (
    SET LOCATION_NAME=%%F
)

SET COMPUTE_NAME=
FOR /F "tokens=* USEBACKQ" %%F IN (`call %SCRIPT_FULL_PATH%INIReader.bat /s GameLift/Anywhere /i ComputeName %SCRIPT_FULL_PATH%GameLiftConfig.ini`) DO (
    SET COMPUTE_NAME=%%F
)

SET GAMESERVER_PORT=
FOR /F "tokens=* USEBACKQ" %%F IN (`call %SCRIPT_FULL_PATH%INIReader.bat /s GameServer /i Port %SCRIPT_FULL_PATH%GameLiftConfig.ini`) DO (
    SET GAMESERVER_PORT=%%F
)

SET PUBLIC_IP=
FOR /F "tokens=* USEBACKQ" %%F IN (`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`) DO (
    SET PUBLIC_IP=%%F
)

SET FLEET_ID=
FOR /F "tokens=* USEBACKQ" %%F IN (`call aws gamelift describe-fleet-attributes --region %AWS_REGION% --query "reverse(sort_by(FleetAttributes[?Name==`%FLEET_NAME%`], &CreationTime))[0].FleetId" --output text`) DO (
    SET FLEET_ID=%%F
)

SET LOCATION_ARN=
FOR /F "tokens=* USEBACKQ" %%F IN (`call aws gamelift list-locations --region %AWS_REGION% --query "Locations[?LocationName==`%LOCATION_NAME%`].LocationArn" --output text `) DO (
    SET LOCATION_ARN=%%F
)

SET WEBSOCKET_URL=
if not "%FLEET_ID%"=="None" (
    FOR /F "tokens=* USEBACKQ" %%F IN (`call aws gamelift describe-compute --fleet-id %FLEET_ID% --compute-name %COMPUTE_NAME% --region %AWS_REGION% --query "Compute.GameLiftServiceSdkEndpoint" --output text`) DO (
        SET WEBSOCKET_URL=%%F
    )
)
