//
//  MovieView.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 13/03/08.
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
