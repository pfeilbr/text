//
//  BPApp.m
//  text
//
//  Created by Brian Pfeil on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPApp.h"

static BPApp* BPAppSharedInstance = nil;

@interface BPApp ()

@property (nonatomic, assign) BPMetadata* metadata;

@end


@implementation BPApp

@synthesize metadata, fontSizeDefinitions;

+ (BPApp*)sharedInstance {
	if (!BPAppSharedInstance) {
		BPAppSharedInstance = [[[self class] alloc] init];
	}
	return BPAppSharedInstance;
}

- (id)init {
	if (self = [super init]) {
		self.metadata = [BPMetadata sharedInstance];
	}
	return self;
}

- (NSString*)getSmallIconImagePathForIconNamed:(NSString*)iconName {
	NSString* bundleDirectoryPath = [[NSBundle mainBundle] bundlePath];
	NSString* iconDirectory = [bundleDirectoryPath stringByAppendingPathComponent:kDropboxSmallIconsBaseDirectoryName];
	NSString* iconFileName = [NSString stringWithFormat:@"%@.gif", iconName];
	NSString* iconImagePath = [iconDirectory stringByAppendingPathComponent:iconFileName];
	return iconImagePath;
}

- (NSString*)getLargeIconImagePathForIconNamed:(NSString*)iconName {
	NSString* bundleDirectoryPath = [[NSBundle mainBundle] bundlePath];
	NSString* iconDirectory = [bundleDirectoryPath stringByAppendingPathComponent:kDropboxLargeIconsBaseDirectoryName];
	NSString* iconFileName = [NSString stringWithFormat:@"%@48.gif", iconName];
	NSString* iconImagePath = [iconDirectory stringByAppendingPathComponent:iconFileName];
	return iconImagePath;
}


- (NSArray*)fontSizeDefinitions {
	return [metadata.dict valueForKeyPath:@"fontSizeDefinitions"];
}

- (void)dealloc {
	[metadata release];
	[super dealloc];
}

@end
