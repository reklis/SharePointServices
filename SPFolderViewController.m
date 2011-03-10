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
@synthesize directoryUrl;
@synthesize folderDataSource;

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
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    self.folderDataSource = [SPFolderDataSource folderDataSourceForUrl:self.directoryUrl];

    self.tableView.dataSource = self.folderDataSource;

    [self.folderDataSource addObserver:self
                            forKeyPath:@"dataSourceState"
                               options:NSKeyValueObservingOptionNew
                               context:NULL];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"dataSourceState"]) {
        [self.tableView reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = NSLocalizedString(@"Loading...",@"Loading...");
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
     When a row is selected, set the detail view controller's detail item to the item associated with the selected row.
     */
    
    SPFolderItem* item = [self.folderDataSource itemAtPath:indexPath];
    
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


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    
    [self.folderDataSource removeObserver:self
                               forKeyPath:@"dataSourceState"];
}


- (void)dealloc {
    [folderDataSource release];
    [directoryUrl release];
    
    [super dealloc];
}


@end

