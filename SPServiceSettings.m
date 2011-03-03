//
//  SPServiceSettings.m
//  SharePointClient
//
//  Created by Steven Fusco on 2/28/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPServiceSettings.h"

@implementation SPServiceSettings

@synthesize sharedRootUrl;
@synthesize sharedCredentials;
@synthesize synchronousNetworkMode;
@synthesize debugMode;

+ (id) settings
{
    return [[[SPServiceSettings alloc] init] autorelease];
}

@end
