//
//  MovieThoughtsController.m
//  Movies
//
//  Created by Patrick Quinn-Graham on 26/03/08.
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


#import "Constants.h"
#import "PersistStore.h"
#import "Movie.h"
#import "MovieThoughtsController.h"


@implementation MovieThoughtsController

@synthesize theMovie;
@synthesize callbackObject;
@synthesize callbackSelector;

- (id)init
{
	if (self = [super init]) {
		// Initialize your view controller.
		self.title = @"";
	}
	return self;
}


- (void)loadView
{
	UIColor *backgroundColor = [UIColor colorWithRed:197.0/255.0 green:204.0/255.0 blue:211.0/255.0 alpha:1.0];
	
	// Create a custom view hierarchy.
	UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	view.backgroundColor = backgroundColor;
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	self.view = view;
	[view release];

	self.view.autoresizesSubviews = YES;
	
}

- (void)viewWillAppear:(BOOL)animated
{
	if(theMovie == nil) {
		return;
	}
	[theMovie hydrate];
	
	if(textView != nil) [textView release];
	
	CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
	
	textView = [[UITextView alloc] initWithFrame:frame];
	textView.textColor = [UIColor blackColor];
	textView.font = [UIFont systemFontOfSize:16.0];
	textView.backgroundColor = [UIColor whiteColor];
	textView.delegate = self;
	textView.returnKeyType = UIReturnKeyDefault;
	textView.keyboardType = UIKeyboardTypeDefault;
	[self.view addSubview:textView];	
	
	textView.text = (theMovie.thoughts != nil && ![theMovie.thoughts isEqualToString:@"(null)"]) ? theMovie.thoughts : @"";
}

-(void)viewDidAppear:(BOOL)animated
{
	self.navigationItem.rightBarButtonItem = nil;	
}

- (void)textViewDidBeginEditing:(UITextView *)localTextView
{
	UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveAction:)] autorelease];	
	self.navigationItem.rightBarButtonItem = saveButton;
	
	CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 200);
	localTextView.frame = frame;
}

- (void)saveAction:(id)sender
{
	[textView resignFirstResponder];
	self.navigationItem.rightBarButtonItem = nil;	
	theMovie.thoughts = textView.text;	
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)dealloc
{
	[textView release];
	[super dealloc];
}


@end
