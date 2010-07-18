//
//  SyncController.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 15/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
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
