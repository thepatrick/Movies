//
//  RootViewController
//  Movies
//
//  Created by Patrick Quinn-Graham on 09/03/08.
//  Copyright (c) 2008-2010 Patrick Quinn-Graham
//  
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


#import "RootViewController.h"
#import "MoviesAppDelegate.h"
#import "DetailViewController.h"
#import "OwnedController.h"
#import "MovieListViewController.h"
#import "MovieViewController.h"
#import "Movie.h"
#import "SyncController.h"
#import "LeftIconCell.h"

@implementation RootViewController

@synthesize appController;
@synthesize tableView;

- init {
	if (self = [super init]) {
		self.title = NSLocalizedString(@"Movies", @"Main title");
	}
	return self;
}

- (void)dealloc
{
	tableView.dataSource = nil;
	tableView.delegate = nil;
	[tableView release];
	[mainMenu release];
	[ownedMenu release];
	[toolbar release];
	[self.view release];
    [super dealloc];
}

- (void)loadView {
	
	mainMenu = [[NSMutableArray alloc] init];
	[mainMenu addObject:@"Should Own"];
	[mainMenu addObject:@"All"];

	ownedMenu = [[NSMutableArray alloc] init];
	[ownedMenu addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"All", @"Title", @"all.png", @"Icon", @"owned == YES", @"Predicate", @"(bluray = 1 OR dvd1 = 1 OR dvd2 = 1 OR dvd4 = 1)", @"fakePredicate", nil]];
	[ownedMenu addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Blu Ray", @"Title", @"bluray.png", @"Icon", @"bluray == YES", @"Predicate", @"bluray = 1", @"fakePredicate", nil]];		
	[ownedMenu addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"DVD Region 1", @"Title", @"dvd1.png", @"Icon", @"dvd1 == YES", @"Predicate", @"dvd1 = 1", @"fakePredicate", nil]];
	[ownedMenu addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"DVD Region 2", @"Title", @"dvd2.png", @"Icon", @"dvd2 == YES", @"Predicate", @"dvd2 = 1", @"fakePredicate", nil]];
	[ownedMenu addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"DVD Region 4", @"Title", @"dvd4.png", @"Icon", @"dvd4 == YES", @"Predicate", @"dvd4 = 1", @"fakePredicate", nil]];	
	
	UIView *m = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	
	CGRect fr = m.bounds;
	fr.size.height = fr.size.height - 84;
	
	tableView = [[UITableView alloc] initWithFrame:fr style:UITableViewStyleGrouped];
	//tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	tableView.delegate = self;
	tableView.dataSource = self;	
	[tableView reloadData];	
	[m addSubview:tableView];
	
	CGRect f = CGRectMake(0, 376, 320, 40);
	toolbar = [[[UIToolbar alloc] initWithFrame:f] autorelease];
	[m addSubview:toolbar];
	
	[self updateToolbar];
	
	self.view = m;
	[m release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToolbar) 
												 name:UIApplicationWillEnterForegroundNotification 
											   object:nil];
}

-(void)updateToolbar {
	NSLog(@"Updating the RootViewController toolbar");
	UIBarButtonItem *b;
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:4];
	
	b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(toolbarLiveSite)];
	[arr addObject:[b autorelease]];
	
	b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[arr addObject:[b autorelease]];
	
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"SyncEnabled"]) {
		
		b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(toolbarSync)];
		[arr addObject:[b autorelease]];
		
		b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[arr addObject:[b autorelease]];		
		
	}
	
	b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toolbarAddNew)];
	[arr addObject:[b autorelease]];

	[toolbar setItems:arr];
}

-(void)doMagic
{
	NSLog(@"doMagic!");
}

-(void)viewWillDisappear:(BOOL)animated {
	//[toolbar setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    // Update the view with current data before it is displayed; scroll to the top of the list
	[tableView reloadData];
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];	
	[tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0] animated:animated scrollPosition:UITableViewScrollPositionNone];

}

