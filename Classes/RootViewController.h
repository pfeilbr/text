//
//  RootViewController.h
//  text
//
//  Created by Brian Pfeil on 4/28/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ItemTableViewController.h"

@class DetailViewController;

@interface RootViewController : ItemTableViewController <NSFetchedResultsControllerDelegate, UINavigationControllerDelegate> {
	DetailViewController *detailViewController;
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (UIViewController*)visibleViewController;

@end
