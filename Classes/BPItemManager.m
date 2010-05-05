//
//  BPItemManager.m
//  text
//
//  Created by Brian Pfeil on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPItemManager.h"

BPItemManager *sharedInstance = nil;

@interface BPItemManager()
- (NSString*)itemRootDirectory;
@end


@implementation BPItemManager

@synthesize currentDisplayedDirectoryPath;

- (id)init {
	if (self = [super init]) {
		self.currentDisplayedDirectoryPath = [self itemRootDirectory];
	}
	return self;
}

+ (BPItemManager*)sharedInstance {
	if (sharedInstance == nil) {
		sharedInstance = [[[self class] alloc] init];
	}
	return sharedInstance;
}

- (NSString*)itemRootDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSArray*)rootItems {
	NSString *rootDirectory = [self itemRootDirectory];
	return [self itemsForDirectoryAtPath:rootDirectory];
}

- (NSArray*)itemsForDirectoryAtPath:(NSString*)directoryAtPath {
	NSMutableArray *items = [[NSMutableArray alloc] init];
	NSError *err;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryAtPath error:&err];
	for (NSString *fileName in contents) {
		BPItem *item = [[[BPItem alloc] init] autorelease];
		item.name = fileName;
		item.path = [NSString stringWithFormat:@"%@/%@", directoryAtPath, fileName];
		BOOL isDirectory;
		[[NSFileManager defaultManager] fileExistsAtPath:item.path isDirectory:&isDirectory];
		item.type = isDirectory ? kItemTypeFolder : kItemTypeFile;
		[items addObject:item];
	}
	[items sortUsingSelector:@selector(compare:)];
	return items;
}

- (NSArray*)itemsForCurrentDisplayedDirectoryPath {
	return [self itemsForDirectoryAtPath:currentDisplayedDirectoryPath];
}

- (BPItem*)createFileItemWithFileName:(NSString*)fileName atDirectoryPath:(NSString*)directoryPath {
	NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, fileName];
	NSData *data = [NSData data];
	BOOL fileCreated = [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
	BPItem *item = nil;
	if (fileCreated) {
		item = [[BPItem alloc] init];
		item.name = fileName;
		item.path = [NSString stringWithFormat:@"%@/%@", directoryPath, fileName];
		item.type = kItemTypeFile;
	}
	return item;
}

- (BPItem*)createFolderItemWithFolderName:(NSString*)folderName atDirectoryPath:(NSString*)directoryPath {
	NSString *fullDirectoryPath = [NSString stringWithFormat:@"%@/%@", directoryPath, folderName];
	BOOL directoryCreated = [[NSFileManager defaultManager] createDirectoryAtPath:fullDirectoryPath attributes:nil];
	BPItem *item = nil;
	if (directoryCreated) {
		item = [[BPItem alloc] init];
		item.name = folderName;
		item.path = fullDirectoryPath;
		item.type = kItemTypeFolder;
	}
	return item;
}

- (BPItem*)fileItemFromPath:(NSString*)path {
	BPItem *item = nil;
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	if (fileExists) {
		item = [[BPItem alloc] init];
		item.name = [path lastPathComponent];
		item.path = path;
		item.type = kItemTypeFile;
	}
	return item;	
}

- (BPItem*)createDefaultFileItemAtCurrentDisplayedDirectoryPath {
	NSString *fileName = [self nextDefaultFileNameForCurrentDisplayedDirectoryPath];
	return [self createFileItemWithFileName:fileName atDirectoryPath:currentDisplayedDirectoryPath];
}

- (BOOL)saveItem:(BPItem*)item withText:(NSString*)text error:(NSError**)err {
	return [text writeToFile:item.path atomically:YES encoding:NSUTF8StringEncoding error:err];
}

- (BOOL)deleteItem:(BPItem*)item {
	NSError *err;
	return [[NSFileManager defaultManager] removeItemAtPath:item.path error:&err];
}

- (NSString*)pushDirectoryName:(NSString*)directoryName {
	self.currentDisplayedDirectoryPath = [self.currentDisplayedDirectoryPath stringByAppendingPathComponent:directoryName];
	return currentDisplayedDirectoryPath;
}

- (NSString*)popDirectoryName {
	self.currentDisplayedDirectoryPath = [currentDisplayedDirectoryPath stringByDeletingLastPathComponent];
	return currentDisplayedDirectoryPath;
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
	return [self nextDefaultFileNameAtDirectoryPath:currentDisplayedDirectoryPath];
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
	return [self nextDefaultFolderNameAtDirectoryPath:currentDisplayedDirectoryPath];
}


- (BPItem*)renameFileItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
	NSError *err;
	[[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:&err];
	return [self fileItemFromPath:toPath];
}

@end
