//
//  MovieListCell.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 13/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MovieListCell : UITableViewCell {
	UILabel *theTitle;
	UILabel *theScore;
	NSObject *values;
}

@property (nonatomic, retain) NSObject *values;
@property (nonatomic, assign) UILabel *theTitle;
@property (nonatomic, assign) UILabel *theScore;

- (UILabel *)newLabelForMainText:(BOOL)main;

@end
