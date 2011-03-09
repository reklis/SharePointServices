//
//  SPUnitTests.m
//  SharePointClient
//
//  Created by Steven Fusco on 2/27/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPUnitTests.h"

#import "SPUnitTestCredentials.h" // not included in source control for security reasons

@implementation SPDebugLogger

- (id) init
{
    self = [super init];
    if (self != nil) {
        logFile = fopen("/SPUnitTests.log", "a");
    }
    return self;
}

- (void) dealloc
{
    fclose(logFile);
    [super dealloc];
}


- (void) write:(NSString*)message
{
    fprintf(logFile, "%s\n", [message cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    fflush(logFile);
}

@end

#define STAssertHTTPOK(_REQ_) STAssertEquals([_REQ_ responseStatusCode], HTTPStatusOK, [_REQ_ responseString])

@implementation SPUnitTests

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void) testAppDelegate {
    
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    
}

#else                           // all code under test must be linked into the Unit Test bundle

- (void) setUp
{
    [super setUp];
    
    SPServiceSettings* settings = [SPServiceSettings settings];
    
    [settings setSharedCredentials:[SPUnitTestCredentials testCredentials]];
    
    [settings setSharedRootUrl:[SPUnitTestCredentials testUrl]];
    
    [settings setSynchronousNetworkMode:YES];
    [settings setDebugMode:YES];
    
    [SPServiceFactory setServiceSettings:settings];
    
    log = [[[SPDebugLogger alloc] init] autorelease];
}

- (void) testList_GetListCollection
{
    SPList* list = [SPList list];
    
    [list getListCollection:^(SPSoapRequest* req){
        STAssertNotNil(req, @"Request nil");
        STAssertNotNil([req responseString], @"response string nil");
        //[log write:[req responseString]];
        STAssertEquals([req responseStatusCode], HTTPStatusOK, [req responseStatusMessage]);
        
        __block int blockExecCount = 0;
        [req responseNodesForXPath:@"//sp:List" usingBlock:^(XPathResult* r) {
            STAssertNotNil(r, @"result should not be nil");
            //[log write:[NSString stringWithFormat:@"%@", r]];
            STAssertEqualObjects(r.name, @"List", @"name of element matched not list");
            STAssertEqualObjects(r.content, @"", @"content of list should be empty");
            
            STAssertNotNil(r.attributes, @"attribute dictionary should not be nil");
            //[log write:[NSString stringWithFormat:@"%@", r.attributes]];
            STAssertTrue((r.attributes.count != 0), @"attribute count should not be zero");
            
            ++blockExecCount;
        }];
        
        STAssertTrue(blockExecCount != 0, [NSString stringWithFormat:@"%d blocks executed", blockExecCount]);
    }];
}

- (void) testList_GetListByName
{
    SPList* list = [SPList list];
    
    [list getList:@"Calendar" handler:^(SPSoapRequest* req){
        STAssertHTTPOK(req);
        
        NSArray* results = [req responseNodesForXPath:@"//sp:List"];
        STAssertNotNil(results, @"results should not be nil");
        
        //[log write:[NSString stringWithFormat:@"%@", results]];
        
        STAssertEquals((int)results.count, (int)1, [NSString stringWithFormat:@"found %d", [results count]]);
        
        if (results.count > 0) {
            XPathResult* r = [results objectAtIndex:0];
            STAssertNotNil(r, @"first object in array should not be nil");
            
            NSArray* fields = [req responseNodesForXPath:@"//sp:Field"];
            STAssertNotNil(fields, @"fields results should not be nil");
            STAssertEquals((int)fields.count, (int)103, [NSString stringWithFormat:@"found %d", [fields count]]);
            
            STAssertNotNil(r.attributes, @"attribute dictionary should not be nil");
            //[log write:[NSString stringWithFormat:@"%@", r.attributes]];
            STAssertTrue((r.attributes.count != 0), @"attribute count should not be zero");
            
            NSString* listId = [r.attributes objectForKey:@"ID"];
            
            [list getListItems:listId
                      viewName:@""
                         query:@"<Query></Query>"
                    viewFields:@"<ViewFields></ViewFields>"
                      rowLimit:@"0"
                  queryOptions:@"<QueryOptions><ExpandRecurrences>TRUE</ExpandRecurrences></QueryOptions>"
                         webID:@""
                       handler:^(SPSoapRequest* getListItemReq)
            {
                STAssertHTTPOK(getListItemReq);
                
                //[log write:[getListItemReq responseString]];
                
                __block int rowCount = 0;
                [getListItemReq responseNodesForXPath:@"//z:row" usingBlock:^(XPathResult *r)
                {
                    STAssertNotNil(r, @"result should not be nil");
                    
                    NSString* eventName = [getListItemReq responseNodeContentForXPath:[r.xpath stringByAppendingString:@"/@ows_Title"]];
                    STAssertNotNil(eventName, @"title should not be nil");

                    NSString* startDate = [getListItemReq responseNodeContentForXPath:[r.xpath stringByAppendingString:@"/@ows_EventDate"]];
                    STAssertNotNil(startDate, @"event date should not be nil");

                    NSString* endDate = [getListItemReq responseNodeContentForXPath:[r.xpath stringByAppendingString:@"/@ows_EndDate"]];
                    STAssertNotNil(endDate, @"end date should not be nil");
                    
                    NSString* location = [getListItemReq responseNodeContentForXPath:[r.xpath stringByAppendingString:@"/@ows_Location"]];
                    if (location != nil) {
                        NSUInteger strlen = [location length];
                        STAssertTrue(strlen != 0, @"if there is a location, it shouldn't be an empty string");
                    }
                    
                    NSString* isAllDay = [getListItemReq responseNodeContentForXPath:[r.xpath stringByAppendingString:@"/@ows_fAllDayEvent"]];
                    STAssertNotNil(isAllDay, @"is all day should not be nil");
                    STAssertTrue((([isAllDay isEqualToString:@"0"]) || ([isAllDay isEqualToString:@"1"])), @"'all day' flag should be 0 or 1");
                    
                    //[log write:[NSString stringWithFormat:@"title: %@ start: %@ end: %@", eventName, startDate, endDate]];

                    ++rowCount;
                }];
                STAssertTrue(rowCount == 7, @"should have found some rows");
            }];
        }
    }];
}

- (void) testSiteData_EnumerateFolder
{
    SPSiteData* siteData = [SPSiteData siteData];
    
    [siteData enumerateFolder:[[SPUnitTestCredentials testUrl] stringByAppendingString:@"/Shared%20Documents"]
                  withHandler:^(SPSoapRequest* enumFolderReq)
    {
        STAssertHTTPOK(enumFolderReq);
                
        //[log write:enumFolderReq.responseString];
    }];
}

- (void) testSiteData_GetSiteAndWeb
{
    SPSiteData* siteData = [SPSiteData siteData];
    
    [siteData getSiteAndWeb:[SPUnitTestCredentials testUrl]
                withHandler:^(SPSoapRequest* getSiteAndWebReq)
    {
        STAssertHTTPOK(getSiteAndWebReq);
    }];
}

- (void) testSiteData_GetSite
{
    SPSiteData* siteData = [SPSiteData siteData];
    
    [siteData getSite:^(SPSoapRequest* getSiteReq)
    {
        STAssertHTTPOK(getSiteReq);
    }];
}

- (void) testSiteData_GetWeb
{
    SPSiteData* siteData = [SPSiteData siteData];
    
    [siteData getWeb:^(SPSoapRequest *getWebReq)
    {
        STAssertHTTPOK(getWebReq);
    }];
}

- (void) testSiteData_GetListItems
{
    SPSiteData* siteData = [SPSiteData siteData];
    
    [siteData getWeb:^(SPSoapRequest *getWebReq)
    {
        STAssertHTTPOK(getWebReq);

        [getWebReq responseNodesForXPath:@"//sp:InternalName" usingBlock:^(XPathResult *r) {
            NSString* listId = r.content;
            
            STAssertNotNil(listId, @"list id should not be nil");
            
            //[log write:listId];
            
            [siteData getListItems:listId
                             query:@""
                        viewFields:@""
                          rowLimit:@"0"
                           handler:^(SPSoapRequest* listItemReq)
            {
                STAssertHTTPOK(listItemReq);
                               
                //[log write:listItemReq.responseString];
            }];
        
        }];
        
    }];
}

- (void) testRestrictedPort
{
    ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:6666"]];
    
    [req setCompletionBlock:^(void) {
        STAssertHTTPOK(req);
        //[log write:[req responseString]];
    }];
    
    [req setFailedBlock:^(void) {
        STAssertNil([req error], @"request encountered error %@", [req error]);
    }];
    
    [req startSynchronous];

    STAssertNil([req error], @"request encountered error %@", [req error]);
}

//- (void) tearDown
//{
//    [super tearDown];
//}

#endif


@end
