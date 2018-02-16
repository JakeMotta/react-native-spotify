//
//  RCTSpotifyError.m
//  RCTSpotify
//
//  Created by Luis Finke on 2/15/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RCTSpotifyError.h"
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>


@interface RCTSpotifyErrorCode()
-(id)initWithName:(NSString*)name message:(NSString*)message;
+(instancetype)codeWithName:(NSString*)name message:(NSString*)message;
@end


#define DEFINE_SPOTIFY_ERROR_CODE(errorName, messageStr) \
	static RCTSpotifyErrorCode* _RCTSpotifyErrorCode##errorName = nil; \
	RCTSpotifyErrorCode* RCTSpotifyErrorCode##errorName() { \
		if(_RCTSpotifyErrorCode##errorName == nil) { \
			_RCTSpotifyErrorCode##errorName = [RCTSpotifyErrorCode codeWithName:@#errorName message:messageStr]; } \
		return _RCTSpotifyErrorCode##errorName; } \

DEFINE_SPOTIFY_ERROR_CODE(AlreadyInitialized, @"Spotify has already been initialized")
DEFINE_SPOTIFY_ERROR_CODE(NotInitialized, @"Spotify has not been initialized")
DEFINE_SPOTIFY_ERROR_CODE(NotImplemented, @"This feature has not been implemented")
DEFINE_SPOTIFY_ERROR_CODE(NotLoggedIn, @"You are not logged in")
DEFINE_SPOTIFY_ERROR_CODE(MissingOption, @"Missing required option")
DEFINE_SPOTIFY_ERROR_CODE(NullParameter, @"Null parameter")
DEFINE_SPOTIFY_ERROR_CODE(ConflictingCallbacks, @"You cannot call this function while it is already executing")
DEFINE_SPOTIFY_ERROR_CODE(BadResponse, @"Invalid response format")
DEFINE_SPOTIFY_ERROR_CODE(PlayerNotReady, @"Player is not ready")
DEFINE_SPOTIFY_ERROR_CODE(SessionExpired, @"Your login session has expired")

#undef DEFINE_SPOTIFY_ERROR_CODE


@implementation RCTSpotifyErrorCode

@synthesize name = _name;
@synthesize message = _message;

-(id)initWithName:(NSString*)name message:(NSString*)message
{
	if(self = [super init])
	{
		_name = [NSString stringWithString:name];
		_message = [NSString stringWithString:message];
	}
	return self;
}

+(instancetype)codeWithName:(NSString*)name message:(NSString*)message
{
	return [[self alloc] initWithName:name message:message];
}

-(NSString*)code
{
	return [NSString stringWithFormat:@"RNS%@", _name];
}

@end



@interface RCTSpotifyError()
{
	NSError* _error;
}
+(NSString*)getSDKErrorCode:(SpErrorCode)enumVal;
@end

@implementation RCTSpotifyError

@synthesize code = _code;
@synthesize message = _message;

-(id)initWithCode:(NSString*)code message:(NSString*)message
{
	if(self = [super init])
	{
		_code = [NSString stringWithString:code];
		_message = [NSString stringWithString:message];
	}
	return self;
}

-(id)initWithCode:(NSString*)code error:(NSError*)error
{
	if(code == nil || code.length == 0)
	{
		return [self initWithError:error];
	}
	if(self = [super init])
	{
		if(error == nil)
		{
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Cannot provide a nil error to RCTSpotifyError" userInfo:nil];
		}
		_error = error;
		_code = [NSString stringWithString:code];
		_message = _error.localizedDescription;
	}
	return self;
}

-(id)initWithError:(NSError*)error
{
	if(self = [super init])
	{
		if(error == nil)
		{
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Cannot provide a nil error to RCTSpotifyError" userInfo:nil];
		}
		_error = error;
		if([_error.domain isEqualToString:@"com.spotify.ios-sdk.playback"])
		{
			_code = [self.class getSDKErrorCode:_error.code];
			_message = _error.localizedDescription;
		}
		else
		{
			_code = [NSString stringWithFormat:@"%@:%ld", _error.domain, _error.code];
			_message = _error.localizedDescription;
		}
	}
	return self;
}

+(instancetype)errorWithCode:(NSString*)code message:(NSString*)message
{
	return [[self alloc] initWithCode:code message:message];
}

+(instancetype)errorWithCode:(NSString *)code error:(NSError *)error
{
	return [[self alloc] initWithCode:code error:error];
}

+(instancetype)errorWithError:(NSError*)error
{
	return [[self alloc] initWithError:error];
}


#define SDK_ERROR_CASE(error) case error: return @#error;

+(NSString*)getSDKErrorCode:(SpErrorCode)enumVal
{
	switch(enumVal)
	{
		SDK_ERROR_CASE(SPErrorOk)
		SDK_ERROR_CASE(SPErrorFailed)
		SDK_ERROR_CASE(SPErrorInitFailed)
		SDK_ERROR_CASE(SPErrorWrongAPIVersion)
		SDK_ERROR_CASE(SPErrorNullArgument)
		SDK_ERROR_CASE(SPErrorInvalidArgument)
		SDK_ERROR_CASE(SPErrorUninitialized)
		SDK_ERROR_CASE(SPErrorAlreadyInitialized)
		SDK_ERROR_CASE(SPErrorLoginBadCredentials)
		SDK_ERROR_CASE(SPErrorNeedsPremium)
		SDK_ERROR_CASE(SPErrorTravelRestriction)
		SDK_ERROR_CASE(SPErrorApplicationBanned)
		SDK_ERROR_CASE(SPErrorGeneralLoginError)
		SDK_ERROR_CASE(SPErrorUnsupported)
		SDK_ERROR_CASE(SPErrorNotActiveDevice)
		SDK_ERROR_CASE(SPErrorAPIRateLimited)
		SDK_ERROR_CASE(SPErrorPlaybackErrorStart)
		SDK_ERROR_CASE(SPErrorGeneralPlaybackError)
		SDK_ERROR_CASE(SPErrorPlaybackRateLimited)
		SDK_ERROR_CASE(SPErrorPlaybackCappingLimitReached)
		SDK_ERROR_CASE(SPErrorAdIsPlaying)
		SDK_ERROR_CASE(SPErrorCorruptTrack)
		SDK_ERROR_CASE(SPErrorContextFailed)
		SDK_ERROR_CASE(SPErrorPrefetchItemUnavailable)
		SDK_ERROR_CASE(SPAlreadyPrefetching)
		SDK_ERROR_CASE(SPStorageWriteError)
		SDK_ERROR_CASE(SPPrefetchDownloadFailed)
	}
	return [NSString stringWithFormat:@"SPError:%ld", (NSInteger)enumVal];
}

@end