//
//  BPBaseStorageClient.m
//  text
//
//  Created by Brian Pfeil on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPBaseStorageClient.h"

@interface BPBaseStorageClient ()
@end

@implementation BPBaseStorageClient

@synthesize delegate;

- (dispatch_queue_t) dispatchQueue {
	if (dispatchQueue == NULL) {
		dispatchQueue = dispatch_queue_create("com.brianpfeil.BaseItemStoreTaskQueue", NULL);
	}
	return dispatchQueue;
}

- (void)dealloc {
	[super dealloc];
	if (dispatchQueue != NULL) {
		dispatch_release(dispatchQueue);
	}
}

@end
