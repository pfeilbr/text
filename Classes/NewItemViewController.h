//
//  NewItemViewController.h
//  text
//
//  Created by Brian Pfeil on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPItemManager.h"

@interface NewItemViewController : UIViewController<UITextFieldDelegate> {
	ItemType itemType;
	UILabel *titleLabel;
	UILabel *messageLabel;
	UIBarButtonItem *okBarButtonItem;
	UIBarButtonItem *cancelBarButtonItem;
	NSString *titleText;
	UITextField *inputValueTextField;
	NSString *inputValueText;
	BOOL inputValueIsValid;
}

@property ItemType itemType;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *okBarButtonItem;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *cancelBarButtonItem;
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *messageLabel;
@property(nonatomic, retain) IBOutlet UITextField *inputValueTextField;
@property(nonatomic, copy) NSString *titleText;
@property(nonatomic, copy) NSString *inputValueText;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)okButtonPressed:(id)sender;

@end
