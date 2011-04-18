//
//  SettingsTableViewController.m
//  text
//
//  Created by Brian Pfeil on 5/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsTableViewController.h"

@interface SettingsTableViewController()

- (void)reload;

@property(nonatomic, retain) NSDictionary* settingsMetadata;

@end


typedef enum {
	kSettingsGroup_Color = 0,
	kSettingsGroup_Font
} SettingsGroup;

@implementation SettingsTableViewController

@synthesize settingsMetadata;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] != nil) {
		self.title = @"Settings";
		self.settingsMetadata = [[BPMetadata sharedInstance] metadataForPropertyName:@"settings"];
	}
	return self;
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self reload];
}

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
    return [[settingsMetadata valueForKeyPath:@"sections"] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray* sections = [settingsMetadata valueForKeyPath:@"sections"];
	NSDictionary* sectionMetadata = [sections objectAtIndex:section];
	return [[sectionMetadata valueForKeyPath:@"rows"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSArray* sections = [settingsMetadata valueForKeyPath:@"sections"];
	NSDictionary* sectionMetadata = [sections objectAtIndex:section];
	return [sectionMetadata valueForKeyPath:@"name"];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }

	NSArray* sections = [settingsMetadata valueForKeyPath:@"sections"];
	NSDictionary* sectionMetadata = [sections objectAtIndex:indexPath.section];
	NSArray* rows = [sectionMetadata valueForKeyPath:@"rows"];
	NSDictionary* rowMetadata = [rows objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [rowMetadata valueForKeyPath:@"name"];
	NSString* defaultsKeyName = [rowMetadata valueForKeyPath:@"defaultsKeyName"];
	NSString* defaultsFontName = [[NSUserDefaults standardUserDefaults] valueForKey:defaultsKeyName];
	cell.detailTextLabel.text = (defaultsFontName != nil) ? defaultsFontName : [rowMetadata valueForKeyPath:@"defaultValue"];
    
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
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */

	NSArray* sections = [settingsMetadata valueForKeyPath:@"sections"];
	NSDictionary* sectionMetadata = [sections objectAtIndex:indexPath.section];
	NSArray* rows = [sectionMetadata valueForKeyPath:@"rows"];
	NSDictionary* rowMetadata = [rows objectAtIndex:indexPath.row];	
	NSString* name = [rowMetadata valueForKeyPath:@"name"];
	
	if ([name isEqualToString:@"Link to Dropbox"]) {
		if (![[DBSession sharedSession] isLinked]) {
			DBLoginController* controller = [[DBLoginController new] autorelease];
			controller.delegate = self;
			[controller presentFromController:self.navigationController];
		} else {
			[[DBSession sharedSession] unlink];			
			[[NSUserDefaults standardUserDefaults] setValue:@"Link" forKey:@"dropboxLink"];

			[[[[UIAlertView alloc] 
			   initWithTitle:@"Account Unlinked!" message:@"Your dropbox account has been unlinked" 
			   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
			  autorelease]
			 show];
			
			[self reload];
		}			
	} else if ([name isEqualToString:@"Text"]) {
		ColorPickerViewController* cpvc = [[ColorPickerViewController alloc] init];
		cpvc.title = @"Text Color";
		cpvc.onPickCompleteBlock = ^(NSDictionary* colorDefinition) {
			NSString* colorName = [colorDefinition valueForKeyPath:@"name"];
			[[NSUserDefaults standardUserDefaults] setValue:colorName forKey:@"textColor"];
			[[NSNotificationCenter defaultCenter] postNotificationName:BPSettingsChangedNotification object:nil];
		};
		[self.navigationController pushViewController:cpvc animated:YES];
		[cpvc release];
	} else if ([name isEqualToString:@"Background"]) {
		ColorPickerViewController* cpvc = [[ColorPickerViewController alloc] init];
		cpvc.onPickCompleteBlock = ^(NSDictionary* colorDefinition) {
			NSString* colorName = [colorDefinition valueForKeyPath:@"name"];
			[[NSUserDefaults standardUserDefaults] setValue:colorName forKey:@"backgroundColor"];
			[[NSNotificationCenter defaultCenter] postNotificationName:BPSettingsChangedNotification object:nil];
		};		
		cpvc.title = @"Background Color";
		[self.navigationController pushViewController:cpvc animated:YES];
		[cpvc release];		
	} else if ([name isEqualToString:@"Font"]) {
		ARFontPickerViewController* fpvc = [[ARFontPickerViewController alloc] init];
		fpvc.delegate = self;
		fpvc.title = @"Font";
		[self.navigationController pushViewController:fpvc animated:YES];
		[fpvc release];		
	} else if ([name isEqualToString:@"Size"]) {
		GenericPickerViewController* gpvc = [[GenericPickerViewController alloc] init];
		gpvc.items = [BPApp sharedInstance].fontSizeDefinitions;
		gpvc.onPickCompleteBlock = ^(NSDictionary* item) {
			NSString* fontSizeName = [item valueForKeyPath:@"name"];
			NSString* fontSizeString = [item valueForKeyPath:@"value"];
			[[NSUserDefaults standardUserDefaults] setValue:fontSizeName forKey:@"fontSize"];
			[[NSNotificationCenter defaultCenter] postNotificationName:BPSettingsChangedNotification object:nil];
		};
		gpvc.title = @"Font Size";
		[self.navigationController pushViewController:gpvc animated:YES];
		[gpvc release];		
	}
	
}

#pragma mark DBLoginControllerDelegate methods

- (void)loginControllerDidLogin:(DBLoginController*)controller {
	[[NSUserDefaults standardUserDefaults] setValue:@"Unlink" forKey:@"dropboxLink"];
    [self reload];
}

- (void)loginControllerDidCancel:(DBLoginController*)controller {
	
}

- (void)fontPickerViewController:(ARFontPickerViewController *)fontPicker didSelectFont:(NSString *)fontName {
	NSLog(@"fontName = %@", fontName);
	[[NSUserDefaults standardUserDefaults] setValue:fontName forKey:@"fontName"];
	[self.navigationController popViewControllerAnimated:YES];
	[self reload];
	[[NSNotificationCenter defaultCenter] postNotificationName:BPSettingsChangedNotification object:nil];					
}

- (void)reload {
	[self.tableView reloadData];
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
	[settingsMetadata release];
    [super dealloc];
}


@end

