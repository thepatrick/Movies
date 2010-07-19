//
//  PasswordEntryController.m
//  Movies
//
//  Created by Patrick Quinn-Graham on 15/03/08.
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
#import "PasswordEntryController.h"


// the amount of vertical shift upwards keep the text field in view as the keyboard appears
#define kViewVerticalOffset					(kTextFieldHeight + kTweenMargin*5)

// the duration of the animation for the view shift
#define kVerticalOffsetAnimationDuration	0.30

@implementation PasswordEntryController

@synthesize navigationController;
@synthesize message;
@synthesize callbackObject;
@synthesize callbackSelector;

- (id)init
{
	if (self = [super init]) {
		// Initialize your view controller.
		self.title = @"PasswordEntryController";
		navigationController = [[UINavigationController alloc] initWithRootViewController:self];
	}
	return self;
}

-(void)dealloc
{
	[textFieldSecure release];
	[super dealloc];
}

- (void)loadView
{
	UIColor *backgroundColor = [UIColor colorWithRed:197.0/255.0 green:204.0/255.0 blue:211.0/255.0 alpha:1.0];

	UINavigationItem *navItem = self.navigationItem;
	
	UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveAction:)] autorelease];	
	navItem.rightBarButtonItem = saveButton;

	UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction:)] autorelease];	
	navItem.leftBarButtonItem = cancelButton;
		
	// Create a custom view hierarchy.
	UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	view.backgroundColor = backgroundColor;
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	self.view = view;
	[view release];

	self.view.autoresizesSubviews = YES;
	
	CGRect frame = CGRectMake(kLeftMargin, kTweenMargin, self.view.bounds.size.width - (kRightMargin*2), 120);
	
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
	
	label.lineBreakMode = UILineBreakModeWordWrap;    
	label.textAlignment = UITextAlignmentCenter;
    label.text = self.message;
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.textColor = [UIColor darkGrayColor];
    label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 0;
	
	[self.view addSubview:label];
	
	CGFloat yPlacement = 0;

	// create the secure text field
	yPlacement += 120 + kTweenMargin + kLabelHeight;
	frame = CGRectMake(	kLeftMargin,
						yPlacement,
						self.view.bounds.size.width - (kRightMargin*2),
						kTextFieldHeight);
    textFieldSecure = [[UITextField alloc] initWithFrame:frame];
    textFieldSecure.borderStyle = UITextBorderStyleRoundedRect;
	textFieldSecure.textColor = [UIColor blackColor];
    textFieldSecure.font = [UIFont systemFontOfSize:18.0];
    textFieldSecure.delegate = self;
    textFieldSecure.placeholder = @"<enter password>";
    textFieldSecure.backgroundColor = backgroundColor;
	textFieldSecure.returnKeyType = UIReturnKeyDone;
	textFieldSecure.keyboardType = UIKeyboardTypeDefault;	// input numbers only
	textFieldSecure.secureTextEntry = YES;
	
	textFieldSecure.clearsOnBeginEditing = YES;
	
	[self.view addSubview:textFieldSecure];
	
	[textFieldSecure addTarget:self action:@selector(passwordDidFinish:) forControlEvents:UIControlEventEditingDidEndOnExit];	
	[textFieldSecure becomeFirstResponder];
}

-(void)complete:(NSString*)back
{
	[self dismissModalViewControllerAnimated:YES];
	if(callbackObject == nil) return;
	
	NSMethodSignature *sig = [callbackObject methodSignatureForSelector:callbackSelector];
    if (!sig) return;
    NSInvocation *invoke = [NSInvocation invocationWithMethodSignature:sig];
    [invoke setSelector:callbackSelector]; 
    [invoke setArgument:&back atIndex:2]; // You want to pass the content of the element, which you don't know yet.
    [invoke invokeWithTarget:callbackObject];

}

-(void)passwordDidFinish:(UITextField*)sender
{
	[self complete:sender.text];
}

-(void)saveAction:(id)sender
{
	[self complete:textFieldSecure.text];
}

-(void)cancelAction:(id)sender
{
	[self complete:nil];
}

@end
