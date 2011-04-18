//
//  BPFileSystemStorageClient.m
//  text
//
//  Created by Brian Pfeil on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPFileSystemStorageClient.h"


@implementation BPFileSystemStorageClient

- (NSString*)getStorageType {
	return kBPItemStorageTypeFileSystem;
}

- (void)loadMetadata:(NSString*)path {
	dispatch_async(dispatch_get_main_queue(), ^{
		NSError* err;
		NSMutableDictionary* metadata = [[NSMutableDictionary alloc] init];
		NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&err];
		[metadata setValue:path forKey:@"path"];
		[metadata setValue:attributes forKey:@"attributes"];
		
		NSString* fileType = [attributes valueForKey:NSFileType];
		 
		if ([fileType isEqualToString:NSFileTypeDirectory]) {
			NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&err];
			[metadata setValue:contents forKey:@"contents"];
		}
		 
		if (!attributes) {
			if ([delegate respondsToSelector:@selector(storageClient:loadMetadataFailedWithError:)]) {
				[delegate storageClient:self loadMetadataFailedWithError:err];
			}			
		} else {
			if ([delegate respondsToSelector:@selector(storageClient:loadedMetadata:)]) {
				[delegate storageClient:self loadedMetadata:metadata];
			}			
		}
	});
}

- (void)createFile:(NSString*)path fromPath:(NSString*)fromPath {
	dispatch_async(dispatch_get_main_queue(), ^{
		NSError *err;
        
        // delete file if it already exists - update scenario
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        
		BOOL fileCreated = [[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:path error:&err];
		
		if(!fileCreated) {
			if ([delegate respondsToSelector:@selector(storageClient:createFileFailedWithError:)]) {
				[delegate storageClient:self createFileFailedWithError:err];
			}
		} else {
			if ([delegate respondsToSelector:@selector(storageClient:createdFile:)]) {
				[delegate storageClient:self createdFile:path];
			}        
		}
	});
}

- (void)createFolder:(NSString*)path {
	dispatch_async(dispatch_get_main_queue(), ^{
		NSError *err;
		BOOL directoryCreated = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];			
		
		if(!directoryCreated) {
			if ([delegate respondsToSelector:@selector(storageClient:createFolderFailedWithError:)]) {
				[delegate storageClient:self createFolderFailedWithError:err];
			}
		} else {
			if ([delegate respondsToSelector:@selector(storageClient:createdFolder:)]) {
				[delegate storageClient:self createdFolder:path];
			}        
		}
	});
}

- (void)loadFile:(NSString*)path {
	dispatch_async(dispatch_get_main_queue(), ^{
		NSError* err;
		NSData* data = [NSData dataWithContentsOfFile:path options:NSDataReadingMapped error:&err];
		if (!data) {
			if ([delegate respondsToSelector:@selector(storageClient:loadFileFailedWithError:)]) {
				[delegate storageClient:self loadFileFailedWithError:err];
			}			
		} else {
			if ([delegate respondsToSelector:@selector(storageClient:loadedFile:data:)]) {
				[delegate storageClient:self loadedFile:path data:data];
			}
		}
	});
}

- (void)deletePath:(NSString*)path {
	dispatch_async(dispatch_get_main_queue(), ^{
		NSError* err;
		BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:path error:&err];
		if (!deleted) {
			if ([delegate respondsToSelector:@selector(storageClient:deletePathFailedWithError:)]) {
				[delegate storageClient:self deletePathFailedWithError:err];
			}			
		} else {
			if ([delegate respondsToSelector:@selector(storageClient:deletedPath:)]) {
				[delegate storageClient:self deletedPath:path];
			}						
		}
	});
}

- (void)copyFrom:(NSString*)fromPath toPath:(NSString *)toPath {
	dispatch_async(dispatch_get_main_queue(), ^{
		NSError* err;
		BOOL copied = [[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:toPath error:&err]; 
		if (!copied) {
			if ([delegate respondsToSelector:@selector(storageClient:copyPathFailedWithError:)]) {
				[delegate storageClient:self copyPathFailedWithError:err];
			}			
		} else {
			if ([delegate respondsToSelector:@selector(storageClient:copiedPath:toPath:)]) {
				[delegate storageClient:self copiedPath:fromPath toPath:toPath];
			}									
		}		
	});
}

- (void)moveFrom:(NSString*)fromPath toPath:(NSString *)toPath {
	dispatch_async(dispatch_get_main_queue(), ^{
		NSError* err;
		BOOL moved = [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:&err];
		if (!moved) {
			if ([delegate respondsToSelector:@selector(storageClient:movePathFailedWithError:)]) {
				[delegate storageClient:self movePathFailedWithError:err];
			}			
		} else {
			if ([delegate respondsToSelector:@selector(storageClient:movedPath:toPath:)]) {
				[delegate storageClient:self movedPath:fromPath toPath:toPath];
			}									
		}
	});	
}

@end
