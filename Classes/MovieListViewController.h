//
//  MovieListViewController.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 11/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MoviesAppDelegate;
@class MovieViewController;

enum MovieListViewSort {
	MovieListViewSortScore,
	MovieListViewSortTitle,
	MovieListViewSortSeenon
} MovieListViewSort;

@interface MovieListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
	NSArray *movieList;
	UITableView *tableView;
	UISearchBar *sb;
	UIToolbar *toolbar;
	NSInteger sortMode;
	MoviesAppDelegate *appController;
	MovieViewController *movieView;
	
	NSString *fakePredicate;
	
//	NSPredicate *predicate;
}

@property (nonatomic, retain) NSArray *movieList;
@property (nonatomic, retain) UITableView *tableView;
//@property (nonatomic, retain) NSPredicate *predicate;
@property (nonatomic, retain) NSString *fakePredicate;
@property (nonatomic, retain) MoviesAppDelegate *appController;

@property (nonatomic, assign) NSInteger sortMode;
@property (nonatomic, assign) MovieViewController *movieView;


-(void)makeSelection:(NSInteger)newIndexPath animated:(BOOL)animated;

@end
