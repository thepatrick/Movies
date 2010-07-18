//
//  SyncController.m
//  Movies
//
//  Created by Patrick Quinn-Graham on 15/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import "MoviesAppDelegate.h"
#import "PersistStore.h"
#import "SyncController.h"
#import "Movie.h"
#import "XMLDocument.h"
#import "XMLElement.h"
#import "XMLReaderSAX.h"
#import "PasswordEntryController.h"
#import "KeychainBridge.h"
#import "NSStringSyncAdditions.h"


@implementation SyncController

@synthesize appController;
@synthesize store;
@synthesize usageAlertView;
@synthesize passwordEntry;

+controllerWithAppController:(MoviesAppDelegate*)ac andPersistStore:(PersistStore*)ps
{
	SyncController *sc = [[[SyncController alloc] init] autorelease];
	sc.appController = ac;
	sc.store = ps;
	return sc;
}

-init
{
	if(self = [super init]) {
		defaults = [NSUserDefaults standardUserDefaults];		
		NSMutableDictionary *dd = [NSMutableDictionary dictionaryWithObject:@"NO" forKey:@"SyncEnabled"];
		[dd setValue:@"NO" forKey:@"SyncUseSSL"];
		[dd setValue:@"NO" forKey:@"ExtraLogging"];
		[dd setValue:@"NO" forKey:@"BurninateQuickStart"];
		[dd setValue:@"NO" forKey:@"BurninateTheDatabase"];
		[defaults registerDefaults:dd];
		syncLogging = [[NSUserDefaults standardUserDefaults] boolForKey:@"ExtraLogging"];
		syncInProgress = NO;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(regainComposure) 
													 name:UIApplicationWillEnterForegroundNotification 
												   object:nil];
	}
	return self;
}

-(void)dealloc
{
	[store release];
	[appController release];
	[super dealloc];
}

- (void)modalViewCancel:(id)modalView
{
    [modalView release];
}

- (void)modalView:(id)modalView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [modalView release];
}

-(void)passwordWasSet:(id)newPassword
{
	if(newPassword == nil) {
		NSLog(@"They cancelled password set, disable sync for now.");
		[defaults setBool:NO forKey:@"SyncEnabled"];
		return;
	}	
	
	NSString *server = [defaults valueForKey:@"SyncServer"];
	NSString *user = [defaults valueForKey:@"SyncUser"];
	
	NSString *keychainUser = [user stringByAppendingFormat:@"@%@", server];
	
	if([KeychainBridge checkForExistanceOfKeychainItem:server withItemKind:@"Password" forUsername:keychainUser]) {
		if(![KeychainBridge modifyKeychainItem:server withItemKind:@"Password" forUsername:keychainUser withNewPassword:newPassword]) {
			NSLog(@"Failed to modify item... not so good.");		
		}
	} else {
		if(![KeychainBridge addKeychainItem:server withItemKind:@"Password" forUsername:keychainUser withPassword:newPassword]) {
			NSLog(@"Failed to add item... not so good.");
		}
	}
	
	[self performSelectorOnMainThread:@selector(sync) withObject:nil waitUntilDone:NO];
	
}

-(void)showPasswordEntryWithMessage:(NSString*)message
{
		self.passwordEntry = [[[PasswordEntryController alloc] init] autorelease];	
		self.passwordEntry.title = @"Sync Password";
		self.passwordEntry.message =  message;
		self.passwordEntry.callbackObject = self;
		self.passwordEntry.callbackSelector = @selector(passwordWasSet:);
		
		[appController.navigationController presentModalViewController:self.passwordEntry.navigationController animated:YES];
}

-(void)showOverlay
{
	//self.appController.window get bounds
	CGRect screen = [appController.window bounds];
	CGRect frame = CGRectMake(0, (screen.size.height - 100), screen.size.width, 100);
	overlay = [[UIView alloc] initWithFrame:frame];
	overlay.backgroundColor = [UIColor blackColor];
	overlay.alpha = 0.8;	
	
	[self.appController.window addSubview:overlay];
	
	frame = CGRectMake(20, 25, overlay.bounds.size.width - 20 * 2.0, 20.0);
	progLabel = [[UILabel alloc] initWithFrame:frame];
	progLabel.text = @"Synchronising...";
	progLabel.backgroundColor = [UIColor clearColor];
	progLabel.textAlignment = UITextAlignmentCenter;
    progLabel.font = [UIFont boldSystemFontOfSize:14.0];
    progLabel.textColor = [UIColor whiteColor];
	
	[overlay addSubview:progLabel];
	[progLabel release];
	
	frame = CGRectMake(20, 55, overlay.bounds.size.width - 20 * 2.0, 50.0);
	prog = [[UIProgressView alloc] initWithFrame:frame];
	prog.progressViewStyle = UIProgressViewStyleBar;
	//prog.progress = 0.0;
	[overlay addSubview:prog];
	[prog release];
}

