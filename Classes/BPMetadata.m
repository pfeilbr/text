//
//  BPMetadata.m
//  text
//
//  Created by Brian Pfeil on 9/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPMetadata.h"

static BPMetadata* metadataSharedInstance = nil;

@implementation BPMetadata

@synthesize dict;

+ (BPMetadata*)sharedInstance {
	if (metadataSharedInstance == nil) {
		metadataSharedInstance = [[[self class] alloc] init];
	}
	return metadataSharedInstance;
}

- (NSDictionary*)metadata {
	NSString* path = [[NSBundle mainBundle] pathForResource:@"metadata" ofType:@"json"];
	NSError* err;
	NSString* metadataAsJSONString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
	return [metadataAsJSONString JSONValue];
}

- (NSDictionary*)dict {
	return [self metadata];
}

- (NSDictionary*)metadataForPropertyName:(NSString*)propertyName {
	return [[self metadata] valueForKeyPath:propertyName];
}


@end
