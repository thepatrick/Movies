//
//  LeftIconCell.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 11/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LeftIconCell : UITableViewCell 
{

	UIImageView *imageView;
	UILabel *theLabel;
	
	NSDictionary *values;

}

@property (nonatomic, retain) NSDictionary *values;
@property (nonatomic, assign) UILabel *theLabel;

- (UILabel *)newLabelForMainText:(BOOL)main;

@end
