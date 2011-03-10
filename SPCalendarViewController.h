//
//  SPCalendarViewController.h
//  SharePointClient
//
//  Created by Steven Fusco on 3/8/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SPCalendarDataSource.h"

@interface SPCalendarViewController : UITableViewController
{
@private
    NSString* _calendarName;
    SPCalendarDataSource* _calendarDataSource;
}

- (id)initWithStyle:(UITableViewStyle)style calendarName:(NSString*)calendarName;

@end
