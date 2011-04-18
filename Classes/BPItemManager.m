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

#import "BPFileSystemStorageClient.h"
#import "BPDropboxStorageClient.h"

static BPItemManager *sharedInstance = nil;
static BPItem* currentDisplayedDirectoryItem = nil;

@interface BPItemManager()

- (id)storageClientForItem:(BPItem*)item;
- (NSString*)itemRootDirectory;
- (id)itemStoreForItem:(BPItem*)item;
- (id)itemStoreForStorageType:(NSString*)storageType;

@property(nonatomic, retain) BPItem* rootItem;
@property (nonatomic, assign) BPItem* workingItem;
@property(nonatomic, retain) id<BPStorageClient> storageClient;
@property (nonatomic, readonly) NSArray* specialRootItems;

@end


@implementation BPItemManager

@synthesize currentDisplayedDirectoryItem, delegate, rootItem, workingItem, storageClient;

+(void) initialize {
    if (!currentDisplayedDirectoryItem) {
        
	}
}


+ (void)setCurrentDisplayedDirectoryItem:(BPItem*)item {
	currentDisplayedDirectoryItem = item;
}

+ (BPItem*)getCurrentDisplayedDirectoryItem {
	return currentDisplayedDirectoryItem;
}

- (id)init {
    self = [super init];
	if (self) {
		self.currentDisplayedDirectoryItem = [self rootItem];
		[[self class] setCurrentDisplayedDirectoryItem:[self rootItem]];
	}
	return self;
}

- (id)initWithItem:(BPItem*)item {
    self = [self init];
	if (self) {
		self.rootItem = item;
		self.storageClient = [self storageClientForItem:item];
		storageClient.delegate = self;
	}
	return self;
}

- (id)storageClientForItem:(BPItem*)item {
	id client = nil;
	if ([item.storageType isEqualToString:kBPItemStorageTypeRoot]) {
	} else if ([item.storageType isEqualToString:kBPItemStorageTypeFileSystem]) {
		client = [[BPFileSystemStorageClient alloc] init];
	} else if ([item.storageType isEqualToString:kBPItemStorageTypeDropbox]) {
		client = [[BPDropboxStorageClient alloc] init];
	}
	return [client autorelease];
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
	[storageClient release];
	[rootItem release];
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
	item = [self fileItem];
	item.name = [path lastPathComponent];
	item.path = path;
	item.storageType = storageType;
	return item;
}

- (BPItem*)folderItemFromPath:(NSString*)path storageType:(NSString*)storageType {
	BPItem *item = nil;
	item = [self folderItem];
	item.name = [path lastPathComponent];
	item.path = path;
	item.storageType = storageType;
	return item;
}

- (void)createFileItemWithFileName:(NSString*)fileName atDirectoryPath:(NSString*)directoryPath storageType:(NSString*)storageType
{
    NSString* emptyFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"empty.txt"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:emptyFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:emptyFilePath contents:nil attributes:nil];
    }
    
    NSString* path = [directoryPath stringByAppendingPathComponent:fileName];
    [storageClient createFile:path fromPath:emptyFilePath];
}

- (void)createFolderItemWithFolderName:(NSString*)folderName atDirectoryPath:(NSString*)directoryPath  storageType:(NSString*)storageType {
    NSString* path = [directoryPath stringByAppendingPathComponent:folderName];
    [storageClient createFolder:path];
}

#pragma mark -
#pragma mark Item Retrieval

- (NSString*)itemRootDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (BPItem*)rootItem {
	BPItem *item = [self folderItem];
	item.storageType = kBPItemStorageTypeRoot;
	return item;
}

- (NSArray*)specialRootItems {
	BPItem *localRoot = [self folderItemFromPath:[self itemRootDirectory] storageType:kBPItemStorageTypeFileSystem];
	localRoot.storageType = kBPItemStorageTypeFileSystem;

	BPItem *dropboxRoot = [self folderItem];
	dropboxRoot.name = @"Dropbox";
	dropboxRoot.path = @"/";
	dropboxRoot.storageType = kBPItemStorageTypeDropbox;
	
	NSMutableArray *items = [NSMutableArray arrayWithObjects:localRoot, dropboxRoot, nil];
	return items;
}

