//
//  MovieListViewController.m
//  Movies
//
//  Created by Patrick Quinn-Graham on 11/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import "MovieListViewController.h"
#import "MoviesAppDelegate.h"
#import "Movie.h"
#import "MovieListCell.h"
#import "MovieViewController.h"
#import "PersistStore.h"

@implementation MovieListViewController

@synthesize movieList;
@synthesize tableView;
@synthesize sortMode;
@synthesize appController;
@synthesize movieView;
@synthesize fakePredicate;
//@synthesize predicate;

- (void)loadView
{
	UIView *m = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	
	
	CGRect fr = m.bounds;
	fr.size.height = 44;
	
	sb = [[UISearchBar alloc] initWithFrame:fr];
	// don't get in the way of user typing in any way!
	sb.autocorrectionType = UITextAutocorrectionTypeNo;
	sb.autocapitalizationType = UITextAutocapitalizationTypeNone;
	sb.showsCancelButton = NO;
	sb.delegate = self;
	
	sb.placeholder = @"Search this list";
	
	[m addSubview:[sb autorelease]];
	fr = m.bounds;
	fr.size.height = fr.size.height - 128;
	fr.origin.y = 44;
	
	// Create a grouped table view to display the item
    tableView = [[UITableView alloc] initWithFrame:fr style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = self;	
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	[m addSubview:tableView];
	
	
	
	
	
	CGRect f = CGRectMake(0, 376, 320, 40);
	toolbar = [[[UIToolbar alloc] initWithFrame:f] autorelease];
	[m addSubview:toolbar];
	
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
	
	
	self.view = [m autorelease];
}

- (void)dealloc
{
	[super dealloc];
}

-(void)viewDidDisappear:(BOOL)animated
{
	if([sb isFirstResponder])
		[sb resignFirstResponder];	
}

- (void)viewWillAppear:(BOOL)animated 
{
	NSString *sortKey;
	BOOL ascending = YES;
	switch (self.sortMode) {
		case MovieListViewSortScore:
			sortKey = @"score";
			ascending = NO;
			break;
		case MovieListViewSortSeenon:
			sortKey = @"seenon";			
			ascending = NO;
			break;
		default:
			sortKey = @"title";
			break;
	}
	
	self.movieList = [appController.store getMoviesWithConditions:self.fakePredicate 
								andSort:[sortKey stringByAppendingString:(ascending ? @" ASC" : @" DESC")]];
	
	[tableView reloadData];
	if([self tableView:self.tableView numberOfRowsInSection:0] > 0) {
		//[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	}
	[tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0] animated:animated scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewDidAppear:(BOOL)animated 
{
	if(appController.quickStartInProgress) {
		NSInteger quickStartIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"QuickStart.MovieListViewController"];
		if(quickStartIndex > 0) {
			[self makeSelection:(quickStartIndex - 1) animated:NO];
		} else { // we've got as far in to the quickStart process as we can, stop now.
			appController.quickStartInProgress = NO;
		}
	} else {
		// we're appearing, which means they hit back, most likely.
		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"QuickStart.MovieListViewController"];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	// As many rows as there are characters//
//	return [[movieList objectForKey:@"mainCharacters"] count];
	return [movieList count];
}

- (UITableViewCell *)tableView:(UITableView *)whichTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
//	MovieListCell *cell = nil;
//	cell = [[[MovieListCell alloc] initWithFrame:CGRectZero] autorelease];
	
	MovieListCell *cell = (MovieListCell*)[whichTableView dequeueReusableCellWithIdentifier:@"MovieListViewCell"];
    if (cell == nil) {
        cell = [[[MovieListCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MovieListViewCell"] autorelease];
    }
	Movie *m = [movieList objectAtIndex:indexPath.row];
	[m hydrate];	
	cell.values = m;
	return cell;
}

-(void)masterListUpdated
{
	[self viewWillAppear:YES];
}
-(void)makeSelection:(NSInteger)newIndexPath animated:(BOOL)animated
{
	if(movieView == nil) {
		movieView = [[MovieViewController alloc] init];
		movieView.appController = self.appController;
	}
	
	movieView.theMovie = [movieList objectAtIndex:newIndexPath];

	[[self navigationController] pushViewController:movieView animated:animated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	if ([sb isFirstResponder])
		[sb resignFirstResponder];
	
	[self makeSelection:newIndexPath.row animated:YES];
	[[NSUserDefaults standardUserDefaults] setInteger:(newIndexPath.row + 1) forKey:@"QuickStart.MovieListViewController"];
}

-(void)updateMovieListWithPredicate:(NSString*)predicate
{
	
	NSString *sortKey;
	BOOL ascending = YES;
	switch (self.sortMode) {
		case MovieListViewSortScore:
			sortKey = @"score";
			ascending = NO;
			break;
		case MovieListViewSortSeenon:
			sortKey = @"seenon";			
			ascending = NO;
			break;
		default:
			sortKey = @"title";
			break;
	}
	
	self.movieList = [appController.store getMoviesWithConditions:predicate 
					  andSort:[sortKey stringByAppendingString:(ascending ? @" ASC" : @" DESC")]];
}


#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	// only show the status bar's cancel button while in edit mode
	searchBar.showsCancelButton = YES;	
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[self updateMovieListWithPredicate:[self.fakePredicate stringByAppendingFormat:@" AND title LIKE '%%%@%%'", searchText]];	
	[tableView reloadData];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self updateMovieListWithPredicate:self.fakePredicate];	
	
	[tableView reloadData];
	
	[searchBar resignFirstResponder];
	searchBar.text = @"";
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

#pragma mark Toolbar Actions

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

@end


