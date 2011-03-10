//
//  SPContactViewController.m
//  SharePointClient
//
//  Created by Steven Fusco on 3/9/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPContactViewController.h"


@implementation SPContactViewController

@synthesize contactDataSource=_contactDataSource;
@synthesize contactListName=_contactListName;

- (id)initWithStyle:(UITableViewStyle)style 
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_contactListName release];
    [_contactDataSource release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark UITableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = YES;
 
    self.contactDataSource = [[[SPContactDataSource alloc] init] autorelease];
    self.tableView.dataSource = self.contactDataSource;
    
    [self.contactDataSource addObserver:self
                             forKeyPath:@"dataSourceState"
                                options:NSKeyValueObservingOptionNew
                                context:NULL];
    
    [self.contactDataSource loadContactsListNamed:self.contactListName];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //if ([super respondsToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)]) {
    //    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    //}
    
    if ([keyPath isEqualToString:@"dataSourceState"]) {
        [self.tableView reloadData];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self.contactDataSource removeObserver:self
                                forKeyPath:@"dataSourceState"];
    
    [self setContactListName:nil];
    [self setContactDataSource:nil];
    [self setTableView:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end