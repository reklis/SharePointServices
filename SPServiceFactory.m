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

+ (SPSoapService*) makeService:(NSString*)resourcePath withRoot:(NSString*)siteRoot
{
    SPSoapService* svc = [[[SPSoapService alloc] init] autorelease];
    
    SPServiceSettings* settings = [SPServiceFactory serviceSettings];
    NSString* r = (nil == siteRoot) ? [settings sharedRootUrl] : siteRoot;
    svc.resourceUrl = [r stringByAppendingString:resourcePath];
    svc.credentials = [settings sharedCredentials];
    
    return svc;
}

+ (SPSoapService*) makeService:(NSString*)resourcePath
{
    return [SPServiceFactory makeService:resourcePath withRoot:nil];
}

@end
