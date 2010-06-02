//
//  BPBaseItemStore.m
//  text
//
//  Created by Brian Pfeil on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPBaseItemStore.h"


@implementation BPBaseItemStore

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

@end
