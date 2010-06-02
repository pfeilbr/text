//
//  BPFileSystemItemStore.m
//  text
//
//  Created by Brian Pfeil on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPFileSystemItemStore.h"

BPFileSystemItemStore *BPFileSystemItemStoreSharedInstance = nil;

@implementation BPFileSystemItemStore

+ (BPFileSystemItemStore*)sharedInstance {
	if (BPFileSystemItemStoreSharedInstance == nil) {
		BPFileSystemItemStoreSharedInstance = [[[self class] alloc] init];
	}
	return BPFileSystemItemStoreSharedInstance;
}

- (void)dealloc {
	[BPFileSystemItemStoreSharedInstance release];
	[super dealloc];
}

#pragma mark -
#pragma mark item creation

- (BPItem*)fileItemFromPath:(NSString*)path error:(NSError**)err {
	BPItem *item = nil;
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	if (fileExists) {
		item = [self fileItem];
		item.storageType = BPItemPropertyStorageTypeLocalFileSystem;
		item.name = [path lastPathComponent];
		item.path = path;
	}
	return item;
}

- (BPItem*)folderItemFromPath:(NSString*)path error:(NSError**)err {
	BPItem *item = nil;
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	if (fileExists) {
		item = [self folderItem];
		item.storageType = BPItemPropertyStorageTypeLocalFileSystem;
		item.name = [path lastPathComponent];
		item.path = path;
	}
	return item;
}

- (BPItem*)createFileItemWithFileName:(NSString*)fileName atDirectoryPath:(NSString*)directoryPath error:(NSError**)err {
	NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, fileName];
	NSData *data = [NSData data];
	BOOL fileCreated = [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
	if (fileCreated) {
		return [self fileItemFromPath:filePath error:err];
	} else {
		//TODO: error handling here
		return nil;
	}
}

- (BPItem*)createFolderItemWithFolderName:(NSString*)folderName atDirectoryPath:(NSString*)directoryPath error:(NSError**)err {
	NSString *fullDirectoryPath = [NSString stringWithFormat:@"%@/%@", directoryPath, folderName];
	BOOL directoryCreated = [[NSFileManager defaultManager] createDirectoryAtPath:fullDirectoryPath attributes:nil];
	if (directoryCreated) {
		return [self folderItemFromPath:fullDirectoryPath error:err];
	} else {
		//TODO: error handling here
		return nil;
	}
}

#pragma mark -
#pragma mark item operations

- (BOOL)saveItem:(BPItem*)item withText:(NSString*)text error:(NSError**)err {
	return [text writeToFile:item.path atomically:YES encoding:NSUTF8StringEncoding error:err];
}

- (BPItem*)moveItem:(BPItem*)item toPath:(NSString*)path error:(NSError**)err {

	BOOL moved = [[NSFileManager defaultManager] moveItemAtPath:item.path toPath:path error:err];
	if (!moved) {
		//TODO: add error logic
	}
	
	BPItem *newItem = nil;
	if ([item.type isEqualToString:BPItemPropertyTypeFile]) {
		newItem = [self fileItemFromPath:path error:err];
	} else if ([item.type isEqualToString:BPItemPropertyTypeFolder]) {
		newItem = [self folderItemFromPath:path error:err];
	}
	return newItem;
}

- (BOOL)deleteItem:(BPItem*)item error:(NSError**)err {
	return [[NSFileManager defaultManager] removeItemAtPath:item.path error:err];
}

#pragma mark -
#pragma mark item listing


- (NSArray*)contentsOfDirectoryItem:(BPItem*)directoryItem filteredBySearchString:(NSString*)searchString {
	NSMutableArray *items = [[NSMutableArray alloc] init];
	NSError *err;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryItem.path error:&err];
	for (NSString *fileName in contents) {
		if (searchString == nil
			|| [searchString isEqualToString:@""]
			|| [fileName rangeOfString:searchString options:NSRegularExpressionSearch].length > 0) { // regex search
			NSString *path = [NSString stringWithFormat:@"%@/%@", directoryItem.path, fileName];
			BOOL isDirectory;
			[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
			BPItem *item = nil;
			if	(isDirectory) {
				item = [self folderItemFromPath:path error:&err];
			} else {
				item = [self fileItemFromPath:path error:&err];
			}

			[items addObject:item];			
		}
	}
	[items sortUsingSelector:@selector(compare:)];
	return [items autorelease];	
}

@end
