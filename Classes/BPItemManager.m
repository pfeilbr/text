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
	return items;
}

- (BOOL)saveItem:(BPItem*)item withText:(NSString*)text error:(NSError**)err {
	return [text writeToFile:item.path atomically:YES encoding:NSUTF8StringEncoding error:err];
}

@end
