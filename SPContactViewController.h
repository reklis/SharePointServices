//
//  SPContactViewController.h
//  SharePointClient
//
//  Created by Steven Fusco on 3/9/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SPContactDataSource.h"

@protocol SPContactViewControllerDelegate;

@interface SPContactViewController : UITableViewController
{
@private
    NSString* _contactListName;
    SPContactDataSource* _contactDataSource;
}

@property (readwrite,nonatomic,retain) NSString* contactListName;
@property (readwrite,nonatomic,retain) SPContactDataSource* contactDataSource;

@property (readwrite,nonatomic,assign) id<SPContactViewControllerDelegate> delegate;

- (void) createDataSource;

@end



@protocol SPContactViewControllerDelegate <NSObject>

@optional

- (void) contactViewController:(SPContactViewController*)viewController didSelectContact:(SPContact*)contact;

@end