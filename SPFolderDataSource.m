//
//  SPFolderDataSource.m
//  SharePointClient
//
//  Created by Steven Fusco on 3/4/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPFolderDataSource.h"

@implementation SPFolderItem

@synthesize url;
@synthesize name;
@synthesize isFolder;

+ (SPFolderItem*) itemWithName:(NSString*)n url:(NSString*)u isFolder:(BOOL)f
{
    SPFolderItem* i = [[[SPFolderItem alloc] init] autorelease];
    
    i.url = u;
    i.name = n;
    i.isFolder = f;
    
    return i;
}

- (void)dealloc {
    [url release];
    [name release];
    
    [super dealloc];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@ %@ %@", [self class], [self name], [self url]];
}

@end


@implementation SPFolderDataSource

@synthesize directoryContents;
@synthesize filter;
@synthesize folderUrl;

+ (SPFolderDataSource*) folderDataSourceForUrl:(NSString*)folderUrl filter:(NSString*)regex withRoot:(NSString*)siteDataRoot
{
    SPFolderDataSource* ds = [[[SPFolderDataSource alloc] initWithRoot:siteDataRoot] autorelease];
    ds.filter = regex;
    
    [ds loadFolderAtUrl:folderUrl];
    
    return ds;
}

+ (SPFolderDataSource*) folderDataSourceForUrl:(NSString*)folderUrl filter:(NSString*)regex
{
    SPFolderDataSource* ds = [SPFolderDataSource folderDataSourceForUrl:folderUrl
                                                                 filter:regex
                                                               withRoot:nil];
    return ds;
}

+ (SPFolderDataSource*) folderDataSourceForUrl:(NSString*)folderUrl
{
    SPFolderDataSource* ds = [SPFolderDataSource folderDataSourceForUrl:folderUrl
                                                                 filter:nil
                                                               withRoot:nil];
    return ds;
}

#pragma Initialization

- (id)init
{
    self = [super init];
    if (self) {
        siteData = [[SPSiteData siteData] retain];
    }
    return self;
}

- (id)initWithRoot:(NSString*)siteRoot
{
    self = [super init];
    if (self) {
        siteData = [[SPSiteData siteDataWithRoot:siteRoot] retain];
    }
    return self;
}

- (void)dealloc
{
    [directoryContents release];
    [filter release];
    [siteData release];
    [folderUrl release];
    
    [super dealloc];
}

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.dataSourceState) {
        case SPDataSourceStateSucceeded:
        {
            int c = [self.directoryContents count];
            return (0 == c) ? 1 : c;
        }
        default:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"folderItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
    }
    
    //[cell.accessoryView.subviews performSelector:@selector(removeFromSuperview)];

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    //cell.textLabel.shadowColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor grayColor];

    switch (self.dataSourceState) {
        case SPDataSourceStateUnknown:
        case SPDataSourceStateLoading:
            cell.textLabel.text = NSLocalizedString(@"Loading...", @"Loading...");
            //[cell.accessoryView addSubview:[[[UIActivityIndicatorView alloc] init] autorelease]];
            
            break;
        
        case SPDataSourceStateFailed:
            cell.textLabel.text = NSLocalizedString(@"Error loading contents", @"Error loading contents");
            
            break;
        
        case SPDataSourceStateSucceeded:
        {
            int c = [self.directoryContents count];
            if (0 == c) {
                cell.textLabel.text = NSLocalizedString(@"Folder Empty", @"Folder Empty");
            } else {
                SPFolderItem* item = [self itemAtPath:indexPath];
                
                cell.accessoryType = (item.isFolder) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
                cell.textLabel.text = item.name;
                //cell.textLabel.shadowColor = [UIColor clearColor];
                cell.textLabel.textColor = [UIColor blackColor];
                cell.textLabel.textAlignment = UITextAlignmentLeft;
            }
        }
            break;

            
        default:
            break;
    }
    
    
    return cell;
}

- (void) loadFolderAtUrl:(NSString*)url
{
    if (self.dataSourceState == SPDataSourceStateLoading) {
        return;
    }
    
    self.folderUrl = url;
    self.dataSourceState = SPDataSourceStateLoading;
    
    [siteData enumerateFolder:url withHandler:^(SPSoapRequest* folderReq) 
    {
        if (folderReq.error) {
            NSLog(@"SPSiteData::EnumerateFolder Error: %@", folderReq.responseStatusMessage);
            
            self.dataSourceState = SPDataSourceStateFailed;
        } else {
            __block NSMutableArray* dir = [NSMutableArray array];
            
            [folderReq responseNodesForXPath:@"//sp:_sFPUrl" usingBlock:^(XPathResult* r)
            {
                NSString* itemUrl = [siteData.contextUrl stringByAppendingString:
                                     [folderReq responseNodeContentForXPath:[r.xpath stringByAppendingString:@"/*[1]"]]];
                
                NSString* isFolder = [folderReq responseNodeContentForXPath:[r.xpath stringByAppendingString:@"/*[3]"]];
                NSString* name = [[NSURL URLWithString:[itemUrl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]] lastPathComponent];
                
                BOOL addObject = YES;
                
                if (self.filter) {
                    NSError* error = nil;
                    NSRegularExpression* re = [NSRegularExpression regularExpressionWithPattern:self.filter
                                                                                        options:0
                                                                                          error:&error];
                    if (error) {
                        NSLog(@"Error in RegEx: %@", error);
                    } else {
                        if (0 != [re numberOfMatchesInString:name
                                                     options:0
                                                       range:NSMakeRange(0, name.length)]) {
                            addObject = NO;
                        }
                    }
                }
                
                if (addObject) {
                    SPFolderItem* item = [SPFolderItem itemWithName:name
                                                                url:itemUrl
                                                           isFolder:([isFolder isEqualToString:@"true"])];
                    [dir addObject:item];
                }
            }];
            
            [dir sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                SPFolderItem* i1 = (SPFolderItem*) obj1;
                SPFolderItem* i2 = (SPFolderItem*) obj2;
                return [i1.name compare:i2.name];
            }];
            
            self.directoryContents = dir;
            
            self.dataSourceState = SPDataSourceStateSucceeded;
        }
    }];
}

- (void) refresh
{
    [self loadFolderAtUrl:self.folderUrl];
}

- (SPFolderItem*) itemAtPath:(NSIndexPath*)indexPath
{
    if (SPDataSourceStateSucceeded == self.dataSourceState) {
        if (0 != self.directoryContents.count) {
            SPFolderItem* item = [self.directoryContents objectAtIndex:indexPath.row];
            return item;
        }
    }
    
    return nil;
}

@end
