//
//  SPCalendarDataSource.m
//  SharePointClient
//
//  Created by Steven Fusco on 3/8/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPCalendarDataSource.h"

@implementation SPCalendarItem

@synthesize title;
@synthesize startDate;
@synthesize endDate;
@synthesize location;
@synthesize isAllDay;

+ (SPCalendarItem*) calendarItemWithTitle:(NSString*)title
                                    start:(NSDate*)start
                                      end:(NSDate*)end
                                 location:(NSString*)loc
                                   allDay:(BOOL)allDay
{
    SPCalendarItem* event = [[[SPCalendarItem alloc] init] autorelease];
    
    event.title = title;
    event.startDate = start;
    event.endDate = end;
    event.location = loc;
    event.isAllDay = allDay;
    
    return event;
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@ %@", self.title, self.formattedTimespan];
}

- (NSString*) formattedTimespan
{
    NSDateFormatter* timespanFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [timespanFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString* startTimeString = [timespanFormatter stringFromDate:self.startDate];
    NSString* endTimeString = [timespanFormatter stringFromDate:self.endDate];
    
    return [NSString stringWithFormat:@"%@ - %@", startTimeString, endTimeString];
}

- (void)dealloc {
    [title release];
    [startDate release];
    [endDate release];
    [location release];
    [super dealloc];
}

@end

@implementation SPCalendarDataSource

@synthesize events;
@synthesize eventDays;

- (id)init {
    self = [super init];
    if (self) {
        list = [[SPList list] retain];
    }
    return self;
}

- (void)dealloc {
    [list release];
    [eventDays release];
    [events release];
    
    [super dealloc];
}

- (void) loadCalendarNamed:(NSString*)listName
{
    if (self.dataSourceState == SPDataSourceStateLoading) {
        return;
    }
    
    self.dataSourceState = SPDataSourceStateLoading;
    
    [list getList:listName handler:^(SPSoapRequest* req)
    {
        if (req.responseStatusCode != 200) {
            self.dataSourceState = SPDataSourceStateFailed;
            return;
        }

        NSString* listId = [req responseNodeContentForXPath:@"//sp:List/@ID"];

        NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

        // TODO: adjust query such that we avoid events that are too old or too far off into the future
        [list getListItems:listId
                  viewName:@""
                     query:@"<Query></Query>"
                viewFields:@"<ViewFields></ViewFields>"
                  rowLimit:@"0"
              queryOptions:@"<QueryOptions><ExpandRecurrences>TRUE</ExpandRecurrences></QueryOptions>"
                     webID:@""
                   handler:^(SPSoapRequest* getListItemReq)
        {
            if (getListItemReq.responseStatusCode != 200) {
                self.dataSourceState = SPDataSourceStateFailed;
                return;
            }

            __block NSMutableDictionary* myEvents = [NSMutableDictionary dictionary];
            NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

            [getListItemReq responseNodesForXPath:@"//z:row" usingBlock:^(XPathResult *r)
            {
                NSString* eventName = [r.attributes objectForKey:@"ows_Title"];
                NSString* startDate = [r.attributes objectForKey:@"ows_EventDate"];
                NSString* endDate = [r.attributes objectForKey:@"ows_EndDate"];
                NSString* location = [r.attributes objectForKey:@"ows_Location"];
                NSString* isAllDay = [r.attributes objectForKey:@"ows_fAllDayEvent"];

                SPCalendarItem* event = [SPCalendarItem calendarItemWithTitle:eventName
                                                                        start:[dateFormatter dateFromString:startDate]
                                                                          end:[dateFormatter dateFromString:endDate]
                                                                     location:location
                                                                       allDay:[isAllDay isEqualToString:@"YES"]];

                NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                                fromDate:event.startDate];

                NSDate* k = [gregorian dateFromComponents:dateComponents];

                if (![[myEvents allKeys] containsObject:k]) {
                    [myEvents setObject:[NSMutableArray array] forKey:k];
                }

                NSMutableArray* a = (NSMutableArray*) [myEvents objectForKey:k];
                [a addObject:event];
                
                //NSLog(@"Indexed %@", event);
            }];

            [gregorian release];

            self.events = myEvents;
            
            self.eventDays = [[self.events allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
            {
                NSDate* d1 = (NSDate*)obj1;
                NSDate* d2 = (NSDate*)obj2;

                return [d1 compare:d2];
            }];

            for (NSMutableArray* a in [self.events allValues]) {
                [a sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
                {
                    SPCalendarItem* i1 = (SPCalendarItem*) obj1;
                    SPCalendarItem* i2 = (SPCalendarItem*) obj2;
                    
                    return [i1.startDate compare:i2.startDate];
                }];
            }

            self.dataSourceState = SPDataSourceStateSucceeded;
        }];
    }];
}

- (SPCalendarItem*) itemAtPath:(NSIndexPath*)indexPath
{
    NSDate* k = [self.eventDays objectAtIndex:indexPath.section];
    NSArray* items = [self.events objectForKey:k];
    SPCalendarItem* i = [items objectAtIndex:indexPath.row];
    return i;
}

#pragma UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (self.dataSourceState) {
        case SPDataSourceStateSucceeded:
            return [self.eventDays count];
        default:
            return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (self.dataSourceState) {
        case SPDataSourceStateSucceeded:
        {
            NSDate* d = [self.eventDays objectAtIndex:section];
            
            NSDateFormatter* headerFormatter = [[[NSDateFormatter alloc] init] autorelease];
            [headerFormatter setDateStyle:NSDateFormatterFullStyle];
            
            return [headerFormatter stringFromDate:d];
        }
            
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.dataSourceState) {
        case SPDataSourceStateSucceeded:
        {
            NSDate* k = [self.eventDays objectAtIndex:section];
            NSArray* items = [self.events objectForKey:k];
            return [items count];
        }
        default:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* calCellId = @"calendarItemCell";
    static NSString* transitionCellId = @"transitionCellId";
    
    
    NSString* cellId = (self.dataSourceState == SPDataSourceStateSucceeded) ? calCellId : transitionCellId;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:(self.dataSourceState == SPDataSourceStateSucceeded) ? UITableViewCellStyleValue2 : UITableViewCellStyleDefault
                                       reuseIdentifier:cellId] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (self.dataSourceState) {
        case SPDataSourceStateUnknown:
        case SPDataSourceStateLoading:
            cell.textLabel.text = NSLocalizedString(@"Loading...", @"Loading...");
            break;
            
        case SPDataSourceStateFailed:
            cell.textLabel.text = NSLocalizedString(@"Error loading contents", @"Error loading contents");
            break;
            
            
        case SPDataSourceStateSucceeded:
        {
            SPCalendarItem* item = [self itemAtPath:indexPath];
            
            cell.textLabel.text = item.title;
            cell.detailTextLabel.text = item.formattedTimespan;
        }
            break;
            
            
        default:
            break;
    }
    
    
    return cell;
}


@end
