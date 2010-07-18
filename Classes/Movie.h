//
//  Movie.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 12/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMLModelObject.h"

@class SQLRow;

@interface Movie : NSObject <XMLModelObject> {

	BOOL dirty;
	BOOL hydrated;

	NSMutableDictionary *_rawAttributes; // content frm the XML parse.
	
	NSNumber *dbId;
	
	NSString *table;
	
	NSString *_title;
	NSNumber *_score;
	
	BOOL bluray;
	BOOL dvd1;
	BOOL dvd2;
	BOOL dvd4;
	BOOL seenIt;
	
	
	NSString *thoughts;

	NSDate *seenOn;
	NSDate *updatedAt;
	BOOL autoSetUpdatedAt;
	
	PersistStore *store;
}

@property (nonatomic, retain) NSMutableDictionary *rawAttributes;
@property (assign) NSString *table;
@property (copy) NSString *title;
@property (copy) NSString *thoughts;
@property (copy) NSNumber *score;
@property (copy) NSNumber *dbId;
@property (assign) BOOL bluray;
@property (assign) BOOL dvd1;
@property (assign) BOOL dvd2;
@property (assign) BOOL dvd4;
@property (assign) BOOL seenIt;

@property (readonly) BOOL owned;
@property (copy) NSDate *updatedAt;
@property (copy) NSDate *seenOn;

@property (retain) PersistStore *store;

@property (assign) BOOL autoSetUpdatedAt;

+movie;
+movieWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore;

-initWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore;

-(NSString*)urlVersionOfMeWithPrefix:(NSString*)prefix andIncludeID:(BOOL)includeID;

-(void)hydrate;
-(void)dehydrate;
-(void)save;

-(void)saveForNew;

@end
