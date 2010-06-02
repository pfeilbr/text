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
	BPItem *currentDisplayedDirectoryItem;
}

@property(nonatomic, retain) BPItem *currentDisplayedDirectoryItem;

+ (BPItemManager*)sharedInstance;
- (BPItem*)rootItem;
- (NSArray*)specialRootItems;
- (NSArray*)contentsOfDirectoryItem:(BPItem*)directoryItem;
- (NSArray*)itemsForCurrentDisplayedDirectoryPath;

- (BPItem*)fileItem;
- (BPItem*)folderItem;
- (BPItem*)fileItemFromPath:(NSString*)path storageType:(NSString*)storageType;
- (BPItem*)folderItemFromPath:(NSString*)path storageType:(NSString*)storageType;

- (NSArray*)contentsOfDirectoryItem:(BPItem*)directoryItem filteredBySearchString:(NSString*)searchString;
- (NSArray*)itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:(NSString*)searchString;

- (BPItem*)pushDirectoryItem:(BPItem*)directoryItem;
- (BPItem*)popDirectoryItem;

- (NSString*)nextDefaultFileNameAtDirectoryPath:(NSString*)directoryPath;
- (NSString*)nextDefaultFileNameForCurrentDisplayedDirectoryPath;

- (NSString*)nextDefaultFolderNameAtDirectoryPath:(NSString*)directoryPath;
- (NSString*)nextDefaultFolderNameForCurrentDisplayedDirectoryPath;

// item manipulation
- (BPItem*)createFileItemWithFileName:(NSString*)fileName atDirectoryPath:(NSString*)directoryPath storageType:(NSString*)storageType error:(NSError**)err;
- (BPItem*)createFolderItemWithFolderName:(NSString*)folderName atDirectoryPath:(NSString*)directoryPath  storageType:(NSString*)storageType error:(NSError**)err;
- (BOOL)saveItem:(BPItem*)item withText:(NSString*)text error:(NSError**)err;
- (BPItem*)moveItem:(BPItem*)item toPath:(NSString*)path error:(NSError**)err;
- (BOOL)deleteItem:(BPItem*)item error:(NSError**)err;


@end
