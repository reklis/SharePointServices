//
//  SPServiceFactory.h
//  SharePointClient
//
//  Created by Steven Fusco on 2/27/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SPCredentials.h"
#import "SPSoapService.h"
#import "SPServiceSettings.h"

@interface SPServiceFactory : NSObject {

}

+ (SPServiceSettings*) serviceSettings;
+ (void) setServiceSettings:(SPServiceSettings*)s;

+ (SPSoapService*) makeService:(NSString*)resourcePath;

+ (SPSoapService*) listService;
+ (SPSoapService*) siteDataService;

@end
