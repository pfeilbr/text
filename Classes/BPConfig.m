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

@property(nonatomic, retain) NSMutableDictionary *keyboardAccessoryDefinitionsCache;
@end


@implementation BPConfig

@synthesize keyboardAccessoryDefinitionsCache;

- (id)init {
	if (self = [super init]) {
		keyboardAccessoryDefinitionsCache = nil;
	}
	return self;
}

+ (BPConfig*)sharedInstance {
	if (sharedInstance == nil) {
		sharedInstance = [[[self class] alloc] init];
	}
	return sharedInstance;
}

- (void)dealloc {
	[sharedInstance release];
	[keyboardAccessoryDefinitionsCache release];
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

- (NSDictionary*)keyboardAccessoryDefinitions {
	
	if (keyboardAccessoryDefinitionsCache == nil) {
		self.keyboardAccessoryDefinitionsCache = [NSMutableDictionary dictionary];
	} else {
		return keyboardAccessoryDefinitionsCache;
	}
	
	NSString *inputAccessoryDefinitionsDirectoryPath = [self keyboardAccessoryDefinitionsDirectoryPath];
	NSError *err;
	NSArray *contentsOfDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inputAccessoryDefinitionsDirectoryPath error:&err];
	for (NSString *fileName in contentsOfDirectory) {
		NSString *path = [inputAccessoryDefinitionsDirectoryPath stringByAppendingPathComponent:fileName];
		id definition = [self loadConfigFromJSONFileAtPath:path];
		NSString *type = [definition valueForKey:@"type"];
		[keyboardAccessoryDefinitionsCache setValue:definition forKey:type];
	}
	return keyboardAccessoryDefinitionsCache;
}

- (id)keyboardAccessoryDefinitionForType:(NSString*)type {
	return [[self keyboardAccessoryDefinitions] valueForKey:type];
}

- (id)keyboardAccessoryDefinitionForFileExtension:(NSString*)fileExtesion {
	NSString *type = [self typeForFileExtension:fileExtesion];
	return [self keyboardAccessoryDefinitionForType:type];
}

- (NSString*)typeForFileExtension:(NSString*)fileExtension {
	NSDictionary *definitions = [self keyboardAccessoryDefinitions];
	for (NSString *key in definitions) {
		NSDictionary *definition = [definitions valueForKey:key];
		NSArray *fileExtensions = [definition valueForKey:@"extensions"];
		for (NSString *_fileExtension in fileExtensions) {
			if ([_fileExtension isEqualToString:fileExtension]) {
				return [definition valueForKey:@"type"];
			}
		}
	}
	return @"default";
}
						  
@end
