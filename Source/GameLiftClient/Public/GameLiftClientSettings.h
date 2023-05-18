// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Engine/DeveloperSettings.h"
#include "GameLiftClientSettings.generated.h"

/**
 * 
 */
UCLASS(config = Game, defaultconfig, meta = (DisplayName = "GameLiftClient"))
class GAMELIFTCLIENT_API UGameLiftClientSettings : public UDeveloperSettings
{
	GENERATED_BODY()

public:
	// Cognito's Hosted UI URL
	UPROPERTY(config, EditAnywhere, Category = "Login")
	FString LoginUrl;
	// Cognito's Login callback URL
	UPROPERTY(config, EditAnywhere, Category = "Login")
	FString LoginCallbackUrl;
	
	// GameLift backend endpoint URL
	UPROPERTY(config, EditAnywhere, Category = "Backend")
	FString InvokeUrl;
	// API Gateway's API Key (If backend is based on API Gateway)
	UPROPERTY(config, EditAnywhere, Category = "Backend")
	FString ApiKey;

	// AWS regions that GameLift Fleet deployed
	UPROPERTY(config, EditAnywhere, Category = "Fleet")
	TArray<FString> RegionCodes;
};