-(void)changeOverlayToError:(NSString*)err andThenHide:(BOOL)doHide
{
//	[progLabel performSelectorOnMainThread:@selector(setText:) withObject:err waitUntilDone:NO];
	if(doHide) {
		[self hideOverlay:nil];
	}
}

-(void)setProgress:(NSNumber*)progress
{
	///prog.progress = [progress floatValue];
}

-(void)hideOverlay:(id)sender
{
	[UIView beginAnimations:@"removeProgOverlay" context:nil];
	CGRect window = [appController.window bounds];
	overlay.frame = CGRectMake(0, window.size.height, window.size.width, 200);
	overlay.alpha = 0;
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationStopped:afterFinishing:withContext:)];
	[UIView commitAnimations];
}

-(void)animationStopped:(NSString*)animationID afterFinishing:(BOOL)finished withContext:(void*)context
{
	if(animationID == @"removeProgOverlay") {
		[overlay removeFromSuperview];
		[overlay release];
	}
}



-(Movie*)syncLocalObject:(Movie*)local andRemoteObject:(Movie*)remote againstTruthObject:(Movie*)truth
{
	// start with title
	float myTimeDifference = fabs([local.updatedAt timeIntervalSinceDate:remote.updatedAt]);	

	BOOL localIsOlder = (myTimeDifference < 0);

	if(![local.title isEqualToString:remote.title] && ([local.title isEqualToString:truth.title] || localIsOlder)) {
		local.title = remote.title;
	}
	if([local.score integerValue] != [remote.score integerValue] && ([local.score integerValue] == [truth.score integerValue] || localIsOlder)) {
		local.score = remote.score;
	}
	if(![local.thoughts isEqualToString:remote.thoughts] && ([local.thoughts isEqualToString:truth.thoughts] || localIsOlder)) {
		local.thoughts = remote.thoughts;
	}
	if(local.bluray != remote.bluray && (local.bluray == truth.bluray || localIsOlder)) {
		local.bluray = remote.bluray;
	}
	if(local.dvd1 != remote.dvd1 && (local.dvd1 == truth.dvd1 || localIsOlder)) {
		local.dvd1 = remote.dvd1;
	}
	if(local.dvd2 != remote.dvd2 && (local.dvd2 == truth.dvd2 || localIsOlder)) {
		local.dvd2 = remote.dvd2;
	}
	if(local.dvd4 != remote.dvd4 && (local.dvd4 == truth.dvd4 || localIsOlder)) {
		local.dvd4 = remote.dvd4;
	}
	if(local.seenIt != remote.seenIt && (local.seenIt == truth.seenIt || localIsOlder)) {
		local.seenIt = remote.seenIt;
	}
	
	float localRemoteSeenOnTimeDifference = fabs([local.seenOn timeIntervalSinceDate:remote.seenOn]);
	float localTruthSeenOnTimeDifference = fabs([local.seenOn timeIntervalSinceDate:truth.seenOn]);
	if(localRemoteSeenOnTimeDifference == 0 && (localTruthSeenOnTimeDifference || localIsOlder)) {
		local.seenOn = remote.seenOn;
	}
	
	return local;
}

