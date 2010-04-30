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

@class RootViewController;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    
    NSManagedObject *detailItem;
    UILabel *detailDescriptionLabel;
	BPTextView *textView;
	
    RootViewController *rootViewController;
    UIBarButtonItem *actionsButton;
	UIActionSheet *actionSheet;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) NSManagedObject *detailItem;
@property (nonatomic, retain) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, retain) IBOutlet BPTextView *textView;

@property (nonatomic, assign) IBOutlet RootViewController *rootViewController;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionsButton;
@property (nonatomic, retain) IBOutlet UIActionSheet *actionSheet;

- (IBAction)insertNewObject:(id)sender;

- (IBAction)actionsButtonPressed:(id)sender;

@end
