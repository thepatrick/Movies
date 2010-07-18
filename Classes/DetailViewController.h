//
//  DetailViewController.h
//  Blargh
//
//  Created by Patrick Quinn-Graham on 09/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	NSDictionary *detailItem;
	UITableView *tableView;
}

@property (nonatomic, retain) NSDictionary *detailItem;
@property (nonatomic, retain) UITableView *tableView;

@end
