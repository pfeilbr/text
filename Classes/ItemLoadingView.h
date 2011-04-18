//
//  ItemLoadingView.h
//  text
//
//  Created by Brian Pfeil on 11/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ItemLoadingView : UIView {
	UIImageView* imageView;
	UILabel* label;
	UIProgressView* progressView;
}

@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UILabel* label;
@property (nonatomic, retain) IBOutlet UIProgressView* progressView;

@end
