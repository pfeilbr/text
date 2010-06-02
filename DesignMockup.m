#import <Cocoa/Cocoa.h>

@protocol BPStorageClientDelegate;

@protocol BPStorageClient <NSObject>
- (void)createFolder:(NSString*)path;
@end

// ---

@interface BPBaseStorageClient : NSObject {
    id<BPStorageClientDelegate> delegate;
}

@property (nonatomic, assign) id<BPStorageClientDelegate> delegate;

@end

@implementation BPBaseStorageClient

@synthesize delegate;

@end

// ---

@interface BPFileSystemStorageClient : BPBaseStorageClient <BPStorageClient> {

}

- (void)createFolder:(NSString*)path;

@end

@implementation BPFileSystemStorageClient

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

@protocol BPStorageClientDelegate <NSObject>
@optional
- (void)storageClient:(id<BPStorageClient>)storageClient createdFolder:(NSString*)folder;
- (void)storageClient:(id<BPStorageClient>)storageClient createFolderFailedWithError:(NSError*)error;
@end

// ---

@interface AppDelegate : NSObject <NSApplicationDelegate, BPStorageClientDelegate>{
}

- (void)storageClient:(id<BPStorageClient>)storageClient createdFolder:(NSString*)folder;
- (void)storageClient:(id<BPStorageClient>)storageClient createFolderFailedWithError:(NSError*)error;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"BEGIN - applicationDidFinishLaunching");
    BPFileSystemStorageClient* fileSystemStorageClient = [[BPFileSystemStorageClient alloc] init];
    fileSystemStorageClient.delegate = self;
    [fileSystemStorageClient createFolder:@"/private/etc/junk"];    
    NSLog(@"END - applicationDidFinishLaunching");    
}

- (void)storageClient:(id<BPStorageClient>)storageClient createdFolder:(NSString*)folder {
    NSLog(@"storageClient:createdFolder: called");
}

- (void)storageClient:(id<BPStorageClient>)storageClient createFolderFailedWithError:(NSError*)error {
    NSLog(@"storageClient:createFolderFailedWithError: called");
}

@end


// ---

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    AppDelegate* appDelegate = [[AppDelegate alloc] init];
    NSApplication* app = [NSApplication sharedApplication];
    app.delegate = appDelegate;
    [app performSelectorOnMainThread:@selector(run) withObject:nil waitUntilDone:YES];
    
    [pool release];
    
    return 0;
}