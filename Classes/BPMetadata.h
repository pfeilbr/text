//
//  BPMetadata.h
//  text
//
//  Created by Brian Pfeil on 9/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BPMetadata : NSObject {

}

+ (BPMetadata*)sharedInstance;

- (NSDictionary*)metadata;
- (NSDictionary*)metadataForPropertyName:(NSString*)propertyName;

@property (nonatomic, readonly) NSDictionary* dict;

@end
