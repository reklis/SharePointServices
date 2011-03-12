//
//  SPFolderViewController.h
//  SharePointClient
//
//  Created by Steven Fusco on 3/4/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SPFolderDataSource.h"

@class SPFolderViewController;

@protocol SPFolderViewControllerDelegate <NSObject>

@optional

- (void) folderViewController:(SPFolderViewController*)folderViewController didSelectItem:(SPFolderItem*)item;

@end

@interface SPFolderViewController : UITableViewController <SPFolderViewControllerDelegate>
{
@private
    SPFolderDataSource* _folderDataSource;
    NSString* _directoryUrl;
    NSString* _directoryFilter;
}

@property (readwrite,nonatomic,assign) id<SPFolderViewControllerDelegate> delegate; // weak reference

@property (readwrite,nonatomic,retain) NSString* directoryUrl;
@property (readwrite,nonatomic,retain) NSString* directoryFilter;

@property (readwrite,nonatomic,retain) SPFolderDataSource* folderDataSource;

@end
