//
//  SPSoapRequest.h
//  SharePointClient
//
//  Created by Steven Fusco on 2/27/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"

#import "NSData+XPath.h"

typedef enum HTTPStatusEnum {
    HTTPStatusOK = 200,
    HTTPStatusServerError = 500,
    HTTPStatusUnauthorized = 401,
    HTTPStatusForbidden = 403
} HTTPStatus;

@interface SPSoapRequest : ASIHTTPRequest
{
}

+ (NSDictionary*) sharepointNamespaces;

- (NSArray*) responseNodesForXPath:(NSString*)query;
- (void) responseNodesForXPath:(NSString *)query usingBlock:(XPathResultBlock)handler;

@end
