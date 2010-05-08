//
//  BPConfig.m
//  text
//
//  Created by Brian Pfeil on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPConfig.h"

static BPConfig *sharedInstance = nil;

@interface BPConfig()
- (NSString*)baseDirectoryPath;
- (NSString*)keyboardAccessoryDefinitionsDirectoryPath;
- (id)loadConfigFromJSONFileAtPath:(NSString*)path;
@end


@implementation BPConfig

+ (BPConfig*)sharedInstance {
	if (sharedInstance == nil) {
		sharedInstance = [[[self class] alloc] init];
	}
	return sharedInstance;
}

- (void)dealloc {
	[sharedInstance release];
	[super dealloc];
}

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString*)baseDirectoryPath {
	NSString *bundleDirectoryPath = [[NSBundle mainBundle] bundlePath];
	return [bundleDirectoryPath stringByAppendingPathComponent:kConfigBaseDirectoryName];
}

- (NSString*)keyboardAccessoryDefinitionsDirectoryPath {
	return [[self baseDirectoryPath] stringByAppendingPathComponent:kConfigKeyboardAccessoryDefinitionsDirectoryName];
}

- (id)loadConfigFromJSONFileAtPath:(NSString*)path {
	NSError *err;
	NSString *configFileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
	if (configFileContents != nil) {
		return [configFileContents JSONValue];
	} else {
		return nil;
	}
}

- (id)keyboardAccessoryDefinitionForType:(NSString*)type {
	NSString *fileName = [NSString stringWithFormat:@"%@.%@", type, @"json"];
	NSString *path = [[self keyboardAccessoryDefinitionsDirectoryPath] stringByAppendingPathComponent:fileName];
	return [self loadConfigFromJSONFileAtPath:path];
}
						  
@end
