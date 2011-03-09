//
//  SPFolderDataSource.h
//  SharePointClient
//
//  Created by Steven Fusco on 3/4/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SharePointServices.h"
#import "SPDataSource.h"

@class SPFolderItem;

@interface SPFolderDataSource : SPDataSource
{
@private
    SPSiteData* siteData;
}

+ (SPFolderDataSource*) folderDataSourceForUrl:(NSString*)folderUrl;
+ (SPFolderDataSource*) folderDataSourceForUrl:(NSString*)folderUrl filter:(NSString*)regex;

@property (readwrite,nonatomic,retain) NSString* folderUrl;
@property (readwrite,nonatomic,retain) NSString* filter;
@property (readwrite,nonatomic,retain) NSArray* directoryContents;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void) loadFolderAtUrl:(NSString*)url;
- (void) refresh;

- (SPFolderItem*) itemAtPath:(NSIndexPath*)indexPath;

@end


@interface SPFolderItem : NSObject
{
}

+ (SPFolderItem*) itemWithName:(NSString*)n url:(NSString*)u isFolder:(BOOL)f;

@property (readwrite,nonatomic,retain) NSString* url;
@property (readwrite,nonatomic,retain) NSString* name;
@property (readwrite,nonatomic,assign) BOOL isFolder;

@end

