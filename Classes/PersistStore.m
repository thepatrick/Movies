//
//  PersistStore.m
//  Movies
//
//  Created by Patrick Quinn-Graham on 14/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import "SQLDatabase.h"
#import "PersistStore.h"
#import "Movie.h"

#define WAIT_FOR_DB_LOCK_THEN_LOCK while(dbLock) { NSLog(@"Awaiting db..."); }; dbLock = YES; 
//NSLog(@"dbLock engaged");
#define UNLOCK_DB dbLock = NO; 
//NSLog(@"dbLock disengaged");

@implementation PersistStore

@synthesize db;
@synthesize lastSync;

+storeWithFile:(NSString*)file
{
	PersistStore *store = [[[PersistStore alloc] init] autorelease];
	[store openDatabase:file];
	return store;
}

-init
{
	if(self = [super init]) {
		dbIsOpen = NO;
		dbLock = NO;
		centralMovieStore = [[NSMutableDictionary dictionaryWithCapacity:500] retain];
	}	
	return self;
}

-(void)dealloc {
	if(dbIsOpen) {
		[self closeDatabase];
	}
	[centralMovieStore release];
    [super dealloc];
}

-(BOOL)openDatabase:(NSString *)fileName
{	
	BOOL newFile = ![[NSFileManager defaultManager] fileExistsAtPath:fileName];
	self.db = [SQLDatabase databaseWithFile:fileName];
	[db open];
	dbIsOpen = YES;

	if(newFile) {
		NSLog(@"First run, create basic file format");
		[db performQuery:@"CREATE TABLE sync_status_and_version (last_sync datetime, version integer)"];
		[db performQuery:@"INSERT INTO sync_status_and_version VALUES (NULL, 0)"];
//		[db performQuery:@"COMMIT"];
	}

	SQLResult *res = [db performQuery:@"SELECT last_sync, version FROM sync_status_and_version;"];
	SQLRow *row = [res rowAtIndex:0];
	
	NSString *last_sync = [row stringForColumn:@"last_sync"];
	NSString *version = [row stringForColumn:@"version"];
	
	if(last_sync == nil) {
		self.lastSync = [NSDate dateWithTimeIntervalSince1970:0];
	} else {
		self.lastSync = [NSDate dateWithString:last_sync];	
	}
	
	int theVersion = [version integerValue];
	
	NSLog(@"Database: Version: '%d', Last Sync: '%@'", theVersion, self.lastSync);
	
	[self migrateFrom:theVersion];
	
	return YES;
}

-(void)closeDatabase
{
	dbIsOpen = NO;
	[db performQuery:@"COMMIT"];
	[db close];
}

-(void)migrateFrom:(NSInteger)version
{
	if(version < 1) {
		[db performQuery:@"CREATE TABLE movie (id INTEGER PRIMARY KEY, title TEXT, score INTEGER, thoughts TEXT, seenit INTEGER, seenon DATETIME, updated_at DATETIME, bluray INTEGER, dvd1 INTEGER, dvd2 INTEGER, dvd4 INTEGER)"];
		[db performQuery:@"CREATE TABLE trogdor (id INTEGER PRIMARY KEY, title TEXT, score INTEGER, thoughts TEXT, seenit INTEGER, seenon DATETIME, updated_at DATETIME, bluray INTEGER, dvd1 INTEGER, dvd2 INTEGER, dvd4 INTEGER)"];
		[db performQuery:@"CREATE TABLE new_movies (new_movie_id INTEGER)"];
		[db performQuery:@"UPDATE sync_status_and_version SET version = 1"];
//		[db performQuery:@"COMMIT"];
		NSLog(@"Database migrated to v1.");
	}
}



-(void)setSyncDate
{
	self.lastSync = [NSDate date];
	[db performQueryWithFormat:@"UPDATE sync_status_and_version SET last_sync = '%@'", self.lastSync];
}

