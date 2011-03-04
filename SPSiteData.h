//
//  SPSiteData.h
//  SharePointClient
//
//  Created by Steven Fusco on 3/3/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SPServiceFactory.h"

@interface SPSiteData : SPSoapServiceEntity
{}

+ (SPSiteData*) siteData;

- (void) getListItems:(NSString*)listName
                query:(NSString*)query 
           viewFields:(NSString*)viewFields 
             rowLimit:(NSString*)rowLimit 
              handler:(SPSoapRequestCompletedBlock)handler;

- (void) enumerateFolder:(NSString*)folderUrl withHandler:(SPSoapRequestCompletedBlock)handler;

- (void) getWeb:(SPSoapRequestCompletedBlock)handler;
- (void) getSite:(SPSoapRequestCompletedBlock)handler;
- (void) getSiteAndWeb:(NSString*)strUrl withHandler:(SPSoapRequestCompletedBlock)handler;

@end
