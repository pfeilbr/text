//
//  BPDropboxStorageClient.m
//  text
//
//  Created by Brian Pfeil on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPDropboxStorageClient.h"

@interface BPDropboxStorageClient()
@property(nonatomic, retain) DBSession* session;
@property(nonatomic,readonly) DBRestClient* restClient;
@end

@implementation BPDropboxStorageClient

- (id)init {
    self = [super init];
    if (self) {
        request = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString*)getStorageType {
	return kBPItemStorageTypeDropbox;
}

- (DBRestClient*)restClient {
	if (!restClient) {
		restClient = 
			[[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		restClient.delegate = self;
	}
	return restClient;
}

- (NSError*)errorFromInternalError:(NSError*)error {
	NSDictionary* errUserInfo = nil;
	NSDictionary* userInfo = [error userInfo];
	if (userInfo) {
		errUserInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
		[errUserInfo setValue:request forKey:@"request"];
	} else {
		errUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:request, @"request", nil];
	}
	
	NSError* err = [[[NSError alloc] initWithDomain:[error domain] code:[error code] userInfo:errUserInfo] autorelease];
	return err;
}

- (void)loadMetadata:(NSString*)path {
	[self.restClient loadMetadata:path];
}

- (void)createFile:(NSString*)path fromPath:(NSString*)fromPath {
    [request setValue:path forKey:@"path"];
	NSString* toPath = [path stringByDeletingLastPathComponent];
	NSString* filename = [[path pathComponents] lastObject];
	[self.restClient uploadFile:filename toPath:toPath fromPath:fromPath];
}

- (void)createFolder:(NSString*)path {
	[self.restClient createFolder:path];
}

- (void)loadFile:(NSString*)path {
    [request setValue:path forKey:@"path"];
	NSString* destinationPath = [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @""]];
	[self.restClient loadFile:path intoPath:destinationPath];			
}

- (void)deletePath:(NSString*)path {
	[self.restClient deletePath:path];
}

- (void)copyFrom:(NSString*)fromPath toPath:(NSString *)toPath {
	[self.restClient copyFrom:fromPath toPath:toPath];
}

- (void)moveFrom:(NSString*)fromPath toPath:(NSString *)toPath {
	[self.restClient moveFrom:fromPath toPath:toPath];
}

- (void)restClientDidLogin:(DBRestClient*)client {
	NSLog(@"%s", __FUNCTION__);	
}

- (void)restClient:(DBRestClient*)client loginFailedWithError:(NSError*)error {
	NSLog(@"%s", __FUNCTION__);	
}

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
	if ([delegate respondsToSelector:@selector(storageClient:loadedMetadata:)]) {
		NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
		[dict setValue:metadata.path forKey:@"path"];
		[dict setValue:metadata forKey:@"attributes"];
		[dict setValue:metadata.contents forKey:@"contents"];
		[delegate storageClient:self loadedMetadata:[dict autorelease]];
	}
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
	if ([delegate respondsToSelector:@selector(storageClient:loadMetadataFailedWithError:)]) {
		[delegate storageClient:self loadMetadataFailedWithError:error];
	}
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath {
	if ([delegate respondsToSelector:@selector(storageClient:loadedFile:data:)]) {
		NSString* path = [request valueForKey:@"path"];
		[delegate storageClient:self loadedFile:path data:[NSData dataWithContentsOfFile:destPath]];

		NSError* err;
		[[NSFileManager defaultManager] removeItemAtPath:destPath error:&err];
	}
}

- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath {
	NSLog(@"%s", __FUNCTION__);	
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)srcPath {	
	if ([delegate respondsToSelector:@selector(storageClient:createdFile:)]) {
		NSString* path = [request valueForKey:@"path"];
		NSString* toPath = [path stringByDeletingLastPathComponent];		
		[delegate storageClient:self createdFile:path];
	}
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress forFile:(NSString*)srcPath {
	
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
	if ([delegate respondsToSelector:@selector(storageClient:createFileFailedWithError:)]) {
		NSError* err = [self errorFromInternalError:error];
		[delegate storageClient:self createFileFailedWithError:err];
	}
}
// [error userInfo] contains the sourcePath

- (void)restClient:(DBRestClient*)client createdFolder:(NSDictionary*)folder {
	NSLog(@"%s", __FUNCTION__);	
	if ([delegate respondsToSelector:@selector(storageClient:createdFolder:)]) {
		[delegate storageClient:self createdFolder:[folder valueForKey:@"path"]];
	}        	
}
// Folder is the metadata for the newly created folder

- (void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error {
	NSLog(@"%s", __FUNCTION__);	
	if ([delegate respondsToSelector:@selector(storageClient:createFolderFailedWithError:)]) {
		NSError* err = [self errorFromInternalError:error];
		[delegate storageClient:self createFolderFailedWithError:err];
	}	
}
// [error userInfo] contains the root and path

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path {
	if ([delegate respondsToSelector:@selector(storageClient:deletedPath:)]) {
		[delegate storageClient:self deletedPath:path];
	}
}
// Folder is the metadata for the newly created folder

- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error {
	if ([delegate respondsToSelector:@selector(storageClient:deletePathFailedWithError:)]) {
		NSError* err = [self errorFromInternalError:error];
		[delegate storageClient:self deletePathFailedWithError:err];
	}		
}
// [error userInfo] contains the root and path

- (void)restClient:(DBRestClient*)client copiedPath:(NSString *)fromPath toPath:(NSString *)toPath {
	if ([delegate respondsToSelector:@selector(storageClient:copiedPath:toPath:)]) {
		[delegate storageClient:self copiedPath:fromPath toPath:toPath];
	}	
}
// Folder is the metadata for the newly created folder

- (void)restClient:(DBRestClient*)client copyPathFailedWithError:(NSError*)err {
	if ([delegate respondsToSelector:@selector(storageClient:copyPathFailedWithError:)]) {
		[delegate storageClient:self copyPathFailedWithError:err];
	}		
}
// [error userInfo] contains the root and path
//

- (void)restClient:(DBRestClient*)client movedPath:(NSString *)fromPath toPath:(NSString *)toPath {
	if ([delegate respondsToSelector:@selector(storageClient:movedPath:toPath:)]) {
		[delegate storageClient:self movedPath:fromPath toPath:toPath];
	}		
}

// Folder is the metadata for the newly created folder
- (void)restClient:(DBRestClient*)client movePathFailedWithError:(NSError*)err {
	if ([delegate respondsToSelector:@selector(storageClient:movePathFailedWithError:)]) {
		[delegate storageClient:self movePathFailedWithError:err];
	}			
}
// [error userInfo] contains the root and path

@end
