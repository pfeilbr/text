//
//  BPConfig.h
//  text
//
//  Created by Brian Pfeil on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPConfig : NSObject {
	NSMutableDictionary *keyboardAccessoryDefinitionsCache;
}

+ (BPConfig*)sharedInstance;
- (NSDictionary*)keyboardAccessoryDefinitions;
- (id)keyboardAccessoryDefinitionForType:(NSString*)type;
- (id)keyboardAccessoryDefinitionForFileExtension:(NSString*)fileExtesion;
- (NSString*)typeForFileExtension:(NSString*)fileExtesion;
@end
