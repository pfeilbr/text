//
//  BPItemManager.h
//  text
//
//  Created by Brian Pfeil on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPItem.h"


@interface BPItemManager : NSObject {

}

+ (BPItemManager*)sharedInstance;

- (NSArray*)rootItems;
- (NSArray*)itemsForDirectoryAtPath:(NSString*)directoryAtPath;

- (BOOL)saveItem:(BPItem*)item withText:(NSString*)text error:(NSError**)err;


@end
