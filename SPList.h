//
//  SPList.h
//  SharePointClient
//
//  Created by Steven Fusco on 2/27/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SPSoapService.h"

@interface SPList : NSObject {
}

@property (readwrite,nonatomic,retain) SPSoapService* listSvc;

+ (SPList*) list;

- (id) initWithService:(SPSoapService*)listService;

- (void) getListCollection:(SPSoapRequestCompletedBlock)handler;
- (void) getList:(NSString*)listName handler:(SPSoapRequestCompletedBlock)handler;

@end
