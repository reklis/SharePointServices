//
//  SPServiceFactory.m
//  SharePointClient
//
//  Created by Steven Fusco on 2/27/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPServiceFactory.h"

@implementation SPServiceFactory

static SPServiceSettings* _serviceSettings;

+ (SPServiceSettings*) serviceSettings
{
    @synchronized(_serviceSettings) {
        return _serviceSettings;
    }
}

+ (void) setServiceSettings:(SPServiceSettings*)s
{
    @synchronized(_serviceSettings) {
        if (_serviceSettings) {
            [_serviceSettings release];
        }
        _serviceSettings = [s retain];
    }
}

+ (SPSoapService*) makeService:(NSString*)resourcePath
{
    SPSoapService* svc = [[[SPSoapService alloc] init] autorelease];
    
    SPServiceSettings* settings = [SPServiceFactory serviceSettings];
    svc.resourceUrl = [[settings sharedRootUrl] stringByAppendingString:resourcePath];
    svc.credentials = [settings sharedCredentials];
    return svc;
}

+ (SPSoapService*) listService
{
    return [SPServiceFactory makeService:@"/_vti_bin/Lists.asmx"];
}

+ (SPSoapService*) siteDataService
{
    return [SPServiceFactory makeService:@"/_vti_bin/SiteData.asmx"];
}

@end
