//
//  BPColorManager.h
//  text
//
//  Created by Brian Pfeil on 9/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BPColorManager : NSObject {
	NSArray* colorDefinitions;
}

+ (BPColorManager*)sharedInstance;

- (NSArray*)colorNames;
- (NSArray*)colorDisplayNames;
- (NSArray*)colors;
- (UIColor*)colorFromColorName:(NSString*)colorName;

@property (nonatomic, readonly) NSArray* colorDefinitions;

@end
