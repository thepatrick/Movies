//
//  PasswordEntryController.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 15/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PasswordEntryController : UIViewController <UITextFieldDelegate, UITextFieldDelegate> {


	UITextField *textFieldSecure;
	UIResponder *lastTrackedFirstResponder;
	UINavigationController *navigationController;
	NSString *message;
	
	NSObject *callbackObject;
	SEL callbackSelector;
}

@property (nonatomic, assign) UINavigationController *navigationController;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, assign) NSObject *callbackObject;
@property (nonatomic, assign) SEL callbackSelector;


@end
