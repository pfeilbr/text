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


@interface ItemTableViewController : UITableViewController<UIActionSheetDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
	BOOL isRootDirectory;
	UIBarButtonItem *addButton;	
	UIActionSheet *addActionSheet;	
	BPItem *currentDirectoryItem;
	NSString *searchString;
	BPItem *currentSelectedItem;
}

@property BOOL isRootDirectory;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UIActionSheet *addActionSheet;
@property(nonatomic, retain) BPItem *currentDirectoryItem;
@property(nonatomic, copy) NSString *searchString;
@property(nonatomic, retain) BPItem *currentSelectedItem;

- (IBAction)addButtonPressed:(id)sender;
- (void)reload;
- (void)selectItem:(BPItem*)item;


@end
