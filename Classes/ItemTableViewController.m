//
//  ItemTableViewController.m
//  text
//
//  Created by Brian Pfeil on 4/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ItemTableViewController.h"


@implementation ItemTableViewController

@synthesize items, addButton, addActionSheet;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
	self.navigationItem.rightBarButtonItem = addButton;
	
	self.addActionSheet = [[UIActionSheet alloc] initWithTitle:nil
													  delegate:self
											 cancelButtonTitle:nil
										destructiveButtonTitle:nil
											 otherButtonTitles:@"New File", @"New Folder", @"New Project", nil];
	
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [items count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	BPItem *item = [items objectAtIndex:indexPath.row];
	cell.textLabel.text = item.name;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	BPItem *item = [items objectAtIndex:indexPath.row];
	
	switch (item.type) {
		case kItemTypeFile:
		{
			NSMutableDictionary *dict = [NSMutableDictionary dictionary];
			[dict setObject:item forKey:@"item"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"itemSelected" object:dict];
			break;
		}
		case kItemTypeFolder:
		{
			ItemTableViewController *itvc = [[ItemTableViewController alloc] initWithNibName:@"ItemTableViewController" bundle:nil];
			itvc.title = item.name;
			itvc.items = [[BPItemManager sharedInstance] itemsForDirectoryAtPath:item.path];
			[self.navigationController pushViewController:itvc animated:YES];			
			[itvc release];
			break;
		}
		default:
		{
			break;
		}
	}
}

#pragma mark -
#pragma mark Button Handlers

- (IBAction)addButtonPressed:(id)sender {
	/*
	UIViewController *vc = [[UIViewController alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
	*/
	
	/*
	 NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	 NSError *err;
	 NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&err];
	 */
	
    if (self.addActionSheet.visible) {
        [self.addActionSheet dismissWithClickedButtonIndex:-1 animated:NO];
    }
    
	/*
	 if (popoverController != nil) {
	 [popoverController dismissPopoverAnimated:YES];
	 }
	 */
    
    [addActionSheet showFromBarButtonItem:addButton animated:YES];	
}

#pragma mark ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
		case kAddNewFile:
		{
			NSLog(@"kAddNewFile");
			break;
		}
		case kAddNewFolder:
		{
			break;
		}
		case kAddNewProject:
		{
			break;
		}			
		default:
			break;
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