-(void)syncStageOne
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	if(syncLogging) NSLog(@"Starting sync.");
	
	UIApplication*    app = [UIApplication sharedApplication];
	
	self->syncTask = [app beginBackgroundTaskWithExpirationHandler:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			if(self->syncTask != UIInvalidBackgroundTask) {
				[app endBackgroundTask:syncTask];
				self->syncTask = UIInvalidBackgroundTask;
			}
		});
	}];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

	[self changeOverlayToError:@"Authorizing" andThenHide:NO];
	
	BOOL serverUsesSSL = [defaults boolForKey:@"SyncUseSSL"];
	NSString *server = [defaults valueForKey:@"SyncServer"];
	NSString *user = [defaults valueForKey:@"SyncUser"];
	NSString *thePassword = [defaults valueForKey:@"SyncPass"];
	NSString *authSuffix = [NSString stringWithFormat:@"user=%@&pass=%@", [user urlencode], [thePassword urlencode]];
	NSString *serverPath = [NSString stringWithFormat:@"http%@://%@/movies/", (serverUsesSSL ? @"s":@""), server];	
	NSString *authCheckURL = [NSString stringWithFormat:@"%@sync_auth_check?%@", serverPath, authSuffix];	
	NSString *authCheck = [NSString stringWithContentsOfURL:[NSURL URLWithString:authCheckURL] encoding:NSUTF8StringEncoding error:nil];
	if(authCheck == nil) {
		[self changeOverlayToError:@"Server unreachable." andThenHide:YES];
		if(syncLogging) NSLog(@"Server unreachable.");
		return; // server unavailable, probably.
	}

	if([authCheck isEqualToString:@"AUTHFAILED"]) {
		if(syncLogging) NSLog(@"Password bad.");
		return;
	}
	
	if(![authCheck isEqualToString:@"OK"]) {
		[self changeOverlayToError:@"Server error." andThenHide:YES];
		if(syncLogging) NSLog(@"authCheckURL: %@ said %@", authCheckURL, authCheck);
		return;
	}

	[self changeOverlayToError:@"Starting Sync" andThenHide:NO];

	NSString *lastSyncDate = [store.lastSync descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S" timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0] locale:nil];

	NSString *XMLPath = [NSString stringWithFormat:@"%@sync_down?since=%@&%@", serverPath, [lastSyncDate urlencode], authSuffix];	
	if(syncLogging) NSLog(@"Sync Down URL is %@", XMLPath);
	
	
	Movie *value;
	
	NSMutableArray *newMovies = [store getNewMoviesForSync];
	
	NSString *SyncUpPath = [NSString stringWithFormat:@"%@sync_up?%@", serverPath, authSuffix];	
	
	if(syncLogging) NSLog(@"Syncing up %d new movies.", [newMovies count]);
	for(value in newMovies) {
		[value performSelectorOnMainThread:@selector(hydrate) withObject:nil waitUntilDone:YES];
		if(syncLogging) NSLog(@"The following movie has created locally and needs to be synced: %@", value);
		[self syncUpMovie:value toServerURL:SyncUpPath withID:NO];
		[store performSelectorOnMainThread:@selector(deleteMovieFromStore:) withObject:value.dbId waitUntilDone:YES];
	}
	
	NSError *parseError = nil;
	
	NSDictionary *modelDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Movie", @"movie", nil];
    XMLReaderSAX *streamingParser = [[XMLReaderSAX alloc] init];
    [streamingParser setModelObjectDictionary:modelDictionary];
    [modelDictionary release];
	
    [streamingParser parseXMLFileAtURL:[NSURL URLWithString:XMLPath] parseError:&parseError];

	[self changeOverlayToError:@"Sync in Progress" andThenHide:NO];

    NSArray *movies = streamingParser.parsedModelObjects;
	
	NSMutableArray *syncProblems = [NSMutableArray array];
	NSMutableArray *syncSuccesses = [NSMutableArray array];
	
	int okMovies = 0, badMovies = 0, progress = 0;
	
	int totalMovies = [movies count];
	
	if(totalMovies > 2) {
		[self performSelectorOnMainThread:@selector(showOverlay) withObject:nil waitUntilDone:NO];
	}
	
	[store tellCacheToSave];
		
	// get the movies that have been updated
	NSMutableArray *changed = [store getMoviesWithConditions:[NSString stringWithFormat:@"updated_at > '%@'", store.lastSync]];
	
	totalMovies = totalMovies + [changed count] + 1;
	
	for (value in movies) {
		if([store hasMovie:value beenUpdatedSince:store.lastSync]) {
			//NSLog(@"Can't auto update this movie, it's been changed locally... %@", value);
			[syncProblems addObject:value];
			badMovies++;
		} else {
			if([store insertOrUpdateMovie:value]) {
				[syncSuccesses addObject:[Movie movieWithPrimaryKey:[value.dbId integerValue] andStore:store]];
			}
			[store insertOrUpdateTruthMovie:value];
			okMovies++;
		}
		progress++;
		
		//NSNumber *numb = [NSNumber numberWithFloat:(((progress * 1.0) / (totalMovies * 1.0) * 100) / 100)];
		//[self performSelectorOnMainThread:@selector(setProgress:) withObject:numb waitUntilDone:NO];
    }
	
	//NSLog(@"Sync stage one done - %d success, %d conflicts", );
	
	NSInteger resolvedConflicts = 0;
	
	for(value in syncProblems) {
		Movie *local = [store getMovie:[value.dbId integerValue]];
		[local hydrate];

		Movie *truth = [store getMovie:[value.dbId integerValue]];
		truth.table = @"trogdor";
		[truth hydrate];
		
		Movie *result = [self syncLocalObject:local andRemoteObject:value againstTruthObject:truth];
		[store insertOrUpdateTruthMovie:result];
		[result dehydrate];
		[truth dehydrate];
		resolvedConflicts++;
	}
	
	//NSLog(@"Sync stage two done - %d resolved conflicts", resolvedConflicts);
	
	NSInteger changified = 0;
	
	for(value in changed) {
		[value hydrate];
		//NSLog(@"The following movie has changed locally and needs to be synced: %@", value);
		
		[self syncUpMovie:value toServerURL:SyncUpPath withID:YES];

		changified++;
		progress++;
		//NSNumber *numb = [NSNumber numberWithFloat:(((progress * 1.0) / (totalMovies * 1.0) * 100) / 100)];
		//[self performSelectorOnMainThread:@selector(setProgress:) withObject:numb waitUntilDone:NO];
	}
	
	if(syncLogging) NSLog(@"Sync done - %d %d %d %d. We're all done folks!", okMovies, badMovies, resolvedConflicts, changified);
	
	[store setSyncDate];
	
    // The parser creates the array of model objects, but it doesn't know when to dispose of it.
    // At this point we've taken the results and stored them elsewhere, so we can
    // tell the parser to release the model objects and avoid leaking them.
    [streamingParser releaseModelObjects];    
    [streamingParser release]; 

	//prog.progress = 1.0;
	[self changeOverlayToError:@"Done." andThenHide:YES];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[appController performSelectorOnMainThread:@selector(masterListUpdated) withObject:nil waitUntilDone:NO];
	
   [pool release];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if(self->syncTask != UIInvalidBackgroundTask) {
			[app endBackgroundTask:self->syncTask];
			self->syncTask = UIInvalidBackgroundTask;
		}
	});
	
	syncInProgress = NO;
}

