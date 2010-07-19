//
//  SyncController.h
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


#import <UIKit/UIKit.h>

@class MoviesAppDelegate;
@class PersistStore;
@class PasswordEntryController;

@interface SyncController : NSObject {
	NSUserDefaults *defaults;
	MoviesAppDelegate *appController;
	PersistStore *store;
    UIAlertView *usageAlertView;
	PasswordEntryController *passwordEntry;
	
	
	UIView *overlay;
	UIProgressView *prog;
	UILabel *progLabel;

	BOOL syncLogging;
	
	BOOL syncInProgress;
	
	UIBackgroundTaskIdentifier syncTask;
}

@property (nonatomic, retain) MoviesAppDelegate *appController;
@property (nonatomic, retain) PersistStore *store;
@property (nonatomic, retain) UIAlertView *usageAlertView;
@property (nonatomic, retain) PasswordEntryController *passwordEntry;

+controllerWithAppController:(MoviesAppDelegate*)ac andPersistStore:(PersistStore*)ns;
-(void)showPasswordEntryWithMessage:(NSString*)message;

-(void)passwordWasSet:(id)newPassword;
-(void)showPasswordEntryWithMessage:(NSString*)message;
-(void)showOverlay;
-(void)changeOverlayToError:(NSString*)err andThenHide:(BOOL)doHide;
-(void)hideOverlay:(id)sender;


-(Movie*)syncLocalObject:(Movie*)local andRemoteObject:(Movie*)remote againstTruthObject:(Movie*)truth;
-(void)syncUpMovie:(Movie*)mov toServerURL:(NSString*)SyncUpPath withID:(BOOL)includeID;
-(void)syncStageOne;

-(void)sync;

-(BOOL)couldSync;

-(void)regainComposure;

@end
