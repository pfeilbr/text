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

- (void)dealloc {
	[currentDisplayedDirectoryPath release];
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

- (BPItem*)fileItemFromPath:(NSString*)path {
	BPItem *item = nil;
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	if (fileExists) {
		item = [self fileItem];
		item.name = [path lastPathComponent];
		item.path = path;
	}
	return item;
}

- (BPItem*)folderItemFromPath:(NSString*)path {
	BPItem *item = nil;
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	if (fileExists) {
		item = [self folderItem];
		item.name = [path lastPathComponent];
		item.path = path;
	}
	return item;
}

- (BPItem*)createFileItemWithFileName:(NSString*)fileName atDirectoryPath:(NSString*)directoryPath {
	NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, fileName];
	NSData *data = [NSData data];
	BOOL fileCreated = [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
	if (fileCreated) {
		return [self fileItemFromPath:filePath];
	} else {
		//TODO: error handling here
		return nil;
	}
}

- (BPItem*)createFolderItemWithFolderName:(NSString*)folderName atDirectoryPath:(NSString*)directoryPath {
	NSString *fullDirectoryPath = [NSString stringWithFormat:@"%@/%@", directoryPath, folderName];
	BOOL directoryCreated = [[NSFileManager defaultManager] createDirectoryAtPath:fullDirectoryPath attributes:nil];
	if (directoryCreated) {
		return [self folderItemFromPath:fullDirectoryPath];
	} else {
		//TODO: error handling here
		return nil;
	}
}

- (BPItem*)createDefaultFileItemAtCurrentDisplayedDirectoryPath {
	NSString *fileName = [self nextDefaultFileNameForCurrentDisplayedDirectoryPath];
	return [self createFileItemWithFileName:fileName atDirectoryPath:currentDisplayedDirectoryPath];
}


#pragma mark -
#pragma mark Item Retrieval

- (NSString*)itemRootDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSArray*)rootItems {
	NSString *rootDirectory = [self itemRootDirectory];
	return [self itemsForDirectoryAtPath:rootDirectory];
}

- (NSArray*)specialRootItems {
	BPItem *localRoot = [self folderItemFromPath:[self itemRootDirectory]];
	BPItem *dropboxRoot = [self folderItemFromPath:[self itemRootDirectory]];
	NSMutableArray *items = [NSMutableArray arrayWithObjects:localRoot, dropboxRoot, nil];
	return [items autorelease];
}

- (NSArray*)itemsForDirectoryAtPath:(NSString*)directoryAtPath filteredBySearchString:(NSString*)searchString {
	NSMutableArray *items = [[NSMutableArray alloc] init];
	NSError *err;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryAtPath error:&err];
	for (NSString *fileName in contents) {
		if (searchString == nil
			|| [searchString isEqualToString:@""]
			|| [fileName rangeOfString:searchString options:NSRegularExpressionSearch].length > 0) { // regex search
			BPItem *item = [[[BPItem alloc] init] autorelease];
			item.name = fileName;
			item.path = [NSString stringWithFormat:@"%@/%@", directoryAtPath, fileName];
			BOOL isDirectory;
			[[NSFileManager defaultManager] fileExistsAtPath:item.path isDirectory:&isDirectory];
			item.type = isDirectory ? BPItemPropertyTypeFolder : BPItemPropertyTypeFile;
			[items addObject:item];			
		}
	}
	[items sortUsingSelector:@selector(compare:)];
	return [items autorelease];	
}

- (NSArray*)itemsForDirectoryAtPath:(NSString*)directoryAtPath {
	return [self itemsForDirectoryAtPath:directoryAtPath filteredBySearchString:nil];
}

- (NSArray*)itemsForCurrentDisplayedDirectoryPath {
	return [self itemsForDirectoryAtPath:currentDisplayedDirectoryPath];
}

- (NSArray*)itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:(NSString*)searchString {
	return [self itemsForDirectoryAtPath:currentDisplayedDirectoryPath filteredBySearchString:searchString];
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

#pragma mark -
#pragma mark Item Manipulation

- (BOOL)saveItem:(BPItem*)item withText:(NSString*)text error:(NSError**)err {
	return [text writeToFile:item.path atomically:YES encoding:NSUTF8StringEncoding error:err];
}

- (BPItem*)renameFileItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
	NSError *err;
	[[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:&err];
	return [self fileItemFromPath:toPath];
}

- (BPItem*)moveItem:(BPItem*)item toPath:(NSString*)path {
	NSError *err;
	BOOL moved = [[NSFileManager defaultManager] moveItemAtPath:item.path toPath:path error:&err];
	if (!moved) {
		//TODO: add error logic
	}
	
	BPItem *newItem = nil;
	if ([item.type isEqualToString:BPItemPropertyTypeFile]) {
		newItem = [self fileItemFromPath:path];
	} else if ([item.type isEqualToString:BPItemPropertyTypeFolder]) {
		newItem = [self folderItemFromPath:path];
	}
	return newItem;
}

- (BOOL)deleteItem:(BPItem*)item {
	NSError *err;
	return [[NSFileManager defaultManager] removeItemAtPath:item.path error:&err];
}

@end
