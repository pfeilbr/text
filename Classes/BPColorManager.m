//
//  BPColorManager.m
//  text
//
//  Created by Brian Pfeil on 9/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPColorManager.h"

static BPColorManager* colorManagerSharedInstance = nil;
static NSString* kColorNames = @"black,blue,brown,clear,cyan,darkGray,darkText,gray,green,groupTableViewBackground,lightGray,lightText,magenta";
	
@implementation BPColorManager

@synthesize colorDefinitions;

+ (BPColorManager*)sharedInstance {
	if (colorManagerSharedInstance == nil) {
		colorManagerSharedInstance = [[[self class] alloc] init];
	}
	return colorManagerSharedInstance;
}

- (id)init {
	if (self = [super init]) {
		NSMutableArray* colorDefs = [[NSMutableArray alloc] init];
		unsigned int count;
		Method* classMethods = class_copyMethodList(object_getClass([UIColor class]), &count);
		for (int i = 0; i < count; i++) {
			Method* classMethod = classMethods++;
			SEL selMethodName = method_getName(*classMethod);
			const char* methodName = sel_getName(selMethodName);
			NSString* name = [NSString stringWithCString:methodName encoding:NSUTF8StringEncoding];
			if ([name hasSuffix:@"Color"]) {
				SEL sel = NSSelectorFromString(name);
				UIColor* color = objc_msgSend([UIColor class], sel);
				NSMutableDictionary* colorDefinition = [[NSMutableDictionary alloc] init];
				[colorDefinition setValue:color forKey:@"color"];
				[colorDefinition setValue:name forKey:@"name"];
				[colorDefs addObject:colorDefinition];
			}
		}
		colorDefinitions = colorDefs;
	}
	return self;
}

- (NSArray*)colorNames {
	return [kColorNames componentsSeparatedByString:@","];	
}

- (NSArray*)colorDisplayNames {
	NSMutableArray* colorDisplayNames = [[NSMutableArray alloc] init];	
	NSArray* colorNames = [self colorNames];
	for (NSString* colorName in colorNames) {
		NSString* colorDisplayName = [colorName copy];
		[colorDisplayNames addObject:colorDisplayName];
	}
	return [colorDisplayNames autorelease];
}

- (NSArray*)colors {
	NSMutableArray* colors = [[NSMutableArray alloc] init];
	NSArray* colorNames = [self colorNames];
	for (NSString* colorName in colorNames) {
		UIColor* color = [self colorFromColorName:colorName];
		[colors addObject:color];
	}
	return [colors autorelease];
}

- (UIColor*)colorFromColorName:(NSString*)colorName {
	SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@Color", colorName]);
	return [[UIColor class] performSelector:sel];
}

@end
