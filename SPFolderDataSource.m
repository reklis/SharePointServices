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

@end


@implementation SPFolderDataSource

@synthesize directoryContents;
@synthesize filter;
@synthesize folderUrl;

+ (SPFolderDataSource*) folderDataSourceForUrl:(NSString*)folderUrl filter:(NSString*)regex
{
    SPFolderDataSource* ds = [[[SPFolderDataSource alloc] init] autorelease];
    ds.filter = regex;
    
    [ds loadFolderAtUrl:folderUrl];

    return ds;
}

+ (SPFolderDataSource*) folderDataSourceForUrl:(NSString*)folderUrl
{
    SPFolderDataSource* ds = [SPFolderDataSource folderDataSourceForUrl:folderUrl
                                                                 filter:nil];
    return ds;
}

#pragma Initialization

- (id)init {
    self = [super init];
    if (self) {
        siteData = [[SPSiteData siteData] retain];
    }
    return self;
}

- (void)dealloc {
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
            return [self.directoryContents count];
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
    
    switch (self.dataSourceState) {
        case SPDataSourceStateUnknown:
        case SPDataSourceStateLoading:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = NSLocalizedString(@"Loading...", @"Loading...");
            //[cell.accessoryView addSubview:[[[UIActivityIndicatorView alloc] init] autorelease]];
            
            break;
        
        case SPDataSourceStateFailed:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = NSLocalizedString(@"Error loading contents", @"Error loading contents");
            
            break;
            
        
        case SPDataSourceStateSucceeded:
        {
            SPFolderItem* item = [self itemAtPath:indexPath];
            
            cell.accessoryType = (item.isFolder) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
            cell.textLabel.text = item.name;
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
        if (folderReq.responseStatusCode != 200) {
            NSLog(@"SPSiteData::EnumerateFolder Error: %@", folderReq.responseStatusMessage);
            
            self.dataSourceState = SPDataSourceStateFailed;
        } else {
            __block NSMutableArray* dir = [NSMutableArray array];
            
            [folderReq responseNodesForXPath:@"//sp:_sFPUrl" usingBlock:^(XPathResult* r)
            {
                NSLog(@"%@", r);
                
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
    SPFolderItem* item = [self.directoryContents objectAtIndex:indexPath.row];
    return item;
}

@end
