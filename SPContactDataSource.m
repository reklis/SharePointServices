//
//  SPContactDataSource.m
//  SharePointClient
//
//  Created by Steven Fusco on 3/9/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPContactDataSource.h"

@implementation SPContact

@synthesize lastName;
@synthesize firstName;
@synthesize email;
@synthesize jobTitle;
@synthesize workPhone;
@synthesize mobilePhone;

- (void)dealloc {
    [lastName release];
    [firstName release];
    [email release];
    [jobTitle release];
    [workPhone release];
    [mobilePhone release];
    [super dealloc];
}

- (NSString*) description
{
    return [self formattedName];
}

- (NSString*) formattedName
{
    if (firstName && lastName) {
        return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    } else {
        if (firstName) {
            return firstName;
        } else if (lastName) {
            return lastName;
        } else {
            return @"";
        }
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.lastName = [decoder decodeObjectForKey:@"lastName"];
        self.firstName = [decoder decodeObjectForKey:@"firstName"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.jobTitle = [decoder decodeObjectForKey:@"jobTitle"];
        self.workPhone = [decoder decodeObjectForKey:@"workPhone"];
        self.mobilePhone = [decoder decodeObjectForKey:@"mobilePhone"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.lastName forKey:@"lastName"];
    [encoder encodeObject:self.firstName forKey:@"firstName"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.jobTitle forKey:@"jobTitle"];
    [encoder encodeObject:self.workPhone forKey:@"workPhone"];
    [encoder encodeObject:self.mobilePhone forKey:@"mobilePhone"];
}

@end


@interface SPContactDataSource(Private)
- (void) indexContacts;
- (void) handleHttpError:(NSError*)httpError;
@end


@implementation SPContactDataSource

@synthesize contactIndexes;

- (id)init {
    self = [super init];
    if (self) {
        list = [[SPList list] retain];
    }
    return self;
}

- (void)dealloc {
    [contactIndexes release];
    [list release];
    [super dealloc];
}

- (NSDictionary*) contacts {
    return self.cacheRootObject;
}

- (void) setContacts:(NSDictionary *)contacts
{
    self.cacheRootObject = contacts;
}

- (void) loadContactsListNamed:(NSString*)listName
{
    if (self.dataSourceState == SPDataSourceStateLoading) {
        return;
    }
    
    self.dataSourceState = SPDataSourceStateLoading;
    [list getList:listName handler:^(SPSoapRequest* req)
     {
         if (req.error) {
             [self handleHttpError:req.error];
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
              if (getListItemReq.error) {
                  [self handleHttpError:getListItemReq.error];
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
                   c.mobilePhone = [r.attributes objectForKey:@"ows_CellPhone"];
                   
                   NSString* k = [c.lastName substringToIndex:1];
                   
                   if (![[myContacts allKeys] containsObject:k]) {
                       [myContacts setObject:[NSMutableArray array] forKey:k];
                   }
                   
                   NSMutableArray* a = (NSMutableArray*) [myContacts objectForKey:k];
                   [a addObject:c];
                   
                   //NSLog(@"Indexed %@", c); 
               }];
              
              self.contacts = myContacts;
              [self indexContacts];
              [self saveCachedResults];
              
              self.dataSourceState = SPDataSourceStateSucceeded;
          }];
     }];
    
}

- (void) indexContacts
{
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
}

- (void) handleHttpError:(NSError *)httpError
{
    NSLog(@"error retrieving contacts: %@", httpError);
    
    if (!self.cacheRootObject) {
        [self loadCachedResults];
    }
    
    if (self.contacts) {
        [self indexContacts];
        self.dataSourceState = SPDataSourceStateSucceeded;
    } else {
        self.dataSourceState = SPDataSourceStateFailed;
    }
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
            
            cell.textLabel.text = [item formattedName];
            cell.detailTextLabel.text = item.jobTitle;
        }
            break;
            
            
        default:
            break;
    }
    
    
    return cell;
}


@end
