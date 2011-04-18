//
//  ItemLoadingView.m
//  text
//
//  Created by Brian Pfeil on 11/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ItemLoadingView.h"


@implementation ItemLoadingView

@synthesize imageView;
@synthesize label;
@synthesize progressView;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
