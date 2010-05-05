//
//  NewItemViewController.h
//  text
//
//  Created by Brian Pfeil on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPItemManager.h"

@interface NewItemViewController : UIViewController {
	ItemType itemType;
	UILabel *titleLabel;
	NSString *titleText;
	UITextField *inputValueTextField;
	NSString *inputValueText;
}

@property ItemType itemType;
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UITextField *inputValueTextField;
@property(nonatomic, copy) NSString *titleText;
@property(nonatomic, copy) NSString *inputValueText;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)okButtonPressed:(id)sender;

@end
