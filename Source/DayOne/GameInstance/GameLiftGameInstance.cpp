// Fill out your copyright notice in the Description page of Project Settings.

#include "GameLiftGameInstance.h"
#include "DayOne/DayOne.h"
#include "GameLiftServerSDK.h"

void UGameLiftGameInstance::OnStart()
{
	Super::OnStart();

#if WITH_GAMELIFT
	// Getting the module first.
	FGameLiftServerSDKModule* GameLiftSdkModule = &FModuleManager::LoadModuleChecked<FGameLiftServerSDKModule>(FName("GameLiftServerSDK"));
	// Define the server parameters
	FServerParameters ServerParameters;
	// AuthToken returned from the "aws gamelift get-compute-auth-token" API. Note this will expire and require a new call to the API after 15 minutes.
	FParse::Value(FCommandLine::Get(), TEXT("-authtoken="), ServerParameters.m_authToken);
	// The Host/Compute ID of the GameLift Anywhere instance.
	FParse::Value(FCommandLine::Get(), TEXT("-hostid="), ServerParameters.m_hostId);
	// The EC2 or Anywhere Fleet ID.
	FParse::Value(FCommandLine::Get(), TEXT("-fleetid="), ServerParameters.m_fleetId);
	// The WebSocket URL (GameLiftServiceSdkEndpoint).
	FParse::Value(FCommandLine::Get(), TEXT("-websocketurl="), ServerParameters.m_webSocketUrl);
	// The PID of the running process
	ServerParameters.m_processId = FString::Printf(TEXT("%d"), GetCurrentProcessId());

	UE_LOG(LogDayOne, Warning, TEXT("GameLift ServerParameters: -authtoken=%s, -hostid=%s, -fleetid=%s, -websocketurl=%s"),
	*ServerParameters.m_authToken, *ServerParameters.m_hostId, *ServerParameters.m_fleetId, *ServerParameters.m_webSocketUrl);
	
	// InitSDK will establish a local connection with GameLift's agent to enable further communication.
	auto InitSDKOutcome = GameLiftSdkModule->InitSDK(ServerParameters);
	if (!InitSDKOutcome.IsSuccess())
	{
		UE_LOG(LogDayOne, Warning, TEXT("Failed to init GameLiftServerSDK: %s"), *InitSDKOutcome.GetError().m_errorMessage);
		return;
	}
	
	// Register callbacks to GameLift service
	// OnHealthCheck callback
	auto OnHealthCheck = []()
	{
		UE_LOG(LogDayOne, Warning, TEXT("OnHealthCheck"));
		return true;
	};
	GLProcessParameters.OnHealthCheck.BindLambda(OnHealthCheck);
	// OnStartGameSession callback
	GLProcessParameters.OnStartGameSession.BindUObject(this, &ThisClass::OnStartGameSession);
	// OnProcessTerminate callback
	GLProcessParameters.OnTerminate.BindUObject(this, &ThisClass::OnProcessTerminate);
	
	// Extract port from cmdline arguments.
	// DayOneServer.exe token -port=7777
	int Port = FURL::UrlConfig.DefaultPort;
	FParse::Value(FCommandLine::Get(), TEXT("-port="), Port);
	GLProcessParameters.port = Port;

	// Setup logfile path.
	// TODO: We need wildcard log file names!
	// UnrealEngine renames the log files by current date when the dedicated server process exits,
	// so the log file name are dynamically changing,
	// but the Server SDK’s LogParameters seem to only allow static file names to be specified?
	TArray<FString> LogFiles;
	LogFiles.Add(TEXT("DayOneGameLift.log"));
	GLProcessParameters.logParameters = LogFiles;

	UE_LOG(LogDayOne, Warning, TEXT("GameLift ProcessParameters: -port=%d, logParameters[0]=%s"),
	GLProcessParameters.port, *GLProcessParameters.logParameters[0]);
	
	// Notify GameLift service the game server is ready.
	auto ProcessReadyOutcome = GameLiftSdkModule->ProcessReady(GLProcessParameters);
	if (!ProcessReadyOutcome.IsSuccess())
	{
		UE_LOG(LogDayOne, Warning, TEXT("Failed to call GameLift ProcessReady: %s"), *ProcessReadyOutcome.GetError().m_errorMessage);
		return;
	}
#endif
}

void UGameLiftGameInstance::OnStartGameSession(Aws::GameLift::Server::Model::GameSession GameSession)
{
#if WITH_GAMELIFT
	UE_LOG(LogDayOne, Warning, TEXT("Got OnStartGameSession call from GameLift service"));

	// https://docs.aws.amazon.com/gamelift/latest/flexmatchguide/match-server.html#match-server-data
	FString MatchmakerData = GameSession.GetMatchmakerData();
	TSharedPtr<FJsonObject> JsonObject;
	TSharedRef<TJsonReader<>> JsonReader = TJsonReaderFactory<>::Create(MatchmakerData);
	if (FJsonSerializer::Deserialize(JsonReader, JsonObject))
	{
		TArray<TSharedPtr<FJsonValue>> Teams = JsonObject->GetArrayField("teams");
		for (TSharedPtr<FJsonValue> Team : Teams)
		{
			TSharedPtr<FJsonObject> TeamObject = Team->AsObject();
			FString TeamName = TeamObject->GetStringField("name");

			TArray<TSharedPtr<FJsonValue>> Players = TeamObject->GetArrayField("players");
			for (TSharedPtr<FJsonValue> Player : Players)
			{
				TSharedPtr<FJsonObject> PlayerObject = Player->AsObject();
				FString PlayerId = PlayerObject->GetStringField("playerId");

				FGameLiftPlayer GameSessionPlayer;
				GameSessionPlayer.TeamName = TeamName;
				GameSessionPlayer.PlayerId = PlayerId;
				StartGameSessionState.ReservedPlayers.Add(PlayerId, GameSessionPlayer);
			}
		}

		auto ActiveGameSessionOutcome = Aws::GameLift::Server::ActivateGameSession();
		StartGameSessionState.bIsSuccess = ActiveGameSessionOutcome.IsSuccess();
		if (StartGameSessionState.bIsSuccess)
		{
			StartGameSessionState.OnStartGameSession.ExecuteIfBound(StartGameSessionState);
		}
		else
		{
			StartGameSessionState.ReservedPlayers.Empty();
			UE_LOG(LogDayOne, Warning, TEXT("Failed to ActivateGameSession: %s"), *FString(ActiveGameSessionOutcome.GetError().GetErrorMessage()));
		}
	}
	else
	{
		UE_LOG(LogDayOne, Warning, TEXT("Failed to deserialize GameSession's MatchmakerData: %s"), *MatchmakerData);
	}
#endif
}

void UGameLiftGameInstance::OnProcessTerminate()
{
#if WITH_GAMELIFT
	UE_LOG(LogDayOne, Warning, TEXT("Got OnProcessTerminate call from GameLift service"));
	
	ProcessTerminateState.bIsTerminating = true;

	auto TerminationTimeOutcome = Aws::GameLift::Server::GetTerminationTime();
	if (TerminationTimeOutcome.IsSuccess())
	{
		ProcessTerminateState.TerminationTime = TerminationTimeOutcome.GetResult();
	}

	ProcessTerminateState.OnProcessTerminate.ExecuteIfBound(ProcessTerminateState);
#endif
}
