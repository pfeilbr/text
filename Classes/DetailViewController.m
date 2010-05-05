//
//  DetailViewController.m
//  text
//
//  Created by Brian Pfeil on 4/28/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "TextAppDelegate.h"

enum TextViewActions {
	EMAIL,
	COPY_TO_CLIPBOARD
};


@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)editItemLabel;
- (void)saveItemLabel;
- (void)renameItem;
- (void)clear;
@end


@implementation DetailViewController

@synthesize toolbar, itemLabel, itemLabelTextField, itemLabelBarButtonItem, popoverController, detailDescriptionLabel, textView, keyboardAccessoryView, rootViewController, actionsButton, actionSheet, settingsButton;
@synthesize item;

#pragma mark ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self saveCurrentItem];
	
	NSString *fileName = item.name;

	switch (buttonIndex) {
		case EMAIL:
		{
			NSString *body = [item contents];
			MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
			vc.mailComposeDelegate = self;		
			[vc setSubject:fileName];        
			[vc setMessageBody:body isHTML:NO];
			vc.modalPresentationStyle = UIModalPresentationPageSheet;
			[self presentModalViewController:vc animated:YES];
			[vc release];
			break;
		}
		case COPY_TO_CLIPBOARD:
		{
			NSString *body = [textView clipboardText];			
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			[pasteboard setString:body];
			break;
		}
		default:
			break;
	}
}

#pragma mark -
#pragma mark Managing the detail item

- (void)orientationDidChange:(NSNotification *)notification {
}

- (void)itemLabelTextFieldDidEndEditingNotification:(NSNotification*)notification {
	//UITextField *textField = [notification object];
	[self renameItem];
}

- (void)itemDeletedNotification:(NSNotification*)notification {
	BPItem *_item = [[notification object] valueForKey:kKeyItem];
	if ([self.item isEqualToItem:_item]) {
		[self clear];
	}
}

- (void)clear {
	self.item = nil;
	itemLabel.text = @"";
	textView.text = @"";
	textView.hidden = YES;
}

#pragma mark -
#pragma mark Item Management

- (void)renameItem {
	[self saveItemLabel];
	NSString *toPath = [[BPItemManager sharedInstance].currentDisplayedDirectoryPath stringByAppendingPathComponent:itemLabel.text];
	BPItem *_item = [[BPItemManager sharedInstance] renameFileItemFromPath:item.path toPath:toPath];
	[self setDetailItem:_item];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:_item forKey:kKeyItem];
	[[NSNotificationCenter defaultCenter] postNotificationName:BPSelectItemInItemListNotification object:dict];	
}

- (void)addNewFile:(NSNotification*)notification {
	/*
	[self saveCurrentItem];
	BPItem *_item = [[BPItemManager sharedInstance] createDefaultFileItemAtCurrentDisplayedDirectoryPath];
	[self setDetailItem:_item];
	[self editItemLabel];
	 */
	
	NewItemViewController *nivc = [[NewItemViewController alloc] initWithNibName:@"NewItemViewController" bundle:nil];
	nivc.modalPresentationStyle = UIModalPresentationFormSheet;
	nivc.itemType = kItemTypeFile;
	nivc.titleText = BPAddNewFileTitle;
	nivc.inputValueText = [[BPItemManager sharedInstance] nextDefaultFileNameForCurrentDisplayedDirectoryPath];
	[self presentModalViewController:nivc animated:YES];
	[nivc release];	
	
}

- (void)addNewFolder:(NSNotification*)notification {
	[self saveCurrentItem];
	NewItemViewController *nivc = [[NewItemViewController alloc] initWithNibName:@"NewItemViewController" bundle:nil];
	nivc.modalPresentationStyle = UIModalPresentationFormSheet;
	nivc.itemType = kItemTypeFolder;
	nivc.titleText = BPAddNewFolderTitle;
	nivc.inputValueText = [[BPItemManager sharedInstance] nextDefaultFolderNameForCurrentDisplayedDirectoryPath];
	[self presentModalViewController:nivc animated:YES];
	[nivc release];
}


#pragma mark Button Handlers

- (IBAction)actionsButtonPressed:(id)sender {
    if (self.actionSheet.visible) {
        [self.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
    }
    
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }
    
    [actionSheet showFromBarButtonItem:actionsButton animated:YES];
}

- (IBAction)settingsButtonPressed:(id)sender {
	SettingsTableViewController *stvc = [[SettingsTableViewController alloc] initWithNibName:@"SettingsTableViewController" bundle:nil];
	self.popoverController = [[UIPopoverController alloc] initWithContentViewController:stvc];
	[popoverController presentPopoverFromBarButtonItem:settingsButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	[stvc release];
}

#pragma mark -
#pragma mark Mail Composer Delegate

// Dismisses the email composition interface when users tap Cancel or Send.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {	
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Managing the detail item

- (void)setDetailItem:(BPItem*)_item {
	self.item = _item;
	self.title = item.name;
	itemLabel.text = item.name;
	itemLabelTextField.text = item.name;
	textView.text = [item contents];
	textView.hidden = NO;
		
	if (popoverController != nil) {
		[popoverController dismissPopoverAnimated:YES];
	}
}

- (void)editItemLabel {
	//[UIView beginAnimations:nil context:nil];	
	itemLabel.hidden = YES;
	itemLabelTextField.hidden = NO;
	[itemLabelTextField becomeFirstResponder];	
	itemLabelTextField.text = itemLabel.text;	
	//[UIView commitAnimations];	
}

- (void)saveItemLabel {
	//[UIView beginAnimations:nil context:nil];
	itemLabel.text = itemLabelTextField.text;
	itemLabelTextField.hidden = YES;
	itemLabel.hidden = NO;
	//[UIView commitAnimations];
}


- (void)saveCurrentItem {
	if (item == nil) {
		return;
	}
	NSError *err;
	BOOL saved = [[BPItemManager sharedInstance] saveItem:self.item withText:textView.text error:&err];
	if (!saved) {
		;
	}
}

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
/*
- (void)setDetailItem:(NSManagedObject *)managedObject {
    
	if (detailItem != managedObject) {
		[detailItem release];
		detailItem = [managedObject retain];
		
        // Update the view.
        [self configureView];
	}
    
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }		
}
*/

#pragma mark -
#pragma mark Text View delegate

- (void)textViewDidChange:(UITextView *)textView {
	[self saveCurrentItem];	
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	NSLog(@"textViewDidEndEditing");
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = @"Files";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
}


#pragma mark -
#pragma mark View lifecycle


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	itemLabelBarButtonItem.customView.backgroundColor = [UIColor clearColor];
	itemLabel.backgroundColor = [UIColor clearColor];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(itemLabelTextFieldDidEndEditingNotification:)
												 name:UITextFieldTextDidEndEditingNotification
											   object:itemLabelTextField];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(itemDeletedNotification:)
												 name:BPItemDeletedNotification
											   object:nil];	
	
	
	
	
	 self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															delegate:self
												  cancelButtonTitle:nil
											destructiveButtonTitle:nil
												  otherButtonTitles:@"Email", @"Copy to Clipboard", nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											       selector:@selector(orientationDidChange:)
													    name:@"UIDeviceOrientationDidChangeNotification"
													  object:nil];
 	textView.inputAccessoryView = keyboardAccessoryView;
	
	[self clear];
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

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.popoverController = nil;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	
    [popoverController release];
    [toolbar release];
	
	[detailDescriptionLabel release];
    
	[super dealloc];
}	


@end
