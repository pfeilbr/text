//
//  GenericPickerViewController.h
//  text
//
//  Created by Brian Pfeil on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GenericPickerViewController : UITableViewController {
	NSArray* items;
	void (^onPickCompleteBlock)(NSDictionary*);
}

@property (nonatomic, retain) NSArray* items;
@property (nonatomic, retain) void (^onPickCompleteBlock)(NSDictionary*);

@end
