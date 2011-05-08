//
//  SPCalendarDataSource.h
//  SharePointClient
//
//  Created by Steven Fusco on 3/8/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SharePointServices.h"
#import "SPDataSource.h"

@class SPCalendarItem;

@interface SPCalendarDataSource : SPDataSource
{
@private
    SPList* list;
}

@property (readwrite,retain) NSMutableDictionary* events;
@property (readwrite,retain) NSArray* eventDays;

- (SPCalendarItem*) itemAtPath:(NSIndexPath*)indexPath;
- (void) loadCalendarNamed:(NSString*)listName;

@end

@interface SPCalendarItem : NSObject <NSCoding>
{
}

+ (SPCalendarItem*) calendarItemWithTitle:(NSString*)title
                                    start:(NSDate*)start
                                      end:(NSDate*)end
                                 location:(NSString*)loc
                                   allDay:(BOOL)allDay;

@property (readwrite,nonatomic,retain) NSString* title;
@property (readwrite,nonatomic,retain) NSDate* startDate;
@property (readwrite,nonatomic,retain) NSDate* endDate;
@property (readwrite,nonatomic,retain) NSString* location;
@property (readwrite,nonatomic,assign) BOOL isAllDay;

- (NSString*) formattedTimespan;

@end