//
//  SPDataSource.h
//  SharePointClient
//
//  Created by Steven Fusco on 3/8/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum SPDataSourceStateEnum
{
    SPDataSourceStateUnknown,
    SPDataSourceStateLoading,
    SPDataSourceStateSucceeded,
    SPDataSourceStateFailed
} SPDataSourceState;


@interface SPDataSource : NSObject <UITableViewDataSource>
{
    
}

@property (readwrite,assign) SPDataSourceState dataSourceState;

- (void) refresh;

- (void) addDataSourceObserver:(NSObject*)o;
- (void) removeDataSourceObserver:(NSObject*)o;

@property (readwrite,nonatomic,retain) id<NSObject,NSCoding> cacheRootObject;
@property (readwrite,nonatomic,retain) NSString* cacheFileName;

- (void) saveCachedResults;
- (void) loadCachedResults;

@end
