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

@end


@implementation SPFolderDataSource

@synthesize directoryContents;
@synthesize dataSourceState;

+ (SPFolderDataSource*) folderDataSourceForUrl:(NSString*)folderUrl
{
    SPFolderDataSource* ds = [[[SPFolderDataSource alloc] init] autorelease];
    [ds loadFolderAtUrl:folderUrl];
    return ds;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.dataSourceState) {
        case SPFolderDataSourceStateSucceeded:
            return [self.directoryContents count];
        default:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [cell.accessoryView.subviews performSelector:@selector(removeFromSuperview)];
    
    switch (self.dataSourceState) {
        case SPFolderDataSourceStateUnknown:
        case SPFolderDataSourceStateLoading:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = NSLocalizedString(@"Loading...", @"Loading...");
            [cell.accessoryView addSubview:[[[UIActivityIndicatorView alloc] init] autorelease]];
            
            break;
        
        case SPFolderDataSourceStateFailed:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = NSLocalizedString(@"Error loading contents", @"Error loading contents");
            
            break;
            
        
        case SPFolderDataSourceStateSucceeded:
        {
            SPFolderItem* item = [self.directoryContents objectAtIndex:indexPath.row];
            
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
    self.dataSourceState = SPFolderDataSourceStateLoading;
    
    SPSiteData* siteData = [SPSiteData siteData];
    
    [siteData enumerateFolder:url withHandler:^(SPSoapRequest* folderReq) 
    {
        if (folderReq.responseStatusCode != 200) {
            NSLog(@"SPSiteData::EnumerateFolder Error: %@", folderReq.responseStatusMessage);
            
            self.dataSourceState = SPFolderDataSourceStateFailed;
        } else {
            __block NSMutableArray* dir = [NSMutableArray array];
            
            [folderReq responseNodesForXPath:@"//sp:_sFPUrl" usingBlock:^(XPathResult* r)
            {
                NSLog(@"%@", r);
                
                NSString* itemUrl = [siteData.contextUrl stringByAppendingString:
                                     [folderReq responseNodeContentForXPath:[r.xpath stringByAppendingString:@"/*[1]"]]];
                
                NSString* isFolder = [folderReq responseNodeContentForXPath:[r.xpath stringByAppendingString:@"/*[3]"]];
                NSString* name = [[NSURL URLWithString:[itemUrl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]] lastPathComponent];
                
                SPFolderItem* item = [SPFolderItem itemWithName:name
                                                            url:itemUrl
                                                       isFolder:([isFolder isEqualToString:@"true"])];
                [dir addObject:item];
            }];
            
            self.directoryContents = dir;
            
            self.dataSourceState = SPFolderDataSourceStateSucceeded;
        }
    }];
}

- (NSString*) urlForItemAtPath:(NSIndexPath*)indexPath
{
    SPFolderItem* item = [self.directoryContents objectAtIndex:indexPath.row];
    return item.url;
}

@end
