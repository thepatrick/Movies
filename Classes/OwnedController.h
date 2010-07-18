//
//  OwnedController.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 10/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MoviesAppDelegate;
@class MovieListViewController;

@interface OwnedController :  UIViewController  <UITableViewDelegate, UITableViewDataSource> {
	UITableView *tableView;
	NSMutableArray *mainMenu;
	MoviesAppDelegate *appController;
	
	MovieListViewController *ownedMovies;
}

@property (nonatomic, assign) MoviesAppDelegate *appController;

-(void)makeSelection:(NSInteger)newIndexPath animated:(BOOL)animated;

@end
