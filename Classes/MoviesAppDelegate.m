//
//  MoviesAppDelegate.m
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


#import "PersistStore.h"
#import "RootViewController.h"
#import "SyncController.h"
#import "MoviesAppDelegate.h"
#import "Movie.h"

@implementation MoviesAppDelegate

@synthesize window;
@synthesize store;
@synthesize sync;
@synthesize navigationController;
@synthesize quickStartInProgress;

- (void)applicationDidFinishLaunching:(UIApplication *)application {

	[self setupLocalDB];	
	self.sync = [SyncController controllerWithAppController:self andPersistStore:store];
	
	self.quickStartInProgress = NO;//YES; we have to turn this off for now.
	
    // Create window
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
	RootViewController *rootViewController = [[RootViewController alloc] init];
	rootViewController.appController = self;
	
	navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	[rootViewController release];
		
    // Show the window with table view
	[window addSubview:[navigationController view]];
	
    [window makeKeyAndVisible];
	
	[self performSelector:@selector(bootTimeSyncCrud) withObject:self afterDelay:1];
}

-(void)bootTimeSyncCrud
{
	[self masterListUpdated];
	[sync sync];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[store tellCacheToDehydrate];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	NSLog(@"applicationDidEnterBackground. Because we're a good little application we'll save all the objects and reduce ram usage, less we anger the SDK gods.");
	[store tellCacheToSave];
	[store tellCacheToDehydrate];
	NSLog(@"Goodbye!");	
}

- (void)applicationWillTerminate:(UIApplication *)application {
//	NSLog(@"applicationWillTerminate. Because we're a good little application, and we like our users (well, user), we'll save all the objects and quit, less we anger the SDK gods.");
	[store tellCacheToSave];
//	NSLog(@"Goodbye.");	
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSLog(@"We are back in business!");
}

- (void)dealloc {
	[navigationController release];
	[window release];
	[store release];
	[sync release];
	[super dealloc];
}

- (NSArray *)sortedMovies:(NSArray *)movies withKey:(NSString*)sortKey andAsecndingOrder:(BOOL)ascendingSort
{        
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascendingSort] autorelease];
	[movies makeObjectsPerformSelector:@selector(hydrate)];
	return [movies sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}


-(void)masterListUpdated
{
	[[navigationController viewControllers] makeObjectsPerformSelector:@selector(masterListUpdated)];
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (NSString*)getDocumentsDirectory 
{
    // First, test for existence.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	
    #pragma mark Begin Workaround: create application "Documents" directory if needed
    // Workaround for Beta issue where Documents directory is not created during install.
    BOOL exists = [fileManager fileExistsAtPath:documentsDirectory];
    if (!exists) {
        BOOL success = [fileManager createDirectoryAtPath:documentsDirectory attributes:nil];
        if (!success) {
            NSAssert(0, @"Failed to create Documents directory.");
        }
    }
    #pragma mark End Workaround
	
	return documentsDirectory;
}

-(void)setupLocalDB
{
	self.store = [PersistStore storeWithFile:[[self getDocumentsDirectory] stringByAppendingPathComponent:@"LocalMovies.db"]];
}

@end
