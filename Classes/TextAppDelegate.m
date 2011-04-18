//
//  textAppDelegate.m
//  text
//
//  Created by Brian Pfeil on 4/28/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TextAppDelegate.h"


#import "RootViewController.h"
#import "DetailViewController.h"
#import "DropboxSDK.h"
#import "BPConfig.h"
#import "BPDropboxStorageClient.h"
#import "BPFileSystemStorageClient.h"
#import "ContentWebViewController.h"
#import "BPMetadata.h"

@interface TextAppDelegate (CoreDataPrivate)
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (NSString *)applicationDocumentsDirectory;
@end


@implementation TextAppDelegate

@synthesize window, splitViewController, rootViewController, detailViewController;

- (void)storageClient:(id<BPStorageClient>)storageClient loadedMetadata:(NSDictionary*)metadata {
	NSLog(@"%s", __FUNCTION__);
}

- (void)storageClient:(id<BPStorageClient>)storageClient loadMetadataFailedWithError:(NSError*)error {
	NSLog(@"%s", __FUNCTION__);	
}

- (void)storageClient:(id<BPStorageClient>)storageClient createdFile:(NSString*)path {
	NSLog(@"%s", __FUNCTION__);	
}

- (void)storageClient:(id<BPStorageClient>)storageClient createFileFailedWithError:(NSError*)error {
	NSLog(@"%s", __FUNCTION__);	
}

- (void)storageClient:(id<BPStorageClient>)storageClient createdFolder:(NSString*)folder {
	NSLog(@"%s", __FUNCTION__);	
}

- (void)storageClient:(id<BPStorageClient>)storageClient createFolderFailedWithError:(NSError*)error {
	NSLog(@"%s", __FUNCTION__);	
}

- (void)storageClient:(id<BPStorageClient>)storageClient loadedFile:(NSString*)path data:(NSData*)data {
	NSLog(@"%s", __FUNCTION__);
	NSString* s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"%@",s);
}

- (void)storageClient:(id<BPStorageClient>)storageClient loadFileFailedWithError:(NSError*)error {
	NSLog(@"%s", __FUNCTION__);	
}

- (void)storageClient:(id<BPStorageClient>)storageClient deletedPath:(NSString*)path {
	NSLog(@"%s", __FUNCTION__);		
}

- (void)storageClient:(id<BPStorageClient>)storageClient deletePathFailedWithError:(NSError*)error {
	NSLog(@"%s", __FUNCTION__);
}

- (void)storageClient:(id<BPStorageClient>)storageClient copiedPath:(NSString*)fromPath toPath:(NSString*)toPath {
	NSLog(@"%s", __FUNCTION__);
}

- (void)storageClient:(id<BPStorageClient>)storageClient copyPathFailedWithError:(NSError*)error {
	NSLog(@"%s", __FUNCTION__);
}

- (void)storageClient:(id<BPStorageClient>)storageClient movedPath:(NSString*)fromPath toPath:(NSString*)toPath {
	NSLog(@"%s", __FUNCTION__);
}

- (void)storageClient:(id<BPStorageClient>)storageClient movePathFailedWithError:(NSError*)error {
	NSLog(@"%s", __FUNCTION__);
}


