//
//  BPItem.m
//  text
//
//  Created by Brian Pfeil on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPItem.h"


@implementation BPItem

@synthesize type, name, path;

- (NSString*)directoryPath {
	NSString *_path = nil;
	if ([type isEqualToString:BPItemPropertyTypeFile]) {
		_path = [path stringByDeletingLastPathComponent];
	} else if ([type isEqualToString:BPItemPropertyTypeFolder]) {
		_path = path;
	}
	return _path;
}

- (NSString*)contents {
	NSError *err;
	return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
}

- (BOOL)isEqualToItem:(BPItem*)item {
	return [path isEqualToString:item.path];
}

- (NSComparisonResult)compare:(BPItem*)item {
	if (self.type == item.type) {
		return [self.name compare:item.name options:NSCaseInsensitiveSearch];
	} else {
		if ([self.type isEqualToString:BPItemPropertyTypeFolder]) {
			return NSOrderedAscending;
		} else {
			return NSOrderedDescending;
		}
	}
}

- (BPItem*)itemFromDictionary:(NSDictionary*)dictionaryRepresentation {
	BPItem *item = [[BPItem alloc] init];
	item.type = [dictionaryRepresentation valueForKey:BPItemPropertyType];
	item.name = [dictionaryRepresentation valueForKey:BPItemPropertyName];
	item.path = [dictionaryRepresentation valueForKey:BPItemPropertyPath];
	return item;
}

- (NSDictionary*)dictionaryRepresentation {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setValue:type forKey:BPItemPropertyType];
	[dict setValue:name forKey:BPItemPropertyName];
	[dict setValue:path forKey:BPItemPropertyPath];
	return dict;
}

@end
