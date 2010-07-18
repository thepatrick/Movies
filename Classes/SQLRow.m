//
//  SQLRow.m
//  SQLite Test
//
//  Created by Dustin Mierau on Tue Apr 02 2002.
//  Copyright (c) 2002 Blackhole Media, Inc. All rights reserved.
//

#import "SQLDatabase.h"
#import "SQLDatabasePrivate.h"

@implementation SQLRow

- (id)initWithColumns:(char**)inColumns rowData:(char**)inRowData columns:(int)inColumnCount
{
	if( ![super init] )
		return nil;
	
	mRowData = inRowData;
	mColumns = inColumns;
	mColumnCount = inColumnCount;
	
	return self;
}

- (id)init
{
	if( ![super init] )
		return nil;
	
	mRowData = NULL;
	mColumns = NULL;
	mColumnCount = 0;
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark -

- (int)columnCount
{
	return mColumnCount;
}

#pragma mark -

- (NSString*)nameOfColumnAtIndex:(int)inIndex
{
	if( inIndex >= mColumnCount || ![self valid] )
		return nil;
	
	return [NSString stringWithCString:mColumns[ inIndex ]];
}

- (NSString*)nameOfColumnAtIndexNoCopy:(int)inIndex
{
	if( inIndex >= mColumnCount || ![self valid] )
		return nil;
	
	return [[[NSString alloc] initWithCStringNoCopy:mColumns[ inIndex ] length:strlen( mColumns[ inIndex ] ) freeWhenDone:NO] autorelease];
}

#pragma mark -

- (NSInteger)integerForColumn:(NSString*)inColumnName
{
	return [[self stringForColumn:inColumnName] integerValue];
}

- (NSInteger)integerForColumnAtIndex:(int)inIndex
{
	return [[self stringForColumnAtIndex:inIndex] integerValue];
}

- (NSString*)stringForColumn:(NSString*)inColumnName
{
	int index;
	
	if( ![self valid] )
		return nil;
	
	for( index = 0; index < mColumnCount; index++ )
		if( strcmp( mColumns[ index ], [inColumnName cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation] ) == 0 )
			break;
	
	return [self stringForColumnAtIndex:index];
}

- (NSString*)stringForColumnNoCopy:(NSString*)inColumnName
{
	int index;
	
	if( ![self valid] )
		return nil;
	
	for( index = 0; index < mColumnCount; index++ )
		if( strcmp( mColumns[ index ], [inColumnName cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation] ) == 0 )
			break;
	
	return [self stringForColumnAtIndexNoCopy:index];
}

- (NSString*)stringForColumnAtIndex:(int)inIndex
{
	if( inIndex >= mColumnCount || ![self valid] || mRowData[ inIndex ] == nil)
		return nil;
	
	return [NSString stringWithCString:mRowData[ inIndex ]];
}

- (NSString*)stringForColumnAtIndexNoCopy:(int)inIndex
{
	if( inIndex >= mColumnCount || ![self valid] )
		return nil;
	
	return [[[NSString alloc] initWithCStringNoCopy:mRowData[ inIndex ] length:strlen( mRowData[ inIndex ] ) freeWhenDone:NO] autorelease];
}

#pragma mark -

- (NSString*)description
{
	NSMutableString*	string = [NSMutableString string];
	int					column;
	
	for( column = 0; column < mColumnCount; column++ )
	{
		if( column ) [string appendString:@" | "];
		[string appendFormat:@"%s", mRowData[ column ]];
	}
	
	return string;
}

#pragma mark -

- (BOOL)valid
{
	return ( mRowData != NULL && mColumns != NULL && mColumnCount > 0 );
}

@end
