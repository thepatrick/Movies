//
//  PersistStore.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 14/03/08.
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
