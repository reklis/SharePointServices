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

@synthesize listSvc;

+ (SPList*) list
{
    return [[[SPList alloc] initWithService:[SPServiceFactory listService]] autorelease];
}

- (id) initWithService:(SPSoapService*)listService
{
    self = [super init];
    if (self != nil) {
        self.listSvc = listService;
    }
    return self;
}

- (void) getListCollection:(SPSoapRequestCompletedBlock)handler
{
    [listSvc execute:@"http://schemas.microsoft.com/sharepoint/soap/GetListCollection"
         requestBody:@"<GetListCollection xmlns=\"http://schemas.microsoft.com/sharepoint/soap/\" />"
         withHandler:handler
     ];
}

- (void) getList:(NSString*)listName handler:(SPSoapRequestCompletedBlock)handler
{
    [listSvc execute:@"http://schemas.microsoft.com/sharepoint/soap/GetList"
         requestBody:[NSString stringWithFormat:@"<GetList xmlns=\"http://schemas.microsoft.com/sharepoint/soap/\"><listName>%@</listName></GetList>", listName]
         withHandler:handler];
}

@end
