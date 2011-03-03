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

- (void) testListServiceGetListCollection
{
    SPList* list = [SPList list];
    
    [list getListCollection:^(SPSoapRequest* req){
        STAssertNotNil(req, @"Request nil");
        STAssertNotNil([req responseString], @"response string nil");
        [log write:[req responseString]];
        STAssertEquals([req responseStatusCode], HTTPStatusOK, [req responseStatusMessage]);
        
        __block int blockExecCount = 0;
        [req responseNodesForXPath:@"//sp:List" usingBlock:^(XPathResult* r) {
            STAssertNotNil(r, @"result should not be nil");
            [log write:[NSString stringWithFormat:@"%@", r]];
            STAssertEqualObjects(r.name, @"List", @"name of element matched not list");
            STAssertEqualObjects(r.content, @"", @"content of list should be empty");
            
            ++blockExecCount;
        }];
        
        STAssertTrue(blockExecCount == 26, [NSString stringWithFormat:@"%d blocks executed", blockExecCount]);
    }];
}

- (void) testListServiceGetListByName
{
    SPList* list = [SPList list];
    
    [list getList:@"Calendar" handler:^(SPSoapRequest* req){
        STAssertNotNil(req, @"Request nil");
        STAssertNotNil([req responseString], @"response string nil");
        [log write:[req responseString]];
        STAssertEquals([req responseStatusCode], HTTPStatusOK, [req responseStatusMessage]);
        
        NSArray* results = [req responseNodesForXPath:@"//sp:List/@Title"];
        STAssertNotNil(results, @"results should not be nil");
        
        [log write:[NSString stringWithFormat:@"%@", results]];
        
        STAssertEquals((int)results.count, (int)1, [NSString stringWithFormat:@"found %d", [results count]]);
        
        XPathResult* r = [results objectAtIndex:0];
        STAssertNotNil(r, @"first object in array should not be nil");
        STAssertEqualObjects(r.content, @"Calendar", @"result title not equal to list name searched");
        
        NSArray* fields = [req responseNodesForXPath:@"//sp:Field"];
        STAssertNotNil(fields, @"fields results should not be nil");
        STAssertEquals((int)fields.count, (int)103, [NSString stringWithFormat:@"found %d", [fields count]]);
    }];
}

//- (void) tearDown
//{
//    [super tearDown];
//}

#endif


@end
