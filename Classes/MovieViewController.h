//
//  MovieView.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 13/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MoviesAppDelegate;
@class MovieThoughtsController;
@class Movie;

@interface MovieViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	UITableView *tableView;
	Movie *theMovie;
	MoviesAppDelegate *appController;
	MovieThoughtsController *thoughtsController;
	
	BOOL newMode;
}


@property (nonatomic, assign) BOOL newMode;
@property (nonatomic, retain) Movie *theMovie;

@property (nonatomic, assign) MoviesAppDelegate *appController;

-(UITableViewCell *)movieViewCellForTitle:(NSString*)title andValue:(NSString*)value withAvailableCell:(UITableViewCell *)availableCell;
-(UITableViewCell *)switchCellForTitle:(NSString*)title andValue:(BOOL)value andChangedSelector:(SEL)action withAvailableCell:(UITableViewCell *)availableCell;
-(UITableViewCell *)textfieldCellForTitle:(NSString*)title andValue:(NSString*)value andChangedSelector:(SEL)action andKeyboardType:(UIKeyboardType)keyboard withAvailableCell:(UITableViewCell *)availableCell;

@end
