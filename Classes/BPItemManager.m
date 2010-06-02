//
//  BPItemManager.m
//  text
//
//  Created by Brian Pfeil on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPItemManager.h"
#import "BPFileSystemItemStore.h"
#import "BPDropboxItemStore.h"

BPItemManager *sharedInstance = nil;

@interface BPItemManager()
- (NSString*)itemRootDirectory;
- (id)itemStoreForItem:(BPItem*)item;
- (id)itemStoreForStorageType:(NSString*)storageType;
@end


@implementation BPItemManager

@synthesize currentDisplayedDirectoryItem;

- (id)init {
	if (self = [super init]) {
		self.currentDisplayedDirectoryItem = [self rootItem];
	}
	return self;
}

+ (BPItemManager*)sharedInstance {
	if (sharedInstance == nil) {
		sharedInstance = [[[self class] alloc] init];
	}
	return sharedInstance;
}

- (void)dealloc {
	[currentDisplayedDirectoryItem release];
	[sharedInstance release];
	[super dealloc];
}

#pragma mark -
#pragma mark Item Creation

- (BPItem*)fileItem {
	BPItem *item = [[BPItem alloc] init];
	item.name = @"";
	item.path = @"";
	item.type = BPItemPropertyTypeFile;	
	return [item autorelease];
}

- (BPItem*)folderItem {
	BPItem *item = [[BPItem alloc] init];
	item.name = @"";
	item.path = @"";
	item.type = BPItemPropertyTypeFolder;	
	return [item autorelease];
}

- (BPItem*)fileItemFromPath:(NSString*)path storageType:(NSString*)storageType {
	BPItem *item = nil;
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	if (fileExists) {
		item = [self fileItem];
		item.name = [path lastPathComponent];
		item.path = path;
		item.storageType = storageType;
	}
	return item;
}

- (BPItem*)folderItemFromPath:(NSString*)path storageType:(NSString*)storageType {
	BPItem *item = nil;
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	if (fileExists) {
		item = [self folderItem];
		item.name = [path lastPathComponent];
		item.path = path;
		item.storageType = storageType;
	}
	return item;
}

- (BPItem*)createFileItemWithFileName:(NSString*)fileName atDirectoryPath:(NSString*)directoryPath storageType:(NSString*)storageType error:(NSError**)err {
	return [[self itemStoreForStorageType:storageType] createFileItemWithFileName:fileName atDirectoryPath:directoryPath error:err];
}

- (BPItem*)createFolderItemWithFolderName:(NSString*)folderName atDirectoryPath:(NSString*)directoryPath  storageType:(NSString*)storageType error:(NSError**)err {
	return [[self itemStoreForStorageType:storageType] createFolderItemWithFolderName:folderName atDirectoryPath:directoryPath error:err];	
}

#pragma mark -
#pragma mark Item Retrieval

- (NSString*)itemRootDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (BPItem*)rootItem {
	BPItem *item = [self folderItem];
	item.storageType = BPItemPropertyStorageTypeRoot;
	return item;
}

- (NSArray*)specialRootItems {
	BPItem *localRoot = [self folderItemFromPath:[self itemRootDirectory] storageType:BPItemPropertyStorageTypeLocalFileSystem];
	localRoot.storageType = BPItemPropertyStorageTypeLocalFileSystem;

	BPItem *dropboxRoot = [self folderItem];
	dropboxRoot.name = @"Dropbox";
	dropboxRoot.path = @"/";
	dropboxRoot.storageType = BPItemPropertyStorageTypeDropbox;
	
	NSMutableArray *items = [NSMutableArray arrayWithObjects:localRoot, dropboxRoot, nil];
	return items;
}

- (NSArray*)contentsOfDirectoryItem:(BPItem*)directoryItem filteredBySearchString:(NSString*)searchString {
	
	if ([currentDisplayedDirectoryItem.storageType isEqualToString:BPItemPropertyStorageTypeRoot]) {
		return [self specialRootItems];
	} else {
		return [[self itemStoreForItem:directoryItem] contentsOfDirectoryItem:directoryItem filteredBySearchString:searchString];		
	}

}

- (NSArray*)contentsOfDirectoryItem:(BPItem*)directoryItem {
	return [self contentsOfDirectoryItem:directoryItem filteredBySearchString:nil];
}

