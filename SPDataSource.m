//
//  SPDataSource.m
//  SharePointClient
//
//  Created by Steven Fusco on 3/8/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPDataSource.h"


@implementation SPDataSource

#pragma mark Data

@synthesize dataSourceState;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void) refresh
{
    // default does nothing
}

- (void) addDataSourceObserver:(NSObject*)o
{
    [self addObserver:o
           forKeyPath:@"dataSourceState"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

#pragma mark Cache

@synthesize cacheRootObject, cacheFileName;

- (void) removeDataSourceObserver:(NSObject*)o
{
    @try {
        [self removeObserver:o
                  forKeyPath:@"dataSourceState"];
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

- (void) saveCachedResults
{
    id<NSCoding> rootObj = [self cacheRootObject];
    NSString* archivePath = self.cacheFileName;
    if ((!rootObj) || (!archivePath)) return;
    
    @try {
        BOOL OK = [NSKeyedArchiver archiveRootObject:rootObj
                                              toFile:archivePath];
        if (!OK) {
            NSLog(@"%@ archiving to: %@ Failed", [self class], archivePath);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@ error caching subsites: %@", [self class], exception);
    }
}

- (void) loadCachedResults
{
    NSString* archivePath = self.cacheFileName;
    if (!archivePath) return;
    
    @try {
        self.cacheRootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
        //self.dataSourceState = SPDataSourceStateSucceeded;
    }
    @catch (NSException *exception) {
        NSLog(@"Error loading from cache: %@", exception);
        self.cacheRootObject = nil;
        //self.dataSourceState = SPDataSourceStateFailed;
    }
}

- (void)dealloc {
    [cacheRootObject release];
    [cacheFileName release];
    [super dealloc];
}

@end
