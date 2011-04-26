//
//  SPDataSource.m
//  SharePointClient
//
//  Created by Steven Fusco on 3/8/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPDataSource.h"


@implementation SPDataSource

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

@end