- (void)viewDidAppear:(BOOL)animated 
{
	//[toolbar setHidden:NO];	
	if(appController.quickStartInProgress) {
		NSInteger quickStartIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"QuickStart.RootViewController"];
		if(quickStartIndex > 0) {
			[self makeSelection:(quickStartIndex - 1) animated:NO];
		} else { // we've got as far in to the quickStart process as we can, stop now.
			appController.quickStartInProgress = NO;
		}
	} else {
		// we're appearing, which means they hit back, most likely.
		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"QuickStart.RootViewController"];
	}
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0)
		return [mainMenu count];
	if(section == 1)
		return [ownedMenu count];
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	if(section == 0)
		return @"";
	if(section == 1)
		return @"Owned";
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	if(indexPath.section == 0) {		
		UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = [mainMenu objectAtIndex:indexPath.row];
		return cell;
	}
	
	if(indexPath.section == 1) {
		LeftIconCell *cell = [[[LeftIconCell alloc] initWithFrame:CGRectZero] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.values = [ownedMenu objectAtIndex:indexPath.row];
		return cell;
	}
	
	return nil;
}

-(void)makeOwnedSelection:(NSInteger)newIndexPath animated:(BOOL)animated
{
	NSDictionary *thisRow = [ownedMenu objectAtIndex:newIndexPath];
	
	if(allMovies == nil) {
		allMovies = [[MovieListViewController alloc] init];
		allMovies.appController = self.appController;
	}
	
	allMovies.title = [[thisRow valueForKey:@"Title"] stringByAppendingString:@" Owned Movies"];
	allMovies.fakePredicate = [thisRow valueForKey:@"fakePredicate"];
	allMovies.sortMode = MovieListViewSortTitle;
	
	[[self navigationController] pushViewController:allMovies animated:animated];
}

-(void)makeSelection:(NSInteger)newIndexPath animated:(BOOL)animated
{
	if(newIndexPath == 0) { // Should Own
		if(allMovies == nil) {
			allMovies = [[MovieListViewController alloc] init];
			allMovies.appController = self.appController;
		}
		allMovies.fakePredicate = @"bluray = 0 AND dvd1 = 0 AND dvd2 = 0 and dvd4 = 0";
		allMovies.sortMode = MovieListViewSortScore;
		allMovies.title = @"Should Own";

		[[self navigationController] pushViewController:allMovies animated:animated];
	}
	if(newIndexPath == 1) { // Should Own
		if(allMovies == nil) {
			allMovies = [[MovieListViewController alloc] init];
			allMovies.appController = self.appController;
		}
		allMovies.fakePredicate = @"1 = 1";
		allMovies.sortMode = MovieListViewSortTitle;
		allMovies.title = @"All Movies";
		[[self navigationController] pushViewController:allMovies animated:animated];
	}
}

-(void)toolbarAddNew
{
	Movie *newMovie = [Movie movie];
	newMovie.store = appController.store;
	newMovie.dbId = nil;
	if(movieView == nil) {
		movieView = [[MovieViewController alloc] init];
		movieView.appController = self.appController;
	}
	movieView.newMode = YES;
	newMovie.seenOn = [NSDate date];
	movieView.theMovie = newMovie;
	[[self navigationController] pushViewController:movieView animated:YES];	
}

- (void)toolbarLiveSite
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://patrick.geek.nz/movies"]];	
}

- (void)toolbarSync
{
	[appController.sync sync];	
}

- (void)tableView:(UITableView *)localTableView selectionDidChangeToIndexPath:(NSIndexPath *)newIndexPath fromIndexPath:(NSIndexPath *)oldIndexPath 
{
	if(newIndexPath.section == 0) {
		[self makeSelection:newIndexPath.row animated:YES];
//		[[NSUserDefaults standardUserDefaults] setInteger:(newIndexPath.row + 1) forKey:@"QuickStart.RootViewController"];		
	}
}

- (void)tableView:(UITableView *)myTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	if(newIndexPath.section == 0) {
		[self makeSelection:newIndexPath.row animated:YES];
	} else if(newIndexPath.section == 1) {
		[self makeOwnedSelection:newIndexPath.row animated:YES];
	}
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}

-(void)masterListUpdated
{
	return; // doesn't affect us.
}

@end
