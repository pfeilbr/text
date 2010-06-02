#define kBPItemStorageTypeFileSystemProtocol @"file"
#define kBPItemStorageTypeDropboxProtocol @"dropbox"

@protocol BPStorageClientDelegate;

@protocol BPStorageClient <NSObject>
@optional
@property(nonatomic, assign) id<BPStorageClientDelegate> delegate;
- (void)createFile:(NSString*)path fromPath:(NSString*)path;
- (void)createFolder:(NSString*)path;
- (void)loadFile:(NSString*)path;
- (void)deletePath:(NSString*)path;
- (void)copyFrom:(NSString*)fromPath toPath:(NSString *)toPath;
- (void)moveFrom:(NSString*)fromPath toPath:(NSString *)toPath;
@end

@protocol BPStorageClientDelegate <NSObject>
@optional
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


// ---

@interface BPBaseStorageClient : NSObject <BPStorageClient> {
    id<BPStorageClientDelegate> delegate;
}
@property (nonatomic, assign) id<BPStorageClientDelegate> delegate;
@end

@implementation BPBaseStorageClient
@synthesize delegate;
@end

// ---

@interface BPFileSystemStorageClient : BPBaseStorageClient {}
- (void)createFolder:(NSString*)path;
@end

@implementation BPFileSystemStorageClient

- (NSString*)getSupportedProtocol {
	return kBPItemStorageTypeFileSystemProtocol;
}

- (void)createFolder:(NSString*)path {
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
}

@end

// ---

@interface BPDropboxStorageClient : BPBaseStorageClient <BPStorageClient> {}
- (void)createFolder:(NSString*)path;
@end

@implementation BPDropboxStorageClient

- (void)createFolder:(NSString*)path {
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
}

@end


// ---

@interface BPItem : NSObject {
	NSString* type;
}
@property(nonatomic, copy) NSString* type;
@end

@implementation BPItem
@synthesize type;
@end

// ---

@interface BPItemManager : NSObject {
	id<BPStorageClientDelegate> delegate;
}
@property(nonatomic, assign) id<BPStorageClientDelegate> delegate;
+ (BPItemManager*)defaultManager;
- (void)createFolder:(NSString*)path;
@end

static BPItemManager* defaultManager = nil;

@interface BPItemManager()
- (BPBaseStorageClient*)storageClientForURL:(NSString*)url;
- (NSString*)storageClientPathForURL:(NSString*)url;
@end

@implementation BPItemManager

@synthesize delegate;

+ (BPItemManager*)defaultManager {
	if (defaultManager == nil) {
		defaultManager = [[[self class] alloc] init];
	}
	return defaultManager;
}

- (id<BPStorageClient>)storageClientForURL:(NSString*)url {
	NSArray* storageClientClassNames = [NSArray arrayWithObjects:@"BPFileSystemStorageClient", @"BPDropboxStorageClient", nil];
	NSArray* protocols = [NSArray arrayWithObjects:kBPItemStorageTypeFileSystemProtocol, kBPItemStorageTypeDropboxProtocol, nil];
	for (NSString* protocol in protocols) {
		NSString *prefix = [NSString stringWithFormat:@"%@://", protocol];
		if ([url hasPrefix:prefix]) {
			for (NSString* storageClientClassName in storageClientClassNames) {
				Class klass = NSClassFromString(storageClientClassName);
				NSString* supportedProtocol = [[[klass alloc] init] performSelector:@selector(getSupportedProtocol)];
				if ([supportedProtocol isEqualToString:protocol]) {
					id<BPStorageClient> storageClient = [[klass alloc] init];
					storageClient.delegate = delegate;
					return storageClient;
				}
			}
		}
	}
	return nil;
}

- (NSString*)storageClientPathForURL:(NSString*)url {
	NSRange range = [url rangeOfString:@"://"];
	return [url substringFromIndex:(range.location + range.length)];
}

- (void)createFolder:(NSString*)url {
	id<BPStorageClient> storageClient = [self storageClientForURL:url];
	NSString* path = [self storageClientPathForURL:url];
	[storageClient createFolder:path];
}

@end

// ---

@interface AppDelegate : NSObject <NSApplicationDelegate, BPStorageClientDelegate>{
	BPItemManager* itemManager;
}
- (void)storageClient:(id<BPStorageClient>)storageClient createdFolder:(NSString*)folder;
- (void)storageClient:(id<BPStorageClient>)storageClient createFolderFailedWithError:(NSError*)error;
@end

@interface AppDelegate()
@property(nonatomic, retain) BPItemManager* itemManager;
@end

@implementation AppDelegate

@synthesize itemManager;

- (id)init {
	if (self = [super init]) {
		self.itemManager = [[BPItemManager alloc] init];
		itemManager.delegate = self;
	}
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[itemManager createFolder:@"file:///tmp/deleteme01"];	
}

- (void)storageClient:(id<BPStorageClient>)storageClient createdFolder:(NSString*)folder {
    NSLog(@"storageClient:createdFolder: called");
}

- (void)storageClient:(id<BPStorageClient>)storageClient createFolderFailedWithError:(NSError*)error {
    NSLog(@"storageClient:createFolderFailedWithError: called");
}

@end