-(BOOL)hasMovie:(Movie*)movie beenUpdatedSince:(NSDate*)date
{
	SQLResult *res = [db performQueryWithFormat:@"SELECT updated_at FROM movie WHERE id = %d", movie.dbId];
	if([res rowCount] == 0) {
		return NO; // it's new.
	}
	SQLRow *row = [res rowAtIndex:0];
	NSDate *localDate = [NSDate dateWithString:[row stringForColumn:@"updated_at"]];

	float myTimeDifference = fabs([localDate timeIntervalSinceDate:date]);	
	
	return (myTimeDifference > 0); // localDate is more recent than the incoming date.
}

-(NSInteger)insertMovie:(Movie*)movie inTable:(NSString*)table andAddToNew:(BOOL)addToNew
{
	NSString *theTitle = [SQLDatabase prepareStringForQuery:movie.title];
	NSString *theThoughts = [SQLDatabase prepareStringForQuery:movie.thoughts];
	
	NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (id, title, score, bluray, dvd1, dvd2, dvd4, updated_at, thoughts, seenit, seenon) VALUES (%@, '%@', %d, %d, %d, %d, %d, '%@', '%@', %d, '%@')",
		table,
		(movie.dbId == nil ? @"NULL" : movie.dbId),
		theTitle,
		[movie.score integerValue],
		movie.bluray,
		movie.dvd1,
		movie.dvd2,
		movie.dvd4,
		movie.updatedAt,
		theThoughts,
		movie.seenIt,
		movie.seenOn];
	
	WAIT_FOR_DB_LOCK_THEN_LOCK
	[db performQuery:sql];	
	UNLOCK_DB
	
	NSInteger newMovieID;
	
	if(addToNew) {
		
		WAIT_FOR_DB_LOCK_THEN_LOCK
		SQLResult *res = [db performQueryWithFormat:@"SELECT max(id) FROM %@", table];
		if(!res) {
			[db performQuery:@"ROLLBACK"];
		}
		SQLRow *row = [res rowAtIndex:0];
		if(!row) {
			[db performQuery:@"ROLLBACK"];
		}
		
		newMovieID = [row integerForColumnAtIndex:0];
		[db performQueryWithFormat:@"INSERT INTO new_movies (new_movie_id) VALUES (%d)", newMovieID];
		UNLOCK_DB
		
	} else {
		newMovieID =  [movie.dbId integerValue];
	}
	
//	WAIT_FOR_DB_LOCK_THEN_LOCK
//	[db performQuery:@"COMMIT"];	
//	UNLOCK_DB
	
	return newMovieID;
}

-(BOOL)insertOrUpdateMovie:(Movie*)movie inTable:(NSString*)table
{
	BOOL shouldInsert = YES;
	if(movie.dbId != nil) {
		WAIT_FOR_DB_LOCK_THEN_LOCK
		SQLResult *res = [db performQueryWithFormat:@"SELECT id FROM %@ WHERE id = %@", table, movie.dbId];
		shouldInsert = ([res rowCount] == 0);	
		UNLOCK_DB
	}
	
	NSString *theTitle = [SQLDatabase prepareStringForQuery:movie.title];
	NSString *theThoughts = [SQLDatabase prepareStringForQuery:movie.thoughts];
	
	if(shouldInsert) {
		[self insertMovie:movie inTable:table andAddToNew:NO];
	} else { // shouldInsert == NO.
		NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET title = '%@', score = %d, bluray = %d, dvd1 = %d, dvd2 = %d, dvd4 = %d, updated_at = '%@', thoughts = '%@', seenit = %d, seenon = '%@' WHERE id = %@",
			table,
			theTitle,
			[movie.score integerValue],
			movie.bluray,
			movie.dvd1,
			movie.dvd2,
			movie.dvd4,
			movie.updatedAt,
			theThoughts,
			movie.seenIt,
			movie.seenOn,
			movie.dbId];
		WAIT_FOR_DB_LOCK_THEN_LOCK
		[db performQuery:sql];	
//		[db performQuery:@"COMMIT"];
		UNLOCK_DB
	}
	return shouldInsert;
}

// returns YES if insert, NO on update.
-(BOOL)insertOrUpdateMovie:(Movie*)movie
{
	return [self insertOrUpdateMovie:movie inTable:@"movie"];
}

