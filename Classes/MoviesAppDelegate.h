//
//  MoviesAppDelegate.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 09/03/08.
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
