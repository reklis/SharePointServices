//
//  SPServiceSettings.h
//  SharePointClient
//
//  Created by Steven Fusco on 2/28/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SPCredentials.h"

@interface SPServiceSettings : NSObject
{
}

@property (readwrite,nonatomic,retain) NSString* sharedRootUrl;
@property (readwrite,nonatomic,retain) SPCredentials* sharedCredentials;
@property (readwrite,nonatomic,assign) BOOL synchronousNetworkMode;
@property (readwrite,nonatomic,assign) BOOL debugMode;

+ (id) settings;

@end
