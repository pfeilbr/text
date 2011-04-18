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
#import "LoadingView.h"

@interface ItemTableViewController : UITableViewController<BPItemManagerDelegate, UIActionSheetDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
	BOOL itemLoadInProgress;
	BOOL itemsLoaded;
	BOOL isRootDirectory;
	UIBarButtonItem* addButton;	
	UIActionSheet* addActionSheet;
	BPItemManager* itemManager;
	BPItem* currentDirectoryItem;
	NSString* searchString;
	BPItem* currentSelectedItem;
	NSMutableArray* items;
	LoadingView* loadingView;
    NSUInteger rowToDelete;
}

@property BOOL isRootDirectory;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* addButton;
@property (nonatomic, retain) IBOutlet UIActionSheet* addActionSheet;
@property(nonatomic, retain, setter=setCurrentDirectoryItem:) BPItem* currentDirectoryItem;
@property(nonatomic, copy) NSString* searchString;
@property(nonatomic, retain) BPItem* currentSelectedItem;

- (IBAction)addButtonPressed:(id)sender;
- (void)reload;
- (void)loadItems;

@end
