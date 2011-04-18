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
#import "BPBaseStorageClient.h"

@protocol BPItemManagerDelegate;

@interface BPItemManager : NSObject<BPStorageClientDelegate> {
	id<BPItemManagerDelegate> delegate;
	id<BPStorageClient> storageClient;
	BPItem* rootItem;
	BPItem* currentDisplayedDirectoryItem;
	BPItem* workingItem;
}

@property (nonatomic, assign) id<BPItemManagerDelegate> delegate;
@property (nonatomic, retain) BPItem *currentDisplayedDirectoryItem;

+ (void)setCurrentDisplayedDirectoryItem:(BPItem*)item;
+ (BPItem*)getCurrentDisplayedDirectoryItem;

+ (BPItemManager*)sharedInstance;
- (BPItem*)rootItem;
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

- (id)initWithItem:(BPItem*)item;

- (void)loadDirectoryItemContents:(BPItem*)directoryItem;
- (void)loadItem:(BPItem*)item;

// item manipulation
- (void)createFileItemWithFileName:(NSString*)fileName atDirectoryPath:(NSString*)directoryPath storageType:(NSString*)storageType;
- (void)createFolderItemWithFolderName:(NSString*)folderName atDirectoryPath:(NSString*)directoryPath  storageType:(NSString*)storageType;
- (void)saveItem:(BPItem*)item withText:(NSString*)text;
- (BPItem*)moveItem:(BPItem*)item toPath:(NSString*)path error:(NSError**)err;
- (void)deleteItem:(BPItem*)item;


@end

@protocol BPItemManagerDelegate <NSObject>
@optional
- (void)itemManager:(BPItemManager*)itemManager loadedDirectoryItem:(BPItem*)directoryItem contents:(NSArray*)items;
- (void)itemManager:(BPItemManager*)itemManager loadDirectoryItemContentsFailedWithError:(NSError*)error;

- (void)itemManager:(BPItemManager*)itemManager loadedItem:(BPItem*)item data:(NSData*)data;
- (void)itemManager:(BPItemManager*)itemManager loadItemFailedWithError:(NSError*)error;

- (void)itemManager:(BPItemManager*)itemManager createdFileItem:(BPItem*)item;
- (void)itemManager:(BPItemManager*)itemManager createFileItemFailedWithError:(NSError*)error;

- (void)itemManager:(BPItemManager*)itemManager createdFolderItem:(BPItem*)item;
- (void)itemManager:(BPItemManager*)itemManager createFolderItemFailedWithError:(NSError*)error;

- (void)itemManager:(BPItemManager*)itemManager savedItem:(BPItem*)item;
- (void)itemManager:(BPItemManager*)itemManager saveItem:(BPItem*)item failedWithError:(NSError*)error;

- (void)itemManager:(BPItemManager*)itemManager movedItem:(BPItem*)item;
- (void)itemManager:(BPItemManager*)itemManager moveItem:(BPItem*)item failedWithError:(NSError*)error;

- (void)itemManager:(BPItemManager*)itemManager deletedItem:(BPItem*)item;
- (void)itemManager:(BPItemManager*)itemManager deleteItem:(BPItem*)item failedWithError:(NSError*)error;


@end

