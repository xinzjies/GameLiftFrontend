@echo off

SET SCRIPT_FULL_PATH=%~dp0
:: Read GameLiftConfig.ini and import variables
call %SCRIPT_FULL_PATH%GameLiftConfigReader.bat

echo.
echo Init GameLift resources
echo - AWS Region: %AWS_REGION%
echo - Fleet Name: %FLEET_NAME%
echo - Fleet Id: %FLEET_ID%
echo - Custom Location: %LOCATION_NAME%
echo - Custom Location Arn: %LOCATION_ARN%
echo - Compute Name: %COMPUTE_NAME%
echo - Public IP: %PUBLIC_IP%
echo - Service SDK Endpoint: %WEBSOCKET_URL%
echo - GameServer Port: %GAMESERVER_PORT%
echo - Auth Token: %AUTH_TOKEN%

:: Create custom location
echo.
echo Create custom location
if "%LOCATION_ARN%"=="" (
	aws gamelift create-location --location-name %LOCATION_NAME% --region %AWS_REGION%
) else (
	echo Location %LOCATION_NAME% already exists
)

:: Create Anywhere fleet
echo.
echo Create Anywhere fleet
if "%FLEET_ID%"=="None" (
    FOR /F "tokens=* USEBACKQ" %%F IN (`call aws gamelift create-fleet --name %FLEET_NAME% --compute-type ANYWHERE --locations "Location=%LOCATION_NAME%" --region %AWS_REGION% --query "FleetAttributes.FleetId" --output text`) DO (
    	SET FLEET_ID=%%F
	)
) else (
    echo Fleet %FLEET_NAME% already exists
)

:: Register your compute
echo.
echo Register your compute
aws gamelift register-compute --compute-name %COMPUTE_NAME% --fleet-id %FLEET_ID% --ip-address %PUBLIC_IP% --location %LOCATION_NAME% --region %AWS_REGION%
