//
//  BPTextView.m
//  text
//
//  Created by Brian Pfeil on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPTextView.h"


@implementation BPTextView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (NSString*)emailText {
	return [self text];
}

- (NSString*)clipboardText {
	return [self text];	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
