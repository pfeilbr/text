//
//  ItemTableViewController.m
//  text
//
//  Created by Brian Pfeil on 4/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ItemTableViewController.h"

@interface ItemTableViewController()
- (NSIndexPath*)indexPathForItem:(BPItem*)item;
@end


@implementation ItemTableViewController

@synthesize isRootDirectory, addButton, addActionSheet, currentDirectoryPath, searchString, currentSelectedItem;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
	UIBarButtonItem *_flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *_deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:nil action:nil];
	NSArray *buttons = [NSArray arrayWithObjects:self.addButton, _flexibleSpaceButton, _deleteButton, nil];
	[self setToolbarItems:buttons animated:NO];
	[_flexibleSpaceButton release];
	[_deleteButton release];
	
	
	if (isRootDirectory) {
		self.navigationItem.hidesBackButton = YES;
	}

	self.clearsSelectionOnViewWillAppear = NO;
	//self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
	//self.navigationItem.rightBarButtonItem = addButton;
	self.addActionSheet = [[UIActionSheet alloc] initWithTitle:nil
													  delegate:self
											 cancelButtonTitle:BPItemActionCancel
										destructiveButtonTitle:nil
											 otherButtonTitles:BPItemActionNewFile, BPItemActionNewFolder, nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[BPItemManager sharedInstance].currentDisplayedDirectoryPath = self.currentDirectoryPath;
	[self reload];
	[super viewWillAppear:animated];
}

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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *_items = [[BPItemManager sharedInstance] itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:searchString];
    return [_items count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

	NSArray *_items = [[BPItemManager sharedInstance] itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:searchString];
	BPItem *item = [_items objectAtIndex:indexPath.row];
	cell.textLabel.text = item.name;
	cell.accessoryType = ([item.type isEqualToString:BPItemPropertyTypeFolder]) ?  UITableViewCellAccessoryDetailDisclosureButton :  UITableViewCellAccessoryNone;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		NSArray *_items = [[BPItemManager sharedInstance] itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:searchString];
		BPItem *item = [_items objectAtIndex:indexPath.row];
		[[BPItemManager sharedInstance] deleteItem:item];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];

		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:item forKey:kKeyItem];
		[[NSNotificationCenter defaultCenter] postNotificationName:BPItemDeletedNotification object:dict];
		
		// if this wasn't the last row deleted, select the next row
		if ([_items count] > 1) {
			BPItem *itemToSelect = nil;
			
			// if we deleted the last item in the list, select the previous one
			if (([_items count] - 1) == indexPath.row) {
				itemToSelect = [_items objectAtIndex:indexPath.row - 1];
			} else { // select next item in list
				itemToSelect = [_items objectAtIndex:indexPath.row + 1];
			}

			NSMutableDictionary *itemToSelectDict = [NSMutableDictionary dictionary];
			[itemToSelectDict setObject:itemToSelect forKey:kKeyItem];
			[[NSNotificationCenter defaultCenter] postNotificationName:BPSelectItemInItemListNotification object:itemToSelectDict];			
		}
    }   
}



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
	NSArray *_items = [[BPItemManager sharedInstance] itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:searchString];
	BPItem *item = [_items objectAtIndex:indexPath.row];
	currentSelectedItem = item;
	
	if ([item.type isEqualToString:BPItemPropertyTypeFile]) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:item forKey:kKeyItem];
		[[NSNotificationCenter defaultCenter] postNotificationName:BPItemSelectedNotification object:dict];		
	} else if ([item.type isEqualToString:BPItemPropertyTypeFolder]) {
		/*
		ItemTableViewController *itvc = [[ItemTableViewController alloc] initWithNibName:@"ItemTableViewController" bundle:nil];
		itvc.title = item.name;
		itvc.currentDirectoryPath = [[BPItemManager sharedInstance] pushDirectoryName:item.name];
		[self.navigationController pushViewController:itvc animated:YES];	
		[itvc release];
		 */
	}	
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSArray *_items = [[BPItemManager sharedInstance] itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:searchString];
	BPItem *item = [_items objectAtIndex:indexPath.row];

	if ([item.type isEqualToString:BPItemPropertyTypeFolder]) {
		ItemTableViewController *itvc = [[ItemTableViewController alloc] initWithNibName:@"ItemTableViewController" bundle:nil];
		itvc.title = item.name;
		itvc.currentDirectoryPath = [[BPItemManager sharedInstance] pushDirectoryName:item.name];
		[self.navigationController pushViewController:itvc animated:YES];	
		[itvc release];
	}	
}

#pragma mark Item Manipulation

- (void)reload {
	[self.tableView reloadData];
}

- (void)selectItem:(BPItem*)item {
	[self reload];
	currentSelectedItem = item;
	NSIndexPath *indexPath = [self indexPathForItem:item];
	[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
	
	// display file contents in detail view
	if ([item.type isEqualToString:BPItemPropertyTypeFile]) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:item forKey:kKeyItem];
		[[NSNotificationCenter defaultCenter] postNotificationName:BPItemSelectedNotification object:dict];
	}
}

- (NSIndexPath*)indexPathForItem:(BPItem*)item {
	int rowIndex = -1;
	int counter = 0;
	NSArray *_items = [[BPItemManager sharedInstance] itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:searchString];
	for (BPItem *i in _items) {
		if ([i isEqualToItem:item]) {
			rowIndex = counter;
		}
		counter++;
	}
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
	return indexPath;
}

#pragma mark -
#pragma mark Button Handlers

- (IBAction)addButtonPressed:(id)sender {
	
    if (self.addActionSheet.visible) {
        [self.addActionSheet dismissWithClickedButtonIndex:-1 animated:NO];
    }
    
    [addActionSheet showFromBarButtonItem:addButton animated:YES];	
}

#pragma mark ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case kAddNewFile:
		{
			NSMutableDictionary *dict = [NSMutableDictionary dictionary];
			[[NSNotificationCenter defaultCenter] postNotificationName:BPAddNewFileNotification object:dict];			
			break;
		}
		case kAddNewFolder:
		{
			NSMutableDictionary *dict = [NSMutableDictionary dictionary];
			[[NSNotificationCenter defaultCenter] postNotificationName:BPAddNewFolderNotification object:dict];			
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
#pragma mark UISearchDisplayDelegate

#pragma mark -
#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	self.searchString = searchText;
	[self reload];
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
	[addButton release];
	[addActionSheet release];
	[currentDirectoryPath release];
	[searchString release];
    [super dealloc];
}


@end

