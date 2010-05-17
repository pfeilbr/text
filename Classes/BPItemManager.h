//
//  BPItemManager.h
//  text
//
//  Created by Brian Pfeil on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPItem.h"
#import "DBRequest.h"
#import "DBRestClient.h"
#import "DBSession.h"

@interface BPItemManager : NSObject {
	NSString *currentDisplayedDirectoryPath;
}

@property(nonatomic, copy) NSString *currentDisplayedDirectoryPath;

+ (BPItemManager*)sharedInstance;
- (NSArray*)specialRootItems;
- (NSArray*)rootItems;
- (NSArray*)itemsForDirectoryAtPath:(NSString*)directoryAtPath;
- (NSArray*)itemsForCurrentDisplayedDirectoryPath;

- (BPItem*)fileItem;
- (BPItem*)folderItem;
- (BPItem*)fileItemFromPath:(NSString*)path;
- (BPItem*)folderItemFromPath:(NSString*)path;

- (NSArray*)itemsForDirectoryAtPath:(NSString*)directoryAtPath filteredBySearchString:(NSString*)searchString;
- (NSArray*)itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:(NSString*)searchString;

- (NSString*)pushDirectoryName:(NSString*)directoryName;
- (NSString*)popDirectoryName;

- (NSString*)nextDefaultFileNameAtDirectoryPath:(NSString*)directoryPath;
- (NSString*)nextDefaultFileNameForCurrentDisplayedDirectoryPath;

- (NSString*)nextDefaultFolderNameAtDirectoryPath:(NSString*)directoryPath;
- (NSString*)nextDefaultFolderNameForCurrentDisplayedDirectoryPath;

// item manipulation
- (BPItem*)createFileItemWithFileName:(NSString*)fileName atDirectoryPath:(NSString*)directoryPath;
- (BOOL)saveItem:(BPItem*)item withText:(NSString*)text error:(NSError**)err;
- (BPItem*)renameFileItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath;
- (BPItem*)moveItem:(BPItem*)item toPath:(NSString*)path;
- (BOOL)deleteItem:(BPItem*)item;
- (BPItem*)createFolderItemWithFolderName:(NSString*)folderName atDirectoryPath:(NSString*)directoryPath;
- (BPItem*)createDefaultFileItemAtCurrentDisplayedDirectoryPath;

@end
