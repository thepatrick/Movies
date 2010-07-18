//
//  PersistStore.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 14/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SQLDatabase;
@class Movie;

@interface PersistStore : NSObject {

	SQLDatabase *db;
	
	NSDate *lastSync;
	
	NSMutableDictionary *centralMovieStore;
	
	NSMutableArray *_inPlayMovieFetch;

	BOOL dbLock;
	BOOL dbIsOpen;
}

@property (nonatomic, retain) SQLDatabase *db;
@property (nonatomic, retain) NSDate *lastSync;

+storeWithFile:(NSString*)file;

-(BOOL)openDatabase:(NSString *)fileName;
-(void)closeDatabase;
-(void)migrateFrom:(NSInteger)version;
-(void)setSyncDate;
-(BOOL)hasMovie:(Movie*)movie beenUpdatedSince:(NSDate*)date;

-(NSInteger)insertMovie:(Movie*)movie inTable:(NSString*)table andAddToNew:(BOOL)addToNew;
-(BOOL)insertOrUpdateMovie:(Movie*)movie inTable:(NSString*)table;
-(BOOL)insertOrUpdateMovie:(Movie*)movie;
-(BOOL)insertOrUpdateTruthMovie:(Movie*)movie;

-(NSMutableArray*)getAllMovies;
-(NSMutableArray*)getMoviesWithConditions:(NSString*)conditions;
-(NSMutableArray*)getMoviesWithConditions:(NSString*)conditions andSort:(NSString*)sort;
-(NSMutableArray*)getNewMoviesForSync;

-(Movie*)getMovie:(NSInteger)movieId;
-(void)deleteMovieFromStore:(NSInteger)movieId;
-(void)removeMovieFromCache:(NSInteger)movieId;

-(void)tellCacheToDehydrate;
-(void)tellCacheToSave;

@end
