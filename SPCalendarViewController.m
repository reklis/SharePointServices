//
//  SPCalendarViewController.m
//  SharePointClient
//
//  Created by Steven Fusco on 3/8/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPCalendarViewController.h"


@implementation SPCalendarViewController

- (id)initWithStyle:(UITableViewStyle)style calendarName:(NSString*)calendarName
{
    self = [super initWithStyle:style];
    if (self) {
        _calendarName = calendarName;
        
        _calendarDataSource = [[SPCalendarDataSource alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_calendarName release];
    [_calendarDataSource release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.clearsSelectionOnViewWillAppear = YES;
    
    self.tableView.dataSource = _calendarDataSource;
    
    [_calendarDataSource loadCalendarNamed:_calendarName];
    
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_calendarDataSource addObserver:self
                          forKeyPath:@"dataSourceState"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
    [self.tableView reloadData];
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
        [_calendarDataSource removeObserver:self
                                 forKeyPath:@"dataSourceState"];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self setTableView:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPCalendarItem* selectedItem = [_calendarDataSource itemAtPath:indexPath];
    NSLog(@"selected %@", selectedItem);
    [self dismissModalViewControllerAnimated:YES];
}

@end
