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
- (void)selectItem:(BPItem*)item;

@property(nonatomic, retain) BPItemManager* itemManager;
@property(nonatomic, retain) NSArray* items;
@property(nonatomic, retain) LoadingView* loadingView;

@end

@implementation ItemTableViewController

@synthesize isRootDirectory, addButton, addActionSheet, currentDirectoryItem, searchString, currentSelectedItem;
@synthesize itemManager, items, loadingView;

#pragma mark -
#pragma mark View lifecycle

- (void)setCurrentDirectoryItem:(BPItem*)directoryItem {
	currentDirectoryItem = directoryItem;
	self.itemManager = [[BPItemManager alloc] initWithItem:currentDirectoryItem];
	itemManager.delegate = self;	
}

- (NSArray*) items {
	NSMutableArray* filteredItems = [[NSMutableArray alloc] init];
	for (BPItem* item in items) {
		if (searchString == nil
			|| [searchString isEqualToString:@""]
			|| [item.name rangeOfString:searchString options:NSRegularExpressionSearch].length > 0) { // regex search
			[filteredItems addObject:item];			
		}		
	}
	return [filteredItems autorelease];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	itemLoadInProgress = NO;
	itemsLoaded = NO;
	self.items = nil;	
	
	self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
	UIBarButtonItem *_flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *_deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButtonPressed:)];
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
	[BPItemManager sharedInstance].currentDisplayedDirectoryItem = self.currentDirectoryItem;
	self.searchDisplayController.active = NO;
	self.searchString = @"";
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

	if (!itemsLoaded && !itemLoadInProgress) {
		[self loadItems];
		return 0;
	} else {
		return 1;
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//NSArray *_items = [[BPItemManager sharedInstance] itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:searchString];
    return [self.items count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

	//NSArray *_items = [[BPItemManager sharedInstance] itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:searchString];
	NSArray* _items = self.items;
	BPItem *item = [_items objectAtIndex:indexPath.row];
	cell.textLabel.text = item.name;
	cell.accessoryType = ([item.type isEqualToString:BPItemPropertyTypeFolder]) ?  UITableViewCellAccessoryDetailDisclosureButton :  UITableViewCellAccessoryNone;
	
	if ([item.iconName isEqualToString:@""]) {
		UIDocumentInteractionController* dic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:item.path]];
		dic.name = item.name;
		if (dic.icons != nil && ([dic.icons count] > 0)) {
			cell.imageView.image = [dic.icons objectAtIndex:0];
		}		
	} else {
		NSString* iconImagePath = [[BPApp sharedInstance] getSmallIconImagePathForIconNamed:item.iconName];
		cell.imageView.image = [UIImage imageWithContentsOfFile:iconImagePath];
	}
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (void)deleteSelectedRow {
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	if (indexPath != nil) {
		[self deleteRow:indexPath.row];
	}
}

- (void)deleteRow:(NSUInteger)row {
	//NSArray *_items = [[BPItemManager sharedInstance] itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:searchString];
	NSArray *_items = self.items;
	BPItem *item = [_items objectAtIndex:row];
    
    [items removeObject:item];
    
    rowToDelete = row;    
	[itemManager deleteItem:item];
    
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self deleteRow:indexPath.row];
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
	//NSArray *_items = [[BPItemManager sharedInstance] itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:searchString];
	NSArray *_items = self.items;
	BPItem *item = [_items objectAtIndex:indexPath.row];
	self.currentSelectedItem = item;
	
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
	//NSArray *_items = [[BPItemManager sharedInstance] itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:searchString];
	NSArray *_items = self.items;
	BPItem *item = [_items objectAtIndex:indexPath.row];

	if ([item.type isEqualToString:BPItemPropertyTypeFolder]) {
		ItemTableViewController *itvc = [[ItemTableViewController alloc] initWithNibName:@"ItemTableViewController" bundle:nil];
		itvc.title = item.name;
		itvc.currentDirectoryItem = [[BPItemManager sharedInstance] pushDirectoryItem:item];
		[self.navigationController pushViewController:itvc animated:YES];	
		[itvc release];
	}	
}

#pragma mark Item Manipulation

- (void)loadItems {
	itemsLoaded = NO;
	itemLoadInProgress = YES;
	self.loadingView = [LoadingView loadingViewInView:self.view.superview];
	[itemManager loadDirectoryItemContents:currentDirectoryItem];
}

#pragma mark -
#pragma mark BPItemManagerDelegate

- (void)itemManager:(BPItemManager*)itemManager loadedDirectoryItem:(BPItem*)directoryItem contents:(NSArray*)_items {
	[loadingView removeView];
	self.items = _items;
	itemsLoaded = YES;
	itemLoadInProgress = NO;
	
	if (!currentSelectedItem) {
		[self reload];
	} else {
		[self selectItem:currentSelectedItem];
	}	
}

- (void)itemManager:(BPItemManager*)itemManager loadContentsOfDirectoryItemFailedWithError:(NSError*)error {
	itemsLoaded = YES;
	itemLoadInProgress = NO;	
}

- (void)itemManager:(BPItemManager *)itemManager deletedItem:(BPItem *)_item {
    NSUInteger row = rowToDelete;
	NSArray *_items = self.items;
	BPItem *item = [_items objectAtIndex:row];
	NSError *err;
    
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:item forKey:kKeyItem];
	[[NSNotificationCenter defaultCenter] postNotificationName:BPItemDeletedNotification object:dict];
	
	// if this wasn't the last row deleted, select the next row
	if ([_items count] > 1) {
		BPItem *itemToSelect = nil;
		
		// if we deleted the last item in the list, select the previous one
		if (([_items count] - 1) == row) {
			itemToSelect = [_items objectAtIndex:row - 1];
		} else { // select next item in list
			itemToSelect = [_items objectAtIndex:row + 1];
		}
		
		NSMutableDictionary *itemToSelectDict = [NSMutableDictionary dictionary];
		[itemToSelectDict setObject:itemToSelect forKey:kKeyItem];
		[[NSNotificationCenter defaultCenter] postNotificationName:BPSelectItemInItemListNotification object:itemToSelectDict];					
	}    
}

- (void)itemManager:(BPItemManager *)itemManager deleteItem:(BPItem *)item failedWithError:(NSError *)error {
    
}

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
	//NSArray *_items = [[BPItemManager sharedInstance] itemsForCurrentDisplayedDirectoryPathFilteredBySearchString:searchString];
	NSArray *_items = self.items;
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

- (IBAction)deleteButtonPressed:(id)sender {
	
    if (self.addActionSheet.visible) {
        [self.addActionSheet dismissWithClickedButtonIndex:-1 animated:NO];
    }
	
	[self deleteSelectedRow];
    
    //[addActionSheet showFromBarButtonItem:addButton animated:YES];	
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
	[currentDirectoryItem release];
	[currentSelectedItem release];
	[searchString release];
	[itemManager release];
	[items release];
	[loadingView release];
    [super dealloc];
}


@end