-(void)syncUpMovie:(Movie*)mov toServerURL:(NSString*)SyncUpPath withID:(BOOL)includeID
{
	NSString *syncUpString = [mov urlVersionOfMeWithPrefix:@"movie" andIncludeID:includeID];
	
	if(syncLogging) NSLog(@"Syncing up %@", syncUpString);
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:SyncUpPath]];
	
	NSData *data = [syncUpString dataUsingEncoding:NSStringEncodingConversionExternalRepresentation];
	
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody:data];
	
	NSError *err;
	NSURLResponse *response;
	
	NSData *d = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&err];
	
	NSString *m = [NSString stringWithCString:[d bytes] encoding:NSUTF8StringEncoding];
	
	if(![m isEqualToString:@"OK"]) {
		if(syncLogging) NSLog(@"Upload of %@ failed with %@", mov, m);
	}
	
	if(err != nil) {
		if(syncLogging) NSLog(@"There was an error %@", err);
	}
}
-(void)sync
{
	if(![self couldSync]) {
		if(syncLogging) NSLog(@"Sync is disabled in preferences.");
		return;
	}	
	
	while(syncInProgress) {
		NSLog(@".... sync in progress, do it later.");
		return;
	}
	syncInProgress = YES;
	
	NSLog(@"Start sync...");
	
	NSString *server = [defaults valueForKey:@"SyncServer"];
	NSString *user = [defaults valueForKey:@"SyncUser"];
	
	if([server isEqualToString:@""] || [user isEqualToString:@""]) {
        NSString *message = @"Sync is enabled, but account details have not been entered. Go to Settings to configure your account.";
        self.usageAlertView = [[UIAlertView alloc] initWithTitle:@"Sync Error" message:message delegate:self cancelButtonTitle:@"Cancel Sync" otherButtonTitles:nil];
        [self.usageAlertView show];
		return;
	}
	
	[NSThread detachNewThreadSelector:@selector(syncStageOne) toTarget:self withObject:nil];
}




-(BOOL)couldSync
{
	return [defaults boolForKey:@"SyncEnabled"];
}

-(void)regainComposure {
	NSLog(@"SyncController regaining compusre...");
	[defaults synchronize];
	syncLogging = [defaults boolForKey:@"ExtraLogging"];
}

@end