- (void)test {
	
	//NSRegularExpression* regex = [[NSRegularExpression regularExpressionWithPattern:<#(NSString *)pattern#> options:<#(NSRegularExpressionOptions)options#> error:<#(NSError **)error#>
	
	
	BPFileSystemStorageClient* dsc = [[BPFileSystemStorageClient alloc] init];
	NSString* protocol = dsc.storageType;
	
	//NSDictionary* metadata = [[BPMetadata sharedInstance] metadata];
	//NSDictionary* settings = [[BPMetadata sharedInstance] metadataForPropertyName:@"settings"];
	NSDictionary *def = [[BPConfig sharedInstance] keyboardAccessoryDefinitionForType:@"html"];
	NSLog(@"%@", def);
	
	NSString* docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	
	
	BPFileSystemStorageClient* fsClient = [[BPFileSystemStorageClient alloc] init];
	fsClient.delegate = self;
	[fsClient createFolder:[docsDir stringByAppendingPathComponent:@"mydocs"]];
	
	
	NSString* fromPath = [docsDir stringByAppendingPathComponent:@"file1.txt"];
	NSString* path = [docsDir stringByAppendingPathComponent:@"newfile1.txt"];
	[fsClient createFile:path fromPath:fromPath];
	
	[fsClient loadFile:@"junk"];
	
	BPDropboxStorageClient* client = [[BPDropboxStorageClient alloc] init];
	client.delegate = self;
	//[client createFolder:@"/atest01/subfolder01"];
	[client createFile:@"/atest01/subfolder01/a.txt" fromPath:[docsDir stringByAppendingPathComponent:@"file1.txt"]];
	//[client loadFile:@"/notes/Jamaica.txt"];
	//[client deletePath:@"/atest01/subfolder01/a.txt"];
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	
    DBSession* dbSession =
		[[[DBSession alloc]
		  initWithConsumerKey:BPDropboxConsumerKey
		  consumerSecret:BPDropboxConsumerSecret
		 ] autorelease];
    [DBSession setSharedSession:dbSession];

	// TODO: delete test
	//[self test];	
	
	rootViewController.currentDirectoryItem = [BPItemManager sharedInstance].currentDisplayedDirectoryItem;
    
    // Override point for customization after app launch    
    //rootViewController.managedObjectContext = self.managedObjectContext;

    
	// Add the split view controller's view to the window and display.
	[window addSubview:splitViewController.view];
    

    
	//[self performSelector:@selector(webView:) withObject:self afterDelay:1.0];
    [window makeKeyAndVisible];
	
	[self performSelector:@selector(showFullScreen:) withObject:self afterDelay:2.0];
	
	return YES;
}

- (void)showFullScreen:(id)target {
    UIViewController *vc0 = (UIViewController*)[splitViewController.viewControllers objectAtIndex:0];
    UIViewController *vc1 = (UIViewController*)[splitViewController.viewControllers objectAtIndex:1];
    
    [UIView beginAnimations:nil context:nil];
    [splitViewController.view removeFromSuperview];
    tmpView = vc1.view.superview;
    [vc1.view removeFromSuperview];
    [window addSubview:vc1.view];
    [UIView commitAnimations];
    
    [self performSelector:@selector(showSplitScreen:) withObject:self afterDelay:2.0];
}

- (void)showSplitScreen:(id)target {
    UIViewController *vc0 = (UIViewController*)[splitViewController.viewControllers objectAtIndex:0];
    UIViewController *vc1 = (UIViewController*)[splitViewController.viewControllers objectAtIndex:1];
    
    //[UIView beginAnimations:nil context:nil];
    [vc1.view removeFromSuperview];
    [tmpView addSubview:vc1.view];
    CGAffineTransform rotate = CGAffineTransformMakeRotation(0.0);
    vc1.view.transform = rotate;
    [window addSubview:splitViewController.view];
    //[UIView commitAnimations];
    
    [self performSelector:@selector(showFullScreen:) withObject:self afterDelay:2.0];
}


- (void)webView:(id)sender {
	UINavigationController* nc = [[UINavigationController alloc] init];
	
	ContentWebViewController* vc = [[ContentWebViewController alloc] initWithNibName:@"ContentWebViewController" bundle:nil];
	vc.title = @"Web View";
	vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:nil];
	
	[nc pushViewController:vc animated:NO];
	
//	UIView* v = [[UIView alloc] init];
//	v.backgroundColor = [UIColor greenColor];
//	vc.view = v;
	
	UIToolbar* tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 768.0, 40.0)];
	UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:nil action:nil];
	tb.items = [NSArray arrayWithObject:button];
	//[v addSubview:tb];
	
	[splitViewController presentModalViewController:nc animated:YES];
	[vc retain];
	
	[vc.contentWebView loadHTMLString:@"<html><body>hello world</body></html>" baseURL:nil];
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"text.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {

	[managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[splitViewController release];
	[rootViewController release];
	[detailViewController release];

	[window release];
	[super dealloc];
}


@end

