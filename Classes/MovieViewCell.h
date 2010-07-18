//
//  MovieViewCell.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 13/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MovieViewCell : UITableViewCell {
	UILabel *theTitle;
	UILabel *theValue;
}

@property (nonatomic, assign) UILabel *theTitle;
@property (nonatomic, assign) UILabel *theValue;

- (UILabel *)newLabelForMainText:(BOOL)main;

- (void)setTitle:(NSString *)theNewTitle;
- (void)setValue:(NSString *)theNewValue;

@end
