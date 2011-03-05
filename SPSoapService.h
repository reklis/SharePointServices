//
//  SPSoapService.h
//  SharePointClient
//
//  Created by Steven Fusco on 2/27/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SPCredentials.h"
#import "SPSoapRequest.h"

typedef void (^SPSoapRequestCompletedBlock)(SPSoapRequest* request);


@interface SPSoapService : NSObject {

}

@property (readwrite,nonatomic,assign) SPCredentials* credentials; // weak reference
@property (readwrite,nonatomic,retain) NSString* resourceUrl;

+ (NSData*) makeSoapEnvelope:(NSString*)requestBody;

- (void) execute:(NSString*)soapAction
     requestBody:(NSString*)body
     withHandler:(SPSoapRequestCompletedBlock)handler;

@end

@interface SPSoapServiceEntity : NSObject {
    
}

@property (readwrite,nonatomic,retain) SPSoapService* service;

- (id) initWithService:(SPSoapService*)svc;
- (NSString*) contextUrl;

@end