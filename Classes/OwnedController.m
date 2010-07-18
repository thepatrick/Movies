//
//  OwnedController.m
//  Movies
//
//  Created by Patrick Quinn-Graham on 10/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import "OwnedController.h"
#import "MovieListViewController.h"
#import "MoviesAppDelegate.h"
#import "LeftIconCell.h"

@implementation OwnedController

@synthesize appController;

- init {
	if (self = [super init]) {
	}
	return self;
}

- (void)dealloc
{
	tableView.dataSource = nil;
	tableView.delegate = nil;
	[tableView release];
	[mainMenu release];
    [super dealloc];
}

- (void)loadView {
	mainMenu = [[NSMutableArray alloc] init];
	
	[mainMenu addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"All", @"Title", @"all.png", @"Icon", @"owned == YES", @"Predicate", @"bluray = 1 OR dvd1 = 1 OR dvd2 = 1 OR dvd4 = 1", @"fakePredicate", nil]];
	[mainMenu addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Blu Ray", @"Title", @"bluray.png", @"Icon", @"bluray == YES", @"Predicate", @"bluray = 1", @"fakePredicate", nil]];		
	[mainMenu addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"DVD Region 1", @"Title", @"dvd1.png", @"Icon", @"dvd1 == YES", @"Predicate", @"dvd1 = 1", @"fakePredicate", nil]];
	[mainMenu addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"DVD Region 2", @"Title", @"dvd2.png", @"Icon", @"dvd2 == YES", @"Predicate", @"dvd2 = 1", @"fakePredicate", nil]];
	[mainMenu addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"DVD Region 4", @"Title", @"dvd4.png", @"Icon", @"dvd4 == YES", @"Predicate", @"dvd4 = 1", @"fakePredicate", nil]];
	
	tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped]; //UITableViewStylePlain
	tableView.delegate = self;
	tableView.dataSource = self;	
	self.view = tableView;
}

- (void)viewWillAppear:(BOOL)animated {
	self.title = NSLocalizedString(@"Owned", @"Owned title");
	[tableView reloadData];
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0] animated:animated scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewDidAppear:(BOOL)animated 
{
	
	if(appController.quickStartInProgress) {
		NSInteger quickStartIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"QuickStart.OwnedController"];
		if(quickStartIndex > 0) {
			[self makeSelection:(quickStartIndex - 1) animated:NO];
		} else { // we've got as far in to the quickStart process as we can, stop now.
			appController.quickStartInProgress = NO;
		}
	} else {
		// we're appearing, which means they hit back, most likely.
		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"QuickStart.OwnedController"];
	}
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [mainMenu count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	LeftIconCell *cell = nil;
//	if (availableCell != nil) {
//		// Use the existing cell if it's there
//		cell = (LeftIconCell *)availableCell;
//	} else {
		// Since the cell will be sized automatically, we can pass the zero rect for the frame
		cell = [[[LeftIconCell alloc] initWithFrame:CGRectZero] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//	}
	
	cell.values = [mainMenu objectAtIndex:indexPath.row];
	
	return cell;
}

-(void)makeSelection:(NSInteger)newIndexPath animated:(BOOL)animated
{
	NSDictionary *thisRow = [mainMenu objectAtIndex:newIndexPath];

	if(ownedMovies == nil) {
		ownedMovies = [[MovieListViewController alloc] init];
		ownedMovies.appController = self.appController;
	}

	ownedMovies.title = [[thisRow valueForKey:@"Title"] stringByAppendingString:@" Owned Movies"];
	ownedMovies.fakePredicate = [thisRow valueForKey:@"fakePredicate"];//@"bluray = 0 AND dvd1 = 0 AND dvd2 = 0 and dvd4 = 0"
//	ownedMovies.predicate = [NSPredicate predicateWithFormat:];
	ownedMovies.sortMode = MovieListViewSortTitle;
	
	[[self navigationController] pushViewController:ownedMovies animated:animated];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {

	[self makeSelection:newIndexPath.row animated:YES];
	[[NSUserDefaults standardUserDefaults] setInteger:(newIndexPath.row + 1) forKey:@"QuickStart.OwnedController"];
	

}

@end
