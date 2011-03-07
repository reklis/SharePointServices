//
//  SPSoapRequest.m
//  SharePointClient
//
//  Created by Steven Fusco on 2/27/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPSoapRequest.h"

@implementation SPSoapRequest

+ (NSDictionary*) sharepointNamespaces
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"http://schemas.xmlsoap.org/soap/envelope/", @"soap",
            @"http://www.w3.org/2001/XMLSchema-instance", @"xsi",
            @"http://www.w3.org/2001/XMLSchema", @"xsd",
            @"http://schemas.microsoft.com/sharepoint/soap/", @"sp",
            @"urn:schemas-microsoft-com:rowset", @"rs",
            @"#RowsetSchema", @"z",
         nil];
}

- (NSArray*) responseNodesForXPath:(NSString*)query
{
    return [[self responseData] findXPath:query
                          usingNamespaces:[SPSoapRequest sharepointNamespaces]];
}

- (NSString*) responseNodeContentForXPath:(NSString*)query
{
    return [[self responseData] contentAtXPath:query
                               usingNamespaces:[SPSoapRequest sharepointNamespaces]];
}

- (void) responseNodesForXPath:(NSString *)query usingBlock:(XPathResultBlock)handler
{
    [[self responseData] findXPath:query
                   usingNamespaces:[SPSoapRequest sharepointNamespaces]
                      executeBlock:handler];
}

@end
