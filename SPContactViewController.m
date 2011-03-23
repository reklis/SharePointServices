//
//  SPContactViewController.m
//  SharePointClient
//
//  Created by Steven Fusco on 3/9/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPContactViewController.h"


@implementation SPContactViewController

@synthesize delegate;

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
    self.tableView.sectionIndexMinimumDisplayRowCount = 25;
    
    self.contactDataSource = [[[SPContactDataSource alloc] init] autorelease];
    self.tableView.dataSource = self.contactDataSource;
    
    [self.contactDataSource loadContactsListNamed:self.contactListName];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.contactDataSource addObserver:self
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

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    @try {
        [self.contactDataSource removeObserver:self
                                    forKeyPath:@"dataSourceState"];

    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

- (void)viewDidUnload
{
    [self setContactListName:nil];
    [self setContactDataSource:nil];
    [self setTableView:nil];
    
    [super viewDidUnload];
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
    if ([delegate respondsToSelector:@selector(contactViewController:didSelectContact:)]) {
        SPContact* c = [self.contactDataSource itemAtPath:indexPath];
        [delegate contactViewController:self didSelectContact:c];
    }
}

@end
