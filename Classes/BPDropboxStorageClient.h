//
//  BPDropboxStorageClient.h
//  text
//
//  Created by Brian Pfeil on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPBaseStorageClient.h"
#import "DropboxSDK.h"

@interface BPDropboxStorageClient : BPBaseStorageClient <BPStorageClient, DBRestClientDelegate> {
	DBSession* session;
	DBRestClient* restClient;
	NSMutableDictionary* request;
}

@property(nonatomic, readonly, getter=getStorageType) NSString* storageType;

@end
