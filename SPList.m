//
//  SPList.m
//  SharePointClient
//
//  Created by Steven Fusco on 2/27/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPList.h"

#import "SPServiceFactory.h"

@implementation SPList

+ (SPList*) list
{
    SPSoapService* svc = [SPServiceFactory makeService:@"/_vti_bin/Lists.asmx"];
    SPList* listSvc = [[[SPList alloc] initWithService:svc] autorelease];
    return listSvc;
}

- (void) getListCollection:(SPSoapRequestCompletedBlock)handler
{
    [self.service execute:@"http://schemas.microsoft.com/sharepoint/soap/GetListCollection"
              requestBody:@"<GetListCollection xmlns=\"http://schemas.microsoft.com/sharepoint/soap/\" />"
              withHandler:handler];
}

- (void) getList:(NSString*)listName handler:(SPSoapRequestCompletedBlock)handler
{
    [self.service execute:@"http://schemas.microsoft.com/sharepoint/soap/GetList"
              requestBody:[NSString stringWithFormat:@"<GetList xmlns=\"http://schemas.microsoft.com/sharepoint/soap/\"><listName>%@</listName></GetList>", listName]
              withHandler:handler];
}

- (void) getListItems:(NSString*)listName
             viewName:(NSString*)viewName 
                query:(NSString*)query 
           viewFields:(NSString*)viewFields 
             rowLimit:(NSString*)rowLimit 
         queryOptions:(NSString*)queryOptions 
                webID:(NSString*)webID
              handler:(SPSoapRequestCompletedBlock)handler
{
    [self.service execute:@"http://schemas.microsoft.com/sharepoint/soap/GetListItems"
              requestBody:[NSString stringWithFormat:@"<GetListItems xmlns=\"http://schemas.microsoft.com/sharepoint/soap/\"><listName>%@</listName><viewName>%@</viewName><query>%@</query><viewFields>%@</viewFields><rowLimit>%@</rowLimit><queryOptions>%@</queryOptions><webID>%@</webID></GetListItems>",
                      listName, viewName, query, viewFields, rowLimit, queryOptions, webID]
              withHandler:handler];
}

- (void) updateListItems:(NSString*)listName updates:(NSString*)batchUpdateXml handler:(SPSoapRequestCompletedBlock)handler
{
    [self.service execute:@"http://schemas.microsoft.com/sharepoint/soap/UpdateListItems"
              requestBody:[NSString stringWithFormat:@"<UpdateListItems xmlns=\"http://schemas.microsoft.com/sharepoint/soap/\"><listName>%@</listName><updates>%@</updates></UpdateListItems>",
                           listName, batchUpdateXml]
              withHandler:handler];
}

- (void) deleteListItemId:(NSString*)listItemId inList:(NSString*)listName handler:(SPSoapRequestCompletedBlock)handler
{
    // wrapper method for batch update to remove a single item, not part of the soap spec
    
    NSString* viewName = @""; // empty view name == use the default view
    NSString* batchUpdateXml = [NSString stringWithFormat:@"<Batch OnError=\"Continue\" ListVersion=\"1\" ViewName=\"%@\"><Method ID=\"1\" Cmd=\"Delete\"><Field Name='ID'>%@</Field></Method></Batch>", viewName, listItemId];
    [self updateListItems:listName updates:batchUpdateXml handler:handler];
}

@end
