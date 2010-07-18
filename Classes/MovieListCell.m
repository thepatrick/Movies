//
//  MovieListCell.m
//  Movies
//
//  Created by Patrick Quinn-Graham on 13/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import "MovieListCell.h"
#import "PersistStore.h"
#import "Movie.h"

@implementation MovieListCell

@synthesize values;
@synthesize theTitle;
@synthesize theScore;


-(void)sharedInit
{
	/*
	 Create label views to contain the various pieces of text that make up the cell.
	 Add these as subviews.
	 */
	theTitle = [self newLabelForMainText:YES];
	theTitle.textAlignment = UITextAlignmentLeft; // default
	[self addSubview:theTitle];
	[theTitle release];
	
	theScore = [self newLabelForMainText:NO];
	theScore.textAlignment = UITextAlignmentRight; // default
	[self addSubview:theScore];
	[theScore release];	
}

-initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier
{
	if(self = [super initWithFrame:frame reuseIdentifier:identifier]) {
		[self sharedInit];
	}
	return self;
}

-initWithFrame:(CGRect)frame
{

	if (self = [super initWithFrame:frame]) {
		[self sharedInit];
	}
	return self;
}


- (void)dealloc
{
    [super dealloc];
}

- (UILabel *)newLabelForMainText:(BOOL)main {
	/*
	 Create and configure a label view for main or secondary text.
	 Use a default frame as the views will be laid out in layoutSubviews
	 */
	
	/*
	 Colors for the main text and secondary text, in selected and unselected forms
	 When the cell is (un)selected, the labels' highlighted flag will be set acordingly
	 (see setSelected:animated:).
	 Set the background color to clear so highlighting shows correctly
	 */
	UIColor *primaryColor, *selectedColor;
	UIFont *font;
	
	if (main) {
		primaryColor = [UIColor blackColor];
		selectedColor = [UIColor whiteColor];
		font = [UIFont systemFontOfSize:18];
	} else {
		primaryColor = [UIColor darkGrayColor];
		selectedColor = [UIColor lightGrayColor];
		font = [UIFont systemFontOfSize:12];
	}		
	/*
	 Views are drawn most efficiently when they are opaque and do not have a clear background, so set these defaults.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  This is handled in setSelected:animated:.

	 */
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	newLabel.backgroundColor = [UIColor whiteColor];
	newLabel.opaque = YES;
	newLabel.textColor = primaryColor;
	newLabel.highlightedTextColor = selectedColor;
	newLabel.font = font;
	
	return newLabel;
}

- (void)layoutSubviews {

#define LEFT_COLUMN_OFFSET 12
#define LEFT_COLUMN_WIDTH 220	
#define RIGHT_COLUMN_OFFSET 12	
#define RIGHT_COLUMN_WIDTH 50	
#define UPPER_ROW_TOP 12
#define RIGHT_COLUMN_OFFSET 12

    [super layoutSubviews];
    CGRect contentRect = self.contentView.frame;
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
    if (!self.editing) {
		CGFloat boundsX = contentRect.origin.x;
		CGRect frame;

		CGFloat rightOffset = contentRect.size.width - (RIGHT_COLUMN_OFFSET + RIGHT_COLUMN_WIDTH);
		
		frame = CGRectMake(boundsX + LEFT_COLUMN_OFFSET, UPPER_ROW_TOP, LEFT_COLUMN_WIDTH, 20);
		theTitle.frame = frame;
		
		frame =  CGRectMake(rightOffset, UPPER_ROW_TOP, RIGHT_COLUMN_WIDTH, 20);
		theScore.frame = frame;
		
   }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	/*
	 Views are drawn most efficiently when they are opaque and do not have a clear background, so in newLabelForMainText: the labels are made opaque and given a white background.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  
    */
	[super setSelected:selected animated:animated];
	
	UIColor *backgroundColor = nil;
	if (selected) {
	    backgroundColor = [UIColor clearColor];
	} else {
		backgroundColor = [UIColor whiteColor];
	}
	
	NSArray *labelArray = [[NSArray alloc] initWithObjects:theTitle, theScore, nil];
	for (UILabel *label in labelArray) {
		label.backgroundColor = backgroundColor;
		label.highlighted = selected;
		label.opaque = !selected;
	}	
}

- (void)setValues:(NSObject *)newValues {
	if (values != newValues) {
		[values release];
		values = [newValues retain];
	}	
	
	[(Movie*)values hydrate];
		
	// Update values in subviews		
	theTitle.text = [values valueForKey:@"title"];
	theScore.text = [[values valueForKey:@"score"] stringValue];
}

@end
