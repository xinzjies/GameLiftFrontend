// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Engine/GameInstance.h"
#include "GameLiftServerSDK.h"
#include "GameLiftGameInstance.generated.h"

DECLARE_DELEGATE_OneParam(FOnStartGameSessionDelegate, const struct FStartGameSessionState& /*StartGameSessionState*/);
DECLARE_DELEGATE_OneParam(FOnProcessTerminateDelegate, const struct FProcessTerminateState& /*ProcessTerminateState*/);

USTRUCT()
struct FGameLiftPlayer
{
	GENERATED_BODY()

	FString PlayerId;
	FString PlayerSessionId;
	FString TeamName;
};

USTRUCT()
struct FStartGameSessionState
{
	GENERATED_BODY();
	
	bool bIsSuccess;
	TMap<FString, FGameLiftPlayer> ReservedPlayers;
	FOnStartGameSessionDelegate OnStartGameSession;

	FStartGameSessionState()
	{
		bIsSuccess = false;
	}
};

USTRUCT()
struct FProcessTerminateState
{
	GENERATED_BODY();
	
	bool bIsTerminating;
	long TerminationTime;
	FOnProcessTerminateDelegate OnProcessTerminate;

	FProcessTerminateState()
	{
		bIsTerminating = false;
		TerminationTime = 0L;
	}
};

/**
 * 
 */
UCLASS()
class DAYONE_API UGameLiftGameInstance : public UGameInstance
{
	GENERATED_BODY()

public:
	virtual void OnStart() override;
	
	FStartGameSessionState StartGameSessionState;
	FProcessTerminateState ProcessTerminateState;

private:
	// GameLift Server SDK callback functions
	void OnStartGameSession(Aws::GameLift::Server::Model::GameSession GameSession);
	void OnProcessTerminate();

	// Hold GameLift Server SDK process parameters
	// Because GL SDK never keep this, it just reference this
	FProcessParameters GLProcessParameters;
};
