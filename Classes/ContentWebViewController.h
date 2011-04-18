//
//  ContentWebViewController.h
//  text
//
//  Created by Brian Pfeil on 7/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentWebView.h"

@interface ContentWebViewController : UIViewController {
	ContentWebView* contentWebView;
}

@property(nonatomic, retain) IBOutlet ContentWebView* contentWebView;

-(IBAction)doneButtonClicked:(id)sender;

@end
