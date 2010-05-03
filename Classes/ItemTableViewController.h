//
//  ItemTableViewController.h
//  text
//
//  Created by Brian Pfeil on 4/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPItemManager.h"
#import "BPItem.h"


@interface ItemTableViewController : UITableViewController<UIActionSheetDelegate> {
	NSArray *items;
	UIBarButtonItem *addButton;	
	UIActionSheet *addActionSheet;	
}

@property(nonatomic, retain) NSArray *items;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UIActionSheet *addActionSheet;

- (IBAction)addButtonPressed:(id)sender;

@end
