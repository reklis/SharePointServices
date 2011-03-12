//
//  SPContactDataSource.m
//  SharePointClient
//
//  Created by Steven Fusco on 3/9/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPContactDataSource.h"

@implementation SPContact

+ (SPContact*) contactWithLastName:(NSString*)last
                         firstName:(NSString*)first
                             email:(NSString*)em
                          jobTitle:(NSString*)jt
                         workPhone:(NSString*)wp
{
    SPContact* c = [[[SPContact alloc] init] autorelease];
    
    c.lastName = last;
    c.firstName = first;
    c.email = em;
    c.jobTitle = jt;
    c.workPhone = wp;
    
    return c;
}

@synthesize lastName;
@synthesize firstName;
@synthesize email;
@synthesize jobTitle;
@synthesize workPhone;

- (NSString*) description
{
    return [self formattedName];
}

- (NSString*) formattedName
{
    return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
}

@end

@implementation SPContactDataSource

@synthesize contacts;
@synthesize contactIndexes;

- (id)init {
    self = [super init];
    if (self) {
        list = [[SPList list] retain];
    }
    return self;
}

- (void)dealloc {
    [list release];
    [super dealloc];
}

- (void) loadContactsListNamed:(NSString*)listName
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
              
              __block NSMutableDictionary* myContacts = [NSMutableDictionary dictionary];
              
              [getListItemReq responseNodesForXPath:@"//z:row" usingBlock:^(XPathResult *r)
               {
                   SPContact* c = [[[SPContact alloc] init] autorelease];
                   
                   c.lastName = [r.attributes objectForKey:@"ows_Title"];
                   c.firstName = [r.attributes objectForKey:@"ows_FirstName"];
                   c.email = [r.attributes objectForKey:@"ows_Email"];
                   c.jobTitle = [r.attributes objectForKey:@"ows_JobTitle"];
                   c.workPhone = [r.attributes objectForKey:@"ows_WorkPhone"];
                   
                   NSString* k = [c.lastName substringToIndex:1];
                   
                   if (![[myContacts allKeys] containsObject:k]) {
                       [myContacts setObject:[NSMutableArray array] forKey:k];
                   }
                   
                   NSMutableArray* a = (NSMutableArray*) [myContacts objectForKey:k];
                   [a addObject:c];
                   
                   NSLog(@"Indexed %@", c); 
               }];
              
              self.contacts = myContacts;
              
              self.contactIndexes = [[self.contacts allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                                     {
                                         NSString* s1 = (NSString*)obj1;
                                         NSString* s2 = (NSString*)obj2;
                                         
                                         return [s1 compare:s2];
                                     }];
              
              for (NSMutableArray* a in [self.contacts allValues]) {
                  [a sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
                   {
                       SPContact* i1 = (SPContact*) obj1;
                       SPContact* i2 = (SPContact*) obj2;
                       
                       return [i1.lastName compare:i2.lastName];
                   }];
              }
              
              self.dataSourceState = SPDataSourceStateSucceeded;
          }];
     }];
    
}

- (SPContact*) itemAtPath:(NSIndexPath*)indexPath
{
    NSString* k = [self.contactIndexes objectAtIndex:indexPath.section];
    NSArray* items = [self.contacts objectForKey:k];
    SPContact* i = [items objectAtIndex:indexPath.row];
    return i;
}

#pragma UITableViewDataSource

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (self.dataSourceState) {
        case SPDataSourceStateSucceeded:
            return [self.contactIndexes count];
        default:
            return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (self.dataSourceState) {
        case SPDataSourceStateSucceeded:
            return [self.contactIndexes objectAtIndex:section];
            
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.dataSourceState) {
        case SPDataSourceStateSucceeded:
        {
            NSString* k = [self.contactIndexes objectAtIndex:section];
            NSArray* items = [self.contacts objectForKey:k];
            return [items count];
        }
        default:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"contactItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
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
            SPContact* item = [self itemAtPath:indexPath];
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", item.firstName, item.lastName];
            cell.detailTextLabel.text = item.jobTitle;
        }
            break;
            
            
        default:
            break;
    }
    
    
    return cell;
}


@end
