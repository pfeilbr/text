//
//  DetailViewController.h
//  text
//
//  Created by Brian Pfeil on 4/28/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "BPTextView.h"
#import "BPItem.h"
#import "SettingsTableViewController.h"
#import "NewItemViewController.h"
#import "BPConfig.h"

@class RootViewController;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UITextViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	UIPopoverController *popoverController;
	UIToolbar *toolbar;
	UIBarButtonItem *itemLabelBarButtonItem;
	UILabel *itemLabel;
	UITextField *itemLabelTextField;
	UILabel *detailDescriptionLabel;
	BPTextView *textView;
	UIView *inputAccessoryView;
	BPItem *item;
	RootViewController *rootViewController;
	UIBarButtonItem *actionsButton;
	UIActionSheet *actionSheet;
	UIBarButtonItem *settingsButton;
	NSMutableDictionary *inputAccessoryViewCache;
	NSDictionary *inputAccessoryViewDefinition;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UILabel *itemLabel;
@property (nonatomic, retain) IBOutlet UITextField *itemLabelTextField;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *itemLabelBarButtonItem;
@property (nonatomic, retain) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, retain) IBOutlet BPTextView *textView;
@property (nonatomic, retain) IBOutlet UIView *inputAccessoryView;
@property (nonatomic, retain) IBOutlet BPItem *item;
@property (nonatomic, assign) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionsButton;
@property (nonatomic, retain) IBOutlet UIActionSheet *actionSheet;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *settingsButton;
@property (nonatomic, retain) NSDictionary *inputAccessoryViewDefinition;

- (void)setDetailItem:(BPItem*)item;
- (void)saveCurrentItem;
- (void)addNewFile:(NSNotification*)notification;
- (void)renameFile:(NSNotification*)notification;
- (void)addNewFolder:(NSNotification*)notification;
- (void)renameFolder:(NSNotification*)notification;
- (void)editItemLabel;
- (UIView*)inputAccessoryViewForItem:(BPItem*)item;
- (IBAction)actionsButtonPressed:(id)sender;
- (IBAction)settingsButtonPressed:(id)sender;

@end
