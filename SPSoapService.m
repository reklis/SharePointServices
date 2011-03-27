//
//  SPSoapService.m
//  SharePointClient
//
//  Created by Steven Fusco on 2/27/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPSoapService.h"

#import "SPServiceFactory.h"

@implementation SPSoapService

@synthesize credentials;
@synthesize resourceUrl;

+ (NSData*) makeSoapEnvelope:(NSString*)requestBody
{
    static const NSString* envOpen = @"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body>";
    static const NSString* envClose = @"</soap:Body></soap:Envelope>";
    
    NSString* env = [NSString stringWithFormat:@"%@%@%@", envOpen, requestBody, envClose];
    
    return [env dataUsingEncoding:NSUTF8StringEncoding];
}

- (void) execute:(NSString*)soapAction
     requestBody:(NSString*)body
     withHandler:(SPSoapRequestCompletedBlock)handler
{
    __block SPSoapRequest* req = [[[SPSoapRequest alloc] initWithURL:[NSURL URLWithString:self.resourceUrl]] autorelease];
    req.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
    
    SPServiceSettings* settings = [SPServiceFactory serviceSettings];
    
    if (settings.debugMode) {
        [req setValidatesSecureCertificate:NO];
    }
    
    [req setUsername:self.credentials.username];
    [req setPassword:self.credentials.password];
    [req setDomain:self.credentials.domain];
    
    NSMutableDictionary* soapHeaders = [NSMutableDictionary dictionaryWithCapacity:2];
    [soapHeaders setObject:@"text/xml; charset=utf-8" forKey:@"Content-Type"];
    [soapHeaders setObject:soapAction forKey:@"SOAPAction"];
    [req setRequestHeaders:soapHeaders];
    
    [req setRequestMethod:@"POST"];
    [req appendPostData:[SPSoapService makeSoapEnvelope:body]];
    
    [req setCompletionBlock:^{
        handler(req);
    }];
    
    [req setFailedBlock:^{
        NSLog(@"request failed %@", [req error]);
        handler(req);
    }];
    
    if (settings.synchronousNetworkMode) {
        NSLog(@"synchronousNetworkMode");
        [req startSynchronous];
    } else {
        [req startAsynchronous];
    }
}

@end

@implementation SPSoapServiceEntity

@synthesize service;

- (id) initWithService:(SPSoapService*)svc
{
    self = [super init];
    if (self != nil) {
        self.service = svc;
    }
    return self;
}

- (void)dealloc {
    [service release];
    
    [super dealloc];
}

- (NSString*) contextUrl
{
    NSURL* u = [NSURL URLWithString:self.service.resourceUrl];
    return [[[u URLByDeletingLastPathComponent] URLByDeletingLastPathComponent] absoluteString];
}

@end