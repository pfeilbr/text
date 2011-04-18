//
//  ColorPickerViewController.h
//  text
//
//  Created by Brian Pfeil on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPColorManager.h"

@interface ColorPickerViewController : UITableViewController {
	BPColorManager* colorManager;
	void (^onPickCompleteBlock)(NSDictionary*);
}

@property (nonatomic, retain) void (^onPickCompleteBlock)(NSDictionary*);

@end
