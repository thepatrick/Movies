//
//  MoviesAppDelegate.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 09/03/08.
//  Copyright Patrick Quinn-Graham 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PersistStore;
@class SyncController;

@interface MoviesAppDelegate : NSObject  <UIApplicationDelegate> {
    UIWindow *window;
	UINavigationController *navigationController;
	
//	NSMutableArray *masterList;
	UIAlertView *terminatingAlert;
	
	SyncController *sync;	
	PersistStore *store;
	
	BOOL quickStartInProgress;
}

@property (nonatomic, retain) UIWindow *window;
//@property (nonatomic, retain) NSMutableArray *masterList;
@property (nonatomic, retain) PersistStore *store;
@property (nonatomic, retain) SyncController *sync;
@property (nonatomic, assign) UINavigationController *navigationController;

@property (nonatomic, assign) BOOL quickStartInProgress;

- (NSArray *)sortedMovies:(NSArray *)movies withKey:(NSString*)sortKey andAsecndingOrder:(BOOL)ascendingSort;
-(void)masterListUpdated;

- (NSString*)getDocumentsDirectory;
-(void)setupLocalDB;


@end
