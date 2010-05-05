//
//  BPItem.h
//  text
//
//  Created by Brian Pfeil on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BPItem : NSObject {
	NSString *name;
	NSString *path;
	ItemType type;
}

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *path;
@property ItemType type;

- (NSString*)contents;
- (BOOL)isEqualToItem:(BPItem*)item;
- (NSComparisonResult)compare:(BPItem*)item;

@end
