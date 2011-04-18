//
//  BPItem.h
//  text
//
//  Created by Brian Pfeil on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BPItem : NSObject {
	NSString* storageType;
	NSString* type;
	NSString* iconName;
	NSString* name;
	NSString* path;
}

@property(nonatomic, copy) NSString* storageType;
@property(nonatomic, copy) NSString* type;
@property(nonatomic, copy) NSString* iconName;
@property(nonatomic, copy) NSString* name;
@property(nonatomic, copy) NSString* path;

- (NSString*)directoryPath;
- (NSString*)contents;
- (BOOL)isEqualToItem:(BPItem*)item;
- (NSComparisonResult)compare:(BPItem*)item;
- (BPItem*)itemFromDictionary:(NSDictionary*)dictionaryRepresentation;
- (NSDictionary*)dictionaryRepresentation;

@end
