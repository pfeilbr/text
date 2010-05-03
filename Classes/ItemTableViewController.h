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
	UIBarButtonItem *addButton;	
	UIActionSheet *addActionSheet;	
	NSString *currentDirectoryPath;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UIActionSheet *addActionSheet;
@property(nonatomic, copy) NSString *currentDirectoryPath;

- (IBAction)addButtonPressed:(id)sender;
- (void)reload;
- (void)selectItem:(BPItem*)item;

@end
