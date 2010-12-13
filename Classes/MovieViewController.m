//
//  MovieView.m
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


#import "MovieViewController.h"
#import "MoviesAppDelegate.h"
#import "Movie.h"
#import "MovieThoughtsController.h"
#import "MovieViewCell.h"
#import "Constants.h"
#import "PersistStore.h"

@implementation MovieViewController

@synthesize theMovie;
@synthesize appController;
@synthesize newMode;

-init
{
	if(self = [super init]) {
		self.newMode = NO;
	}
	return self;
}

- (void)dealloc
{
	[thoughtsController release];
	[super dealloc];
}


- (void)loadView {
	tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped]; //UITableViewStylePlain
	tableView.delegate = self;
	tableView.dataSource = self;	
	self.view = tableView;
	
	if(self.newMode) {
		UINavigationItem *navItem = self.navigationItem;
		
		
		UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save:)] autorelease];	
		navItem.rightBarButtonItem = saveButton;
	}
}

-(void)masterListUpdated
{
	[self viewWillAppear:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	self.title = NSLocalizedString(@"Movie", @"Movie title");
	[tableView reloadData];
    //[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0] animated:animated scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewDidAppear:(BOOL)animated 
{
	// we've got as far in to the quickStart process as we can, stop now.
	appController.quickStartInProgress = NO;
}

-(void)viewWillDisappear:(BOOL)animated {
	if(!self.newMode) {
		[appController.sync sync]; 	
	}	
}

-(void)save:(id)sender
{
	NSLog(@"Did request save!");
	[theMovie saveForNew];
	[appController.sync sync]; 
	[[self navigationController] popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0)
		return 5;
	if(section == 1)
		return 4;
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(section == 0)
		return @"Movie Info";
	if(section == 1)
		return @"Collection Info";
	return nil;
}

-(UITableViewCell *)movieViewCellForTitle:(NSString*)title andValue:(NSString*)value withAvailableCell:(UITableViewCell *)availableCell
{

	MovieViewCell *cell = nil;
	if (availableCell != nil) {
		// Use the existing cell if it's there
		cell = (MovieViewCell *)availableCell;
	} else {
		// Since the cell will be sized automatically, we can pass the zero rect for the frame
		cell = [[[MovieViewCell alloc] initWithFrame:CGRectZero] autorelease];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	[cell setTitle:title];
	[cell setValue:value];
	
	return cell;
}


-(UITableViewCell *)switchCellForTitle:(NSString*)title andValue:(BOOL)value andChangedSelector:(SEL)action withAvailableCell:(UITableViewCell *)availableCell
{

	UITableViewCell *cell = nil;
	if (availableCell != nil) {
		// Use the existing cell if it's there
		cell = (UITableViewCell *)availableCell;
	} else {
		// Since the cell will be sized automatically, we can pass the zero rect for the frame
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cell.textColor = [UIColor darkGrayColor];
	cell.font = [UIFont systemFontOfSize:16];
	cell.text = title;
	CGRect frame = CGRectMake(((94 + kLeftMargin + kSwitchButtonWidth)), kTopMargin - 10, kSwitchButtonWidth, kSwitchButtonHeight);
	UISwitch *switchControl = [[UISwitch alloc] initWithFrame:frame];
	
	[switchControl addTarget:self action:action forControlEvents:UIControlEventValueChanged];

	switchControl.backgroundColor = [UIColor clearColor];
	
	switchControl.on = value;
		
	[cell addSubview:switchControl];
    [switchControl release];
		
	return cell;
}


-(UITableViewCell *)textfieldCellForTitle:(NSString*)title andValue:(NSString*)value andChangedSelector:(SEL)action andKeyboardType:(UIKeyboardType)keyboard withAvailableCell:(UITableViewCell *)availableCell
{

	UITableViewCell *cell = nil;
	if (availableCell != nil) {
		// Use the existing cell if it's there
		cell = (UITableViewCell *)availableCell;
	} else {
		// Since the cell will be sized automatically, we can pass the zero rect for the frame
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cell.textLabel.textColor = [UIColor darkGrayColor];
	cell.textLabel.font = [UIFont systemFontOfSize:16];
	cell.textLabel.text = title;
		
	CGRect	frame =  CGRectMake(92, 12, 200, 20);
	
	UITextField *textControl = [[[UITextField alloc] initWithFrame:frame] autorelease];
	
	textControl = [[UITextField alloc] initWithFrame:frame];
    textControl.borderStyle = UITextBorderStyleNone;
	textControl.textColor = [UIColor blackColor];
    textControl.font = [UIFont systemFontOfSize:18.0];
    textControl.delegate = self;
    textControl.backgroundColor = [UIColor clearColor];
	textControl.returnKeyType = UIReturnKeyDone;
	textControl.keyboardType = keyboard;	// input numbers only
	
	[textControl addTarget:self action:action forControlEvents:UIControlEventEditingDidEndOnExit];
	[textControl addTarget:self action:action forControlEvents:UIControlEventEditingDidEnd];

	textControl.backgroundColor = [UIColor clearColor];
	
	textControl.text = value;
		
	[cell addSubview:textControl];
    [textControl release];
		
	return cell;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *availableCell = nil;
	
	[theMovie hydrate];
	if(indexPath.section == 0 && indexPath.row == 0) {
		return [self textfieldCellForTitle:@"Title" andValue:theMovie.title andChangedSelector:@selector(titleDidFinish:) andKeyboardType:UIKeyboardTypeDefault withAvailableCell:availableCell];
	}

	if(indexPath.section == 0 && indexPath.row == 1) {
		return [self textfieldCellForTitle:@"Score" andValue:[NSString stringWithFormat:@"%d", [theMovie.score integerValue]] andChangedSelector:@selector(scoreDidFinish:) andKeyboardType:UIKeyboardTypeNumberPad withAvailableCell:availableCell];
	}

	if(indexPath.section == 0 && indexPath.row == 2) {
		return [self movieViewCellForTitle:@"Thoughts" andValue:((theMovie.thoughts != nil && ![theMovie.thoughts isEqualToString:@"(null)"]) ? theMovie.thoughts : @"") withAvailableCell:availableCell];
	}
	
	if(indexPath.section == 0 && indexPath.row == 3) {
		return [self switchCellForTitle:@"Seen It" andValue:theMovie.seenIt andChangedSelector:@selector(seenItDidChange:) withAvailableCell:availableCell];
	}

	if(indexPath.section == 0 && indexPath.row == 4) {
		NSDateFormatter *f = [[[NSDateFormatter alloc] init] autorelease];
		[f setDateStyle:NSDateFormatterLongStyle];
		return [self movieViewCellForTitle:@"Added" andValue:[f stringFromDate:theMovie.seenOn] withAvailableCell:availableCell];
	}
	

	if(indexPath.section == 1 && indexPath.row == 0) {
		return [self switchCellForTitle:@"On BluRay" andValue:theMovie.bluray andChangedSelector:@selector(blurayDidChange:) withAvailableCell:availableCell];
	}
	
	if(indexPath.section == 1 && indexPath.row == 1) {
		return [self switchCellForTitle:@"On DVD1" andValue:theMovie.dvd1 andChangedSelector:@selector(dvd1DidChange:) withAvailableCell:availableCell];
	}

	if(indexPath.section == 1 && indexPath.row == 2) {
		return [self switchCellForTitle:@"On DVD2" andValue:theMovie.dvd2 andChangedSelector:@selector(dvd2DidChange:) withAvailableCell:availableCell];
	}
	
	if(indexPath.section == 1 && indexPath.row == 3) {
		return [self switchCellForTitle:@"On DVD4" andValue:theMovie.dvd4 andChangedSelector:@selector(dvd4DidChange:) withAvailableCell:availableCell];
	}
	
	return nil;
}

-(void)blurayDidChange:(UISwitch*)sender
{
	[theMovie hydrate];
	theMovie.bluray = sender.on;
}

-(void)dvd1DidChange:(UISwitch*)sender
{
	[theMovie hydrate];
	theMovie.dvd1 = sender.on;
}

-(void)dvd2DidChange:(UISwitch*)sender
{
	[theMovie hydrate];
	theMovie.dvd2 = sender.on;
}

-(void)dvd4DidChange:(UISwitch*)sender
{
	[theMovie hydrate];
	theMovie.dvd4 = sender.on;
}


-(void)seenItDidChange:(UISwitch*)sender
{
	[theMovie hydrate];
	theMovie.seenIt = sender.on;
}

-(void)scoreDidFinish:(UITextField*)sender
{
	NSInteger theValue = [sender.text integerValue];
	if(theValue != [theMovie.score integerValue]) {
		[theMovie hydrate];
		theMovie.score = [NSNumber numberWithInteger:theValue];	
	}
}

-(void)titleDidFinish:(UITextField*)sender
{
	if(![theMovie.title isEqualToString:sender.text]) {
		[theMovie hydrate];
		theMovie.title = sender.text;
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(!(indexPath.section == 0 && indexPath.row == 2)) return nil;
	// In this case we don't want the user to be able to select individual items, so return nil
	
	if(thoughtsController == nil) {
		thoughtsController = [[MovieThoughtsController alloc] init];
	}
	
	thoughtsController.theMovie = self.theMovie;
	
	[[self navigationController] pushViewController:thoughtsController animated:YES];
	
	return indexPath;
}

@end