- (void)loadDirectoryItemContents:(BPItem*)directoryItem {
	self.workingItem = directoryItem;
	
	if ([directoryItem.storageType isEqualToString:kBPItemStorageTypeRoot]) {
		if ([delegate respondsToSelector:@selector(itemManager:loadedDirectoryItem:contents:)]) {
			[delegate itemManager:self loadedDirectoryItem:self.workingItem contents:self.specialRootItems];
		}
	} else {
		[storageClient loadMetadata:directoryItem.path];
	}	
}

- (void)loadItem:(BPItem*)item {
	self.workingItem = item;
	[storageClient loadFile:item.path];
}

#pragma mark -
#pragma mark BPStorageClientDelegate

- (void)storageClient:(id<BPStorageClient>)_storageClient loadedMetadata:(NSDictionary*)metadata {
	NSString* directoryPath = [metadata valueForKey:@"path"];
	NSArray* contents = [metadata valueForKey:@"contents"];

	if ([delegate respondsToSelector:@selector(itemManager:loadedDirectoryItem:contents:)]) {		
		NSMutableArray* items = [[NSMutableArray alloc] init];
		
		if ([_storageClient.storageType isEqualToString:kBPItemStorageTypeFileSystem]) {
			for (NSString* fileName in contents){
				NSString *path = [NSString stringWithFormat:@"%@/%@", directoryPath, fileName];
				
				BOOL isDirectory;
				[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
				BPItem *item = nil;
				if	(isDirectory) {
					item = [self folderItemFromPath:path storageType:_storageClient.storageType];
				} else {
					item = [self fileItemFromPath:path storageType:_storageClient.storageType];
				}
				[items addObject:item];
			}
		}

		if ([_storageClient.storageType isEqualToString:kBPItemStorageTypeDropbox]) {
			for (DBMetadata* metadata in contents) {
				NSString* path = metadata.path;
				BOOL isDirectory = metadata.isDirectory;
				BPItem *item = nil;
				if	(isDirectory) {
					item = [self folderItemFromPath:path storageType:_storageClient.storageType];
				} else {
					item = [self fileItemFromPath:path storageType:_storageClient.storageType];
				}
				item.iconName = metadata.icon;
				[items addObject:item];
			}
		}
		
		[items sortUsingSelector:@selector(compare:)];
		
		[delegate itemManager:self loadedDirectoryItem:self.workingItem contents:[items autorelease]];
	}
}

- (void)storageClient:(id<BPStorageClient>)_storageClient loadMetadataFailedWithError:(NSError*)error {
	if ([delegate respondsToSelector:@selector(itemManager:loadDirectoryItemContentsFailedWithError:)]) {
		[delegate itemManager:self loadDirectoryItemContentsFailedWithError:error];
	}	
}

- (void)storageClient:(id<BPStorageClient>)_storageClient createdFile:(NSString*)path {
    if ([delegate respondsToSelector:@selector(itemManager:createdFileItem:)]) {
        BPItem* item = [self fileItemFromPath:path storageType:_storageClient.storageType];
        [delegate itemManager:self createdFileItem:item];
    }
}

- (void)storageClient:(id<BPStorageClient>)_storageClient createFileFailedWithError:(NSError*)error {
	if ([delegate respondsToSelector:@selector(itemManager:createFileFailedWithError:)]) {
		[delegate itemManager:self createFileItemFailedWithError:error];
	}	
}

- (void)storageClient:(id<BPStorageClient>)_storageClient createdFolder:(NSString*)folder {
    if ([delegate respondsToSelector:@selector(itemManager:createdFolderItem:)]) {
        BPItem* item = [self folderItemFromPath:folder storageType:_storageClient.storageType];
        [delegate itemManager:self createdFolderItem:item];
    }
}

- (void)storageClient:(id<BPStorageClient>)_storageClient createFolderFailedWithError:(NSError*)error {
	if ([delegate respondsToSelector:@selector(itemManager:createFolderItemFailedWithError:)]) {
		[delegate itemManager:self createFolderItemFailedWithError:error];
	}	
}

- (void)storageClient:(id<BPStorageClient>)_storageClient loadedFile:(NSString*)path data:(NSData*)data {
	if ([delegate respondsToSelector:@selector(itemManager:loadedItem:data:)]) {
		[delegate itemManager:self loadedItem:self.workingItem data:data];
	}
}

- (void)storageClient:(id<BPStorageClient>)_storageClient loadFileFailedWithError:(NSError*)error {
	if ([delegate respondsToSelector:@selector(itemManager:loadItem:failedWithError:)]) {
		[delegate itemManager:self loadItem:self.workingItem failedWithError:error];
	}	
}

- (void)storageClient:(id<BPStorageClient>)_storageClient deletedPath:(NSString*)path {
	if ([delegate respondsToSelector:@selector(itemManager:deletedItem:)]) {
		[delegate itemManager:self deletedItem:self.workingItem];
	}
}

- (void)storageClient:(id<BPStorageClient>)_storageClient deletePathFailedWithError:(NSError*)error {
	if ([delegate respondsToSelector:@selector(itemManager:deleteItem:failedWithError:)]) {
		[delegate itemManager:self deleteItem:self.workingItem failedWithError:error];
	}	
}

- (void)storageClient:(id<BPStorageClient>)_storageClient copiedPath:(NSString*)fromPath toPath:(NSString*)toPath {
	NSLog(@"%s", __FUNCTION__);
}

- (void)storageClient:(id<BPStorageClient>)_storageClient copyPathFailedWithError:(NSError*)error {
	NSLog(@"%s", __FUNCTION__);
}

- (void)storageClient:(id<BPStorageClient>)_storageClient movedPath:(NSString*)fromPath toPath:(NSString*)toPath {
	NSLog(@"%s", __FUNCTION__);
}

- (void)storageClient:(id<BPStorageClient>)_storageClient movePathFailedWithError:(NSError*)error {
	NSLog(@"%s", __FUNCTION__);
}


- (NSArray*)contentsOfDirectoryItem:(BPItem*)directoryItem filteredBySearchString:(NSString*)searchString {
	
	if ([currentDisplayedDirectoryItem.storageType isEqualToString:kBPItemStorageTypeRoot]) {
		return self.specialRootItems;
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
	
	if ([currentDisplayedDirectoryItem.storageType isEqualToString:kBPItemStorageTypeRoot]) {
		int index = 0;
		NSArray* rootItems = self.specialRootItems;
		for (BPItem* item in rootItems) {
			if ([item.storageType isEqualToString:directoryItem.storageType]) {
				break;
			}
			index++;
		}
		self.currentDisplayedDirectoryItem = [self.specialRootItems objectAtIndex:index];
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

- (void)saveItem:(BPItem*)item withText:(NSString*)text {
    NSString* tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.txt"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:tempFilePath contents:[text dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    [storageClient createFile:item.path fromPath:tempFilePath];
}

- (BPItem*)moveItem:(BPItem*)item toPath:(NSString*)path error:(NSError**)err {
	return [[self itemStoreForItem:item] moveItem:item toPath:path error:err];
}

- (void)deleteItem:(BPItem*)item {
    self.workingItem = item;
    [storageClient deletePath:item.path];
}

- (id)itemStoreForItem:(BPItem*)item {
	if ([item.storageType isEqualToString:kBPItemStorageTypeFileSystem]) {
		return [BPFileSystemItemStore sharedInstance];
	} else if ([item.storageType isEqualToString:kBPItemStorageTypeDropbox]) {
		return [BPDropboxItemStore sharedInstance];
	} else {
		return nil;
	}
}

- (id)itemStoreForStorageType:(NSString*)storageType {
	if ([storageType isEqualToString:kBPItemStorageTypeFileSystem]) {
		return [BPFileSystemItemStore sharedInstance];
	} else if ([storageType isEqualToString:kBPItemStorageTypeDropbox]) {
		return [BPDropboxItemStore sharedInstance];
	} else {
		return nil;
	}
}

@end
