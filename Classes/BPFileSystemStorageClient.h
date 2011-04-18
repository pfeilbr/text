//
//  BPFileSystemStorageClient.h
//  text
//
//  Created by Brian Pfeil on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPBaseStorageClient.h"

@interface BPFileSystemStorageClient : BPBaseStorageClient {}

@property(nonatomic, readonly, getter=getStorageType) NSString* storageType;

@end
