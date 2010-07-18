//
//  MovieThoughtsController.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 26/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Movie;

@interface MovieThoughtsController : UIViewController <UITextViewDelegate> {
	UITextView *textView;
	
	Movie *theMovie;
	
	NSObject *callbackObject;
	SEL callbackSelector;
}

@property (nonatomic, retain) Movie* theMovie;
@property (nonatomic, assign) NSObject *callbackObject;
@property (nonatomic, assign) SEL callbackSelector;

@end
