//
//  BPFileSystemItemStore.h
//  text
//
//  Created by Brian Pfeil on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPBaseItemStore.h"
#import "DBSession.h"
#import "DBRequest.h"
#import "DBRestClient.h"

@interface BPDropboxItemStore : BPBaseItemStore {
	DBRestClient *dropboxRestClient;
}

+ (BPDropboxItemStore*)sharedInstance;

- (BPItem*)fileItemFromPath:(NSString*)path error:(NSError**)err;
- (BPItem*)folderItemFromPath:(NSString*)path error:(NSError**)err;

- (BPItem*)createFileItemWithFileName:(NSString*)fileName atDirectoryPath:(NSString*)directoryPath error:(NSError**)err;
- (BPItem*)createFolderItemWithFolderName:(NSString*)folderName atDirectoryPath:(NSString*)directoryPath error:(NSError**)err;
- (BOOL)saveItem:(BPItem*)item withText:(NSString*)text error:(NSError**)err;
- (BPItem*)moveItem:(BPItem*)item toPath:(NSString*)path error:(NSError**)err;
- (BOOL)deleteItem:(BPItem*)item error:(NSError**)err;

- (NSArray*)contentsOfDirectoryItem:(BPItem*)directoryItem filteredBySearchString:(NSString*)searchString;

@end
