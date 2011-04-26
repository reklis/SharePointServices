//
//  SPFolderViewController.m
//  SharePointClient
//
//  Created by Steven Fusco on 3/4/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPFolderViewController.h"


@implementation SPFolderViewController

@synthesize delegate;

@synthesize directoryUrl = _directoryUrl;
@synthesize directoryFilter = _directoryFilter;
@synthesize folderDataSource = _folderDataSource;
@synthesize rootUrl = _rootUrl;

#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style directoryUrl:(NSString*)url
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        self.directoryUrl = url;
    }
    return self;
}


#pragma mark UITableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    self.clearsSelectionOnViewWillAppear = YES;
    
    self.folderDataSource = [SPFolderDataSource folderDataSourceForUrl:self.directoryUrl
                                                                filter:self.directoryFilter
                                                              withRoot:self.rootUrl];

    self.tableView.dataSource = self.folderDataSource;
    self.clearsSelectionOnViewWillAppear = YES;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.folderDataSource.dataSourceState == SPDataSourceStateSucceeded) {
        float itemCount = self.folderDataSource.directoryContents.count;
        if (0 == itemCount) {
            itemCount += 1.0;
        }
        float height = fminf(44*itemCount, 440);
        self.contentSizeForViewInPopover = CGSizeMake(320.0, height);
    }
    
    if ([keyPath isEqualToString:@"dataSourceState"]) {
        [self.tableView reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.folderDataSource addDataSourceObserver:self];
    [self.folderDataSource refresh];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.folderDataSource removeDataSourceObserver:self];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [self.folderDataSource tableView:aTableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.folderDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPFolderItem* item = [self.folderDataSource itemAtPath:indexPath];
    
    if (item) {
        return indexPath;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPFolderItem* item = [self.folderDataSource itemAtPath:indexPath];
    
    if (item) {
        if ([self.delegate respondsToSelector:@selector(folderViewController:didSelectItem:)]) {
            [self.delegate folderViewController:self didSelectItem:item];
        }
        
        if (item.isFolder) {
            SPFolderViewController* nestedController = [[[SPFolderViewController alloc] init] autorelease];
            nestedController.directoryUrl = item.url;
            nestedController.delegate = self.delegate;
            nestedController.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
            nestedController.title = [[NSURL URLWithString:[item.url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]] lastPathComponent];
            
            [self.navigationController pushViewController:nestedController animated:YES];
        }
    }
}

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [self setDirectoryFilter:nil];
    [self setDirectoryUrl:nil];
    [self setRootUrl:nil];
    [self setFolderDataSource:nil];
    
    [super viewDidUnload];
}


- (void)dealloc {
    [_rootUrl release];
    [_folderDataSource release];
    [_directoryUrl release];
    [_directoryFilter release];
    [super dealloc];
}


@end