- (NSArray*)itemsForCurrentDisplayedDirectoryPath {
	return [self contentsOfDirectoryItem:currentDisplayedDirectoryItem];
}

- (NSArray*)itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:(NSString*)searchString {
	return [self contentsOfDirectoryItem:currentDisplayedDirectoryItem filteredBySearchString:searchString];
}

- (BPItem*)pushDirectoryItem:(BPItem*)directoryItem {
	
	if ([currentDisplayedDirectoryItem.storageType isEqualToString:BPItemPropertyStorageTypeRoot]) {
		self.currentDisplayedDirectoryItem = [[self specialRootItems] objectAtIndex:0];
	} else {
		self.currentDisplayedDirectoryItem = [self folderItemFromPath:[self.currentDisplayedDirectoryItem.path stringByAppendingPathComponent:directoryItem.name] storageType:directoryItem.storageType];
	}
	
	return currentDisplayedDirectoryItem;
}

- (BPItem*)popDirectoryItem {
	self.currentDisplayedDirectoryItem = [self folderItemFromPath:[self.currentDisplayedDirectoryItem.path stringByDeletingLastPathComponent] storageType:self.currentDisplayedDirectoryItem.storageType];
	return currentDisplayedDirectoryItem;
}

- (NSString*)nextDefaultFileNameAtDirectoryPath:(NSString*)directoryPath {
	BOOL foundUnusedFileName = NO;
	int counter = 1;
	NSString *currentPath = nil;
	NSString *currentFileName = nil;
	while (!foundUnusedFileName) {
		currentFileName = [NSString stringWithFormat:@"%@%d.txt", @"file", counter++];
		currentPath = [NSString stringWithFormat:@"%@/%@", directoryPath, currentFileName];
		foundUnusedFileName = ![[NSFileManager defaultManager] fileExistsAtPath:currentPath];
	}
	
	return currentFileName;
}

- (NSString*)nextDefaultFileNameForCurrentDisplayedDirectoryPath {
	return [self nextDefaultFileNameAtDirectoryPath:currentDisplayedDirectoryItem.path];
}

- (NSString*)nextDefaultFolderNameAtDirectoryPath:(NSString*)directoryPath {
	BOOL foundUnusedFileName = NO;
	int counter = 1;
	NSString *currentPath = nil;
	NSString *currentFileName = nil;
	while (!foundUnusedFileName) {
		currentFileName = [NSString stringWithFormat:@"%@%d", @"folder", counter++];
		currentPath = [NSString stringWithFormat:@"%@/%@", directoryPath, currentFileName];
		BOOL isDirectory;
		BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:currentPath isDirectory:&isDirectory];
		foundUnusedFileName = !exists || (exists && !isDirectory);
	}
	
	return currentFileName;
}

- (NSString*)nextDefaultFolderNameForCurrentDisplayedDirectoryPath {
	return [self nextDefaultFolderNameAtDirectoryPath:currentDisplayedDirectoryItem.path];
}

#pragma mark -
#pragma mark Item Manipulation

- (BOOL)saveItem:(BPItem*)item withText:(NSString*)text error:(NSError**)err {
	return [[self itemStoreForItem:item] saveItem:item withText:text error:err];	
}

- (BPItem*)moveItem:(BPItem*)item toPath:(NSString*)path error:(NSError**)err {
	return [[self itemStoreForItem:item] moveItem:item toPath:path error:err];
}

- (BOOL)deleteItem:(BPItem*)item error:(NSError**)err {
	return [[self itemStoreForItem:item] deleteItem:item error:err];
}

- (id)itemStoreForItem:(BPItem*)item {
	if ([item.storageType isEqualToString:BPItemPropertyStorageTypeLocalFileSystem]) {
		return [BPFileSystemItemStore sharedInstance];
	} else if ([item.storageType isEqualToString:BPItemPropertyStorageTypeDropbox]) {
		return [BPDropboxItemStore sharedInstance];
	} else {
		return nil;
	}
}

- (id)itemStoreForStorageType:(NSString*)storageType {
	if ([storageType isEqualToString:BPItemPropertyStorageTypeLocalFileSystem]) {
		return [BPFileSystemItemStore sharedInstance];
	} else if ([storageType isEqualToString:BPItemPropertyStorageTypeDropbox]) {
		return [BPDropboxItemStore sharedInstance];
	} else {
		return nil;
	}
}

@end
