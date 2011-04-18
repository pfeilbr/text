//
//  BPBaseStorageClient.h
//  text
//
//  Created by Brian Pfeil on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

@protocol BPStorageClientDelegate;

@protocol BPStorageClient <NSObject>
@optional
@property(nonatomic, readonly, getter=getStorageType) NSString* storageType;
@property(nonatomic, assign) id<BPStorageClientDelegate> delegate;
- (void)loadMetadata:(NSString*)path;
- (void)createFile:(NSString*)path fromPath:(NSString*)path;
- (void)createFolder:(NSString*)path;
- (void)loadFile:(NSString*)path;
- (void)deletePath:(NSString*)path;
- (void)copyFrom:(NSString*)fromPath toPath:(NSString *)toPath;
- (void)moveFrom:(NSString*)fromPath toPath:(NSString *)toPath;
@end


@protocol BPStorageClientDelegate <NSObject>
@optional
- (void)storageClient:(id<BPStorageClient>)storageClient loadedMetadata:(NSDictionary*)metadata;
- (void)storageClient:(id<BPStorageClient>)storageClient loadMetadataFailedWithError:(NSError*)error;

- (void)storageClient:(id<BPStorageClient>)storageClient createdFile:(NSString*)path;
- (void)storageClient:(id<BPStorageClient>)storageClient createFileFailedWithError:(NSError*)error;

- (void)storageClient:(id<BPStorageClient>)storageClient createdFolder:(NSString*)folder;
- (void)storageClient:(id<BPStorageClient>)storageClient createFolderFailedWithError:(NSError*)error;

- (void)storageClient:(id<BPStorageClient>)storageClient loadedFile:(NSString*)path data:(NSData*)data;
- (void)storageClient:(id<BPStorageClient>)storageClient loadFileFailedWithError:(NSError*)error;

- (void)storageClient:(id<BPStorageClient>)storageClient deletedPath:(NSString*)path;
- (void)storageClient:(id<BPStorageClient>)storageClient deletePathFailedWithError:(NSError*)error;

- (void)storageClient:(id<BPStorageClient>)storageClient copiedPath:(NSString*)fromPath toPath:(NSString*)toPath;
- (void)storageClient:(id<BPStorageClient>)storageClient copyPathFailedWithError:(NSError*)error;

- (void)storageClient:(id<BPStorageClient>)storageClient movedPath:(NSString*)fromPath toPath:(NSString*)toPath;
- (void)storageClient:(id<BPStorageClient>)storageClient movePathFailedWithError:(NSError*)error;
@end


@interface BPBaseStorageClient : NSObject <BPStorageClient> {
	dispatch_queue_t dispatchQueue;	
    id<BPStorageClientDelegate> delegate;
}

- (dispatch_queue_t) dispatchQueue;

@property (nonatomic, assign) id<BPStorageClientDelegate> delegate;
@property(nonatomic, readonly, getter=getStorageType) NSString* storageType;
@end