// returns YES if insert, NO on update.
-(BOOL)insertOrUpdateTruthMovie:(Movie*)movie
{
	return [self insertOrUpdateMovie:movie inTable:@"trogdor"];
}

-(void)getNewMoviesForSync_worker
{

}

-(NSMutableArray*)getNewMoviesForSync
{
//	while(_inPlayMovieFetch != nil) {
//		NSLog(@"Waiting for previous getNewMoviesForSync to end...");
//	}

	//	_inPlayMovieFetch = [NSMutableArray array];
//	[self performSelectorOnMainThread:@selector(getNewMoviesForSync_worker) withObject:nil waitUntilDone:YES];
	
	WAIT_FOR_DB_LOCK_THEN_LOCK
	NSMutableArray *returning_array = [NSMutableArray array];
	SQLResult *res = [db performQuery:@"SELECT new_movie_id FROM new_movies"];
	SQLRow *row;
	for(row in [res rowEnumerator]) {
		[returning_array addObject:[self getMovie:[row integerForColumn:@"new_movie_id"]]];
	}
	UNLOCK_DB
	return returning_array;
}

-(NSMutableArray*)getMoviesWithConditions:(NSString*)conditions andSort:(NSString*)sort
{
	WAIT_FOR_DB_LOCK_THEN_LOCK
	NSMutableArray *array = [NSMutableArray array];
	SQLResult *res = [db performQueryWithFormat:@"SELECT id FROM movie %@ ORDER BY %@", 
						(conditions != nil ? [@"WHERE " stringByAppendingString:conditions] : @""),
					  (sort != nil ? sort : @"title ASC")];
	
	
	SQLRow *row;
	for(row in [res rowEnumerator]) {
		[array addObject:[self getMovie:[row integerForColumn:@"id"]]];
	}
	
	//NSLog(@"returning for %@ %@: %@", conditions, sort, array);
	UNLOCK_DB
	
	return array;
}

-(NSMutableArray*)getMoviesWithConditions:(NSString*)conditions
{
	return [self getMoviesWithConditions:conditions andSort:nil];
}

-(NSMutableArray*)getAllMovies
{
	return [self getMoviesWithConditions:nil andSort:nil];
}

-(Movie*)getMovie:(NSInteger)movieId
{
	Movie *theMovie = [centralMovieStore objectForKey:[NSString stringWithFormat:@"%d", movieId]];
	if(theMovie == nil) {
		NSString *theKey = [NSString stringWithFormat:@"%d", movieId];
		theMovie = [Movie movieWithPrimaryKey:movieId andStore:self];
		[centralMovieStore setObject:theMovie forKey:theKey];
	}
	return theMovie;
}

-(void)deleteMovieFromStore:(NSInteger)movieId
{
//	[self performSelectorOnMainThread:@selector(removeMovieFromCache:) withObject:[NSNumber numberWithInt:movieId] waitUntilDone:YES];
//	[db performSelectorOnMainThread:@selector(performQuery:) withObject:[NSString stringWithFormat:@"DELETE FROM movie WHERE id = %d", movieId] waitUntilDone:YES];
//	[db performSelectorOnMainThread:@selector(performQuery:) withObject:[NSString stringWithFormat:@"DELETE FROM new_movies WHERE new_movie_id = %d", movieId] waitUntilDone:YES];
	[self removeMovieFromCache:movieId];
	[db performQueryWithFormat:@"DELETE FROM movie WHERE id = %d", movieId];
	[db performQueryWithFormat:@"DELETE FROM new_movies WHERE new_movie_id = %d", movieId];
	//[db performQuery:@"COMMIT"];
}

-(void)removeMovieFromCache:(NSInteger)movieId
{
	[centralMovieStore removeObjectForKey:[NSString stringWithFormat:@"%d", movieId]];
}

-(void)tellCacheToSave
{
	NSArray *pen = [centralMovieStore allValues];
	[pen makeObjectsPerformSelector:@selector(save)];
}

-(void)tellCacheToDehydrate
{
	NSArray *pen = [centralMovieStore allValues];
	[pen makeObjectsPerformSelector:@selector(dehydrate)];
}


@end
