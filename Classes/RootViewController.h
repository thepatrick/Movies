//
//  RootViewController.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 09/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@class MoviesAppDelegate;
@class OwnedController;
@class MovieListViewController;
@class MovieViewController;

@interface RootViewController :  UIViewController  <UITableViewDelegate, UITableViewDataSource> {
	UITableView *tableView;
	DetailViewController *detailViewController;
	MoviesAppDelegate *appController;
	
	NSMutableArray *mainMenu;
	NSMutableArray *ownedMenu;
	
	//OwnedController *ownedMenu;
	MovieListViewController *allMovies;
	MovieViewController *movieView;
	
	UIToolbar *toolbar;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, assign) MoviesAppDelegate *appController;

-(void)masterListUpdated;
-(void)makeSelection:(NSInteger)newIndexPath animated:(BOOL)animated;
-(void)updateToolbar;

@end
