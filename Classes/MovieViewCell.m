//
//  MovieViewCell.m
//  Movies
//
//  Created by Patrick Quinn-Graham on 13/03/08.
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


#import "MovieViewCell.h"


@implementation MovieViewCell

@synthesize theTitle;
@synthesize theValue;

- (id)initWithFrame:(CGRect)frame {

	if (self = [super initWithFrame:frame]) {
		/*
		 Create label views to contain the various pieces of text that make up the cell.
		 Add these as subviews.
		 */
		theTitle = [self newLabelForMainText:NO];
		theTitle.textAlignment = UITextAlignmentLeft; // default
		[self addSubview:theTitle];
		[theTitle release];
		
		theValue = [self newLabelForMainText:YES];
		theValue.textAlignment = UITextAlignmentLeft; // default
		[self addSubview:theValue];
		[theValue release];
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
		font = [UIFont systemFontOfSize:16];
	} else {
		primaryColor = [UIColor darkGrayColor];
		selectedColor = [UIColor lightGrayColor];
		font = [UIFont systemFontOfSize:16];
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
#define LEFT_COLUMN_WIDTH 75	
#define RIGHT_COLUMN_OFFSET 92
#define UPPER_ROW_TOP 12

    [super layoutSubviews];
    CGRect contentRect = self.contentView.frame;
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
    if (!self.editing) {
		CGFloat boundsX = contentRect.origin.x;
		CGRect frame;

		CGFloat rightWidth = contentRect.size.width - (2 + RIGHT_COLUMN_OFFSET);
		
		frame = CGRectMake(boundsX + LEFT_COLUMN_OFFSET, UPPER_ROW_TOP, LEFT_COLUMN_WIDTH, 20);
		theTitle.frame = frame;
		
		frame =  CGRectMake(RIGHT_COLUMN_OFFSET, UPPER_ROW_TOP, rightWidth, 20);
		theValue.frame = frame;
		
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
	
	NSArray *labelArray = [[NSArray alloc] initWithObjects:theTitle, theValue, nil];
	for (UILabel *label in labelArray) {
		label.backgroundColor = backgroundColor;
		label.highlighted = selected;
		label.opaque = !selected;
	}	
}

- (void)setTitle:(NSString *)theNewTitle {
	theTitle.text = theNewTitle;
}
- (void)setValue:(NSString *)theNewValue {
	theValue.text = theNewValue;
}

@end
