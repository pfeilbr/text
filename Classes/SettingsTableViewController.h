//
//  SettingsTableViewController.h
//  text
//
//  Created by Brian Pfeil on 5/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPMetadata.h"
#import "GenericPickerViewController.h"
#import "ColorPickerViewController.h"
#import "ARFontPickerViewController.h"
#import "DropboxSDK.h"


@interface SettingsTableViewController : UITableViewController<ARFontPickerViewControllerDelegate, DBLoginControllerDelegate> {
	NSDictionary* settingsMetadata;
}


@end
