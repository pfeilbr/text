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
	NSString *currentDisplayedDirectoryPath;
}

@property(nonatomic, copy) NSString *currentDisplayedDirectoryPath;

+ (BPItemManager*)sharedInstance;
- (NSArray*)rootItems;
- (NSArray*)itemsForDirectoryAtPath:(NSString*)directoryAtPath;
- (NSArray*)itemsForCurrentDisplayedDirectoryPath;
- (BPItem*)createFileItemWithFileName:(NSString*)fileName atDirectoryPath:(NSString*)directoryPath;
- (BOOL)saveItem:(BPItem*)item withText:(NSString*)text error:(NSError**)err;
- (BOOL)deleteItem:(BPItem*)item;
- (BPItem*)fileItemFromPath:(NSString*)path;

- (NSString*)pushDirectoryName:(NSString*)directoryName;
- (NSString*)popDirectoryName;

- (NSString*)nextDefaultFileNameAtDirectoryPath:(NSString*)directoryPath;
- (NSString*)nextDefaultFileNameForCurrentDisplayedDirectoryPath;

- (BPItem*)createDefaultFileItemAtCurrentDisplayedDirectoryPath;
- (BPItem*)renameFileItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath;


@end
