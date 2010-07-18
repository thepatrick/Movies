//
//  DetailViewController
//  Blargh
//
//  Created by Patrick Quinn-Graham on 09/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"


@implementation DetailViewController

@synthesize detailItem;
@synthesize tableView;

- (void)loadView
{
	// Create a grouped table view to display the item
    tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];
	tableView.delegate = self;
	tableView.dataSource = self;	
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.view = tableView;
}

- (void)dealloc
{
	[super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {
    // Update the view with current data before it is displayed; scroll to the top of the list
	self.title = [(NSDictionary *)detailItem objectForKey:@"Title"];
	[tableView reloadData];
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// As many rows as there are characters//
//	return [[detailItem objectForKey:@"mainCharacters"] count];
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
//	UISimpleTableViewCell *cell = nil;
//	if (availableCell != nil) {
		// Use the existing cell if it's there
//		cell = (UISimpleTableViewCell *)availableCell;
	//} else {
		// We can use CGRectZero because the table view will lay out the cell
	//}
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
	
	NSLog(@"tableView:... %@", detailItem);
	// Set the value in the cell
	cell.text = [detailItem objectForKey:@"URL"];
	return cell;

}


// Provide a title for the section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"URLs";
	}
	return nil;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// In this case we don't want the user to be able to select individual items, so return nil
	return nil;
}

@end
