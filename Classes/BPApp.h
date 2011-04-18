//
//  BPApp.h
//  text
//
//  Created by Brian Pfeil on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPMetadata.h"

@interface BPApp : NSObject {
	BPMetadata* metadata;
}

+ (BPApp*)sharedInstance;

- (NSString*)getSmallIconImagePathForIconNamed:(NSString*)iconName;
- (NSString*)getLargeIconImagePathForIconNamed:(NSString*)iconName;

@property (nonatomic, readonly) NSArray* fontSizeDefinitions;

@end
