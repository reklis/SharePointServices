//
//  SPList.h
//  SharePointClient
//
//  Created by Steven Fusco on 2/27/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SPSoapService.h"

@interface SPList : SPSoapServiceEntity {
}

+ (SPList*) list;

- (void) getListCollection:(SPSoapRequestCompletedBlock)handler;
- (void) getList:(NSString*)listName handler:(SPSoapRequestCompletedBlock)handler;
- (void) getListItems:(NSString*)listName
             viewName:(NSString*)viewName 
                query:(NSString*)query 
           viewFields:(NSString*)viewFields 
             rowLimit:(NSString*)rowLimit 
         queryOptions:(NSString*)queryOptions 
                webID:(NSString*)webID
              handler:(SPSoapRequestCompletedBlock)handler;

@end
