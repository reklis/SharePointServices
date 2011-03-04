//
//  SPSiteData.m
//  SharePointClient
//
//  Created by Steven Fusco on 3/3/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPSiteData.h"


@implementation SPSiteData

+ (SPSiteData*) siteData
{
    return [[[SPSiteData alloc] initWithService:[SPServiceFactory siteDataService]] autorelease];
}

- (void) getListItems:(NSString*)listName
                query:(NSString*)query 
           viewFields:(NSString*)viewFields 
             rowLimit:(NSString*)rowLimit 
              handler:(SPSoapRequestCompletedBlock)handler
{
    [self.service execute:@"http://schemas.microsoft.com/sharepoint/soap/GetListItems"
              requestBody:[NSString stringWithFormat:@"<GetListItems xmlns=\"http://schemas.microsoft.com/sharepoint/soap/\"><strListName>%@</strListName><strQuery>%@</strQuery><strViewFields>%@</strViewFields><uRowLimit>%@</uRowLimit></GetListItems>",
                      listName, query, viewFields, rowLimit]
              withHandler:handler];
}

- (void) enumerateFolder:(NSString*)folderUrl withHandler:(SPSoapRequestCompletedBlock)handler
{
    [self.service execute:@"http://schemas.microsoft.com/sharepoint/soap/EnumerateFolder"
              requestBody:[NSString stringWithFormat:@"<EnumerateFolder xmlns=\"http://schemas.microsoft.com/sharepoint/soap/\"><strFolderUrl>%@</strFolderUrl></EnumerateFolder>",
                           folderUrl]
              withHandler:handler];
}

- (void) getWeb:(SPSoapRequestCompletedBlock)handler
{
    [self.service execute:@"http://schemas.microsoft.com/sharepoint/soap/GetWeb"
              requestBody:@"<GetWeb xmlns=\"http://schemas.microsoft.com/sharepoint/soap/\" />"
              withHandler:handler];
}

- (void) getSite:(SPSoapRequestCompletedBlock)handler
{
    [self.service execute:@"http://schemas.microsoft.com/sharepoint/soap/GetSite"
              requestBody:@"<GetSite xmlns=\"http://schemas.microsoft.com/sharepoint/soap/\" />"
              withHandler:handler];
}

- (void) getSiteAndWeb:(NSString*)strUrl withHandler:(SPSoapRequestCompletedBlock)handler
{
    [self.service execute:@"http://schemas.microsoft.com/sharepoint/soap/GetSiteAndWeb"
              requestBody:[NSString stringWithFormat:@"<GetSiteAndWeb xmlns=\"http://schemas.microsoft.com/sharepoint/soap/\"><strUrl>%@</strUrl></GetSiteAndWeb>",
                           strUrl]
              withHandler:handler];
    }

@end
