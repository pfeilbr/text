//
//  BPItem.m
//  text
//
//  Created by Brian Pfeil on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPItem.h"


@implementation BPItem

@synthesize name, path, type;

- (NSString*)contents {
	NSError *err;
	return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
}

@end
