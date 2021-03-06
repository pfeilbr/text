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
#import <MobileCoreServices/UTCoreTypes.h>
#import "BPMetadata.h"


enum TextViewActions {
	EMAIL,
	COPY_TO_CLIPBOARD
};


@interface DetailViewController ()

- (void)editItemLabel;
- (void)saveItemLabel;
- (void)renameItem;
- (void)clear;
- (void)inputAccessoryViewButtonClicked:(id)sender;
- (NSDictionary*)inputAccessoryViewDefinitionForItem:(BPItem*)_item;

- (UIImage*)imageIconForItem:(BPItem*)_item;
- (void)showItemLoadingView;
- (void)hideItemLoadingView;

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) BPItemManager* itemManager;
@property (nonatomic, retain) NSDictionary* settingsMetadata;
@property (nonatomic, retain) NSMutableDictionary *inputAccessoryViewCache;
@property (nonatomic, retain) UIWebView* webView;
@property (nonatomic, copy) NSString* tempFilePath;

@end


@implementation DetailViewController

@synthesize toolbar, toggleFullScreenButtonItem, itemLabel, itemLabelTextField, itemLabelBarButtonItem, popoverController, detailDescriptionLabel, textView, inputAccessoryView, rootViewController, actionsButton, actionSheet, settingsButton, inputAccessoryViewCache;
@synthesize itemManager, item, inputAccessoryViewDefinition;
@synthesize settingsMetadata;
@synthesize contentWebViewController;
@synthesize webView;
@synthesize tempFilePath;
@synthesize itemLoadingView;
@synthesize itemLoadingBackgroundView;

/*
- (void)awakeFromNib {
	self.settingsMetadata = [[BPMetadata sharedInstance] metadataForPropertyName:@"settings"];	
}
*/

#pragma mark ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)_actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	// return if user clicked off the sheet and didn't select a button
	if (buttonIndex == -1) {
		return;
	}
	
	[self saveCurrentItem];
	
	NSString *buttonTitle = [_actionSheet buttonTitleAtIndex:buttonIndex];
	NSString *fileName = item.name;
	
	if ([buttonTitle isEqualToString:BPItemActionRenameFile]) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:item forKey:kKeyItem];
		[[NSNotificationCenter defaultCenter] postNotificationName:BPRenameFileNotification object:dict];			
	} else if ([buttonTitle isEqualToString:BPItemActionRenameFolder]) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:@"" forKey:kKeyItem];
		[[NSNotificationCenter defaultCenter] postNotificationName:BPRenameFolderNotification object:dict];
	} else if ([buttonTitle isEqualToString:BPItemActionEmailFile]) {
		NSString *body = [item contents];
		MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
		vc.mailComposeDelegate = self;		
		[vc setSubject:fileName];        
		[vc setMessageBody:body isHTML:NO];
		vc.modalPresentationStyle = UIModalPresentationPageSheet;
		[self presentModalViewController:vc animated:YES];
		[vc release];		
	} else if ([buttonTitle isEqualToString:BPItemActionCopyFileToClipboard]) {
		NSString *body = [textView clipboardText];			
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		[pasteboard setString:body];		
	} else if ([buttonTitle isEqualToString:BPItemActionWebPreview]) {
		NSString *body = [item contents];
		if (contentWebViewController == nil) {
			self.contentWebViewController = [[ContentWebViewController alloc] initWithNibName:@"ContentWebViewController" bundle:nil];
			contentWebViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		}
		[self.splitViewController presentModalViewController:contentWebViewController animated:YES];
		[contentWebViewController.contentWebView loadHTMLString:body baseURL:nil];
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
	self.view.backgroundColor = [UIColor grayColor];
}

#pragma mark -
#pragma mark Item Management

- (void)renameItem {
	[self saveItemLabel];
	NSString *toPath = [[BPItemManager sharedInstance].currentDisplayedDirectoryItem.path stringByAppendingPathComponent:itemLabel.text];
	NSError *err;
	BPItem *_item = [[BPItemManager sharedInstance] moveItem:item toPath:toPath error:&err];
	[self setDetailItem:_item];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:_item forKey:kKeyItem];
	[[NSNotificationCenter defaultCenter] postNotificationName:BPSelectItemInItemListNotification object:dict];	
}

- (void)addNewFile:(NSNotification*)notification {	
	NewItemViewController *nivc = [[NewItemViewController alloc] initWithNibName:@"NewItemViewController" bundle:nil];
    BPItem* currentDirectoryItem = [[((NewItemViewController*)self.rootViewController) visibleViewController] currentDirectoryItem];
    nivc.itemManager = [[BPItemManager alloc] initWithItem:currentDirectoryItem];
	nivc.modalPresentationStyle = UIModalPresentationFormSheet;
	nivc.mode = BPItemPropertyModifyModeNew;
	nivc.itemType = BPItemPropertyTypeFile;
	nivc.titleText = BPAddNewFileTitle;
	nivc.inputValueText = [[BPItemManager sharedInstance] nextDefaultFileNameForCurrentDisplayedDirectoryPath];
	[self presentModalViewController:nivc animated:YES];
	[nivc release];		
}

- (void)renameFile:(NSNotification*)notification {
	NSDictionary *dict = [notification object];
	BPItem *_item = [dict valueForKey:kKeyItem];
	NewItemViewController *nivc = [[NewItemViewController alloc] initWithNibName:@"NewItemViewController" bundle:nil];
    nivc.itemManager = [[BPItemManager alloc] initWithItem:self.rootViewController.currentDirectoryItem];    
	nivc.modalPresentationStyle = UIModalPresentationFormSheet;
	nivc.mode = BPItemPropertyModifyModeRename;
	nivc.itemType = BPItemPropertyTypeFile;
	nivc.titleText = BPRenameFileTitle;
	nivc.inputValueText = _item.name;
	
	NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithObject:_item forKey:kKeyItem];
	nivc.data = dataDict;
	
	[self presentModalViewController:nivc animated:YES];
	[nivc release];		
}

- (void)renameFolder:(NSNotification*)notification {
	//NSArray *viewControllers = rootViewController.navigationController.viewControllers;
	UIViewController *vc = rootViewController.navigationController.topViewController;
	BPItem *item1 = ((ItemTableViewController*)vc).currentSelectedItem;
	NSDictionary *_dict = [NSDictionary dictionaryWithObject:item1 forKey:kKeyItem];
	NSNotification *_notification = [NSNotification notificationWithName:[notification name] object:_dict];
	
	NSDictionary *dict = [_notification object];
	BPItem *_item = [dict valueForKey:kKeyItem];
	NewItemViewController *nivc = [[NewItemViewController alloc] initWithNibName:@"NewItemViewController" bundle:nil];
    nivc.itemManager = [[BPItemManager alloc] initWithItem:self.rootViewController.currentDirectoryItem];    
	nivc.modalPresentationStyle = UIModalPresentationFormSheet;
	nivc.mode = BPItemPropertyModifyModeRename;
	nivc.itemType = BPItemPropertyTypeFolder;
	nivc.titleText = BPRenameFolderTitle;
	nivc.inputValueText = _item.name;
	
	NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithObject:_item forKey:kKeyItem];
	nivc.data = dataDict;
	
	[self presentModalViewController:nivc animated:YES];
	[nivc release];
}

- (void)addNewFolder:(NSNotification*)notification {
	[self saveCurrentItem];
	NewItemViewController *nivc = [[NewItemViewController alloc] initWithNibName:@"NewItemViewController" bundle:nil];
    BPItem* currentDirectoryItem = [[((NewItemViewController*)self.rootViewController) visibleViewController] currentDirectoryItem];
    nivc.itemManager = [[BPItemManager alloc] initWithItem:currentDirectoryItem];
	nivc.modalPresentationStyle = UIModalPresentationFormSheet;
	nivc.mode = BPItemPropertyModifyModeNew;	
	nivc.itemType = BPItemPropertyTypeFolder;
	nivc.titleText = BPAddNewFolderTitle;
	nivc.inputValueText = [[BPItemManager sharedInstance] nextDefaultFolderNameForCurrentDisplayedDirectoryPath];
	[self presentModalViewController:nivc animated:YES];
	[nivc release];
}

- (void)settingsChanged:(NSNotification*)notification {
	[self applySettings];
}

#pragma mark Button Handlers

- (IBAction)actionsButtonPressed:(id)sender {
	// hde settings popover if being displayed
    if (popoverController != nil && popoverController.popoverVisible) {
        [popoverController dismissPopoverAnimated:YES];
    }

	// toggle display of Action sheet
    if (self.actionSheet.visible) {
		[self.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
    } else {
		[actionSheet showFromBarButtonItem:actionsButton animated:YES];
	}
}

- (IBAction)settingsButtonPressed:(id)sender {
	// hide action sheet if being displayed
    if (self.actionSheet.visible) {
        [self.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
    }
	
	// toggle display of settings popover
    if (popoverController != nil && popoverController.popoverVisible) {
        [popoverController dismissPopoverAnimated:YES];
    } else {
		UINavigationController* nc = [[UINavigationController alloc] init];
		SettingsTableViewController *stvc = [[SettingsTableViewController alloc] initWithNibName:@"SettingsTableViewController" bundle:nil];
		[nc pushViewController:stvc animated:NO];
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:nc];
		[popoverController presentPopoverFromBarButtonItem:settingsButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		[stvc release];
		[nc release];
	}
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
	self.itemManager = [[BPItemManager alloc] initWithItem:_item];
	itemManager.delegate = self;
	
	itemLoadingView.imageView.image = [self imageIconForItem:_item];
	itemLoadingView.label.text = item.name;
	[self showItemLoadingView];
	
	[itemManager loadItem:_item];	
}

- (void)itemManager:(BPItemManager*)itemManager loadedItem:(BPItem*)_item data:(NSData*)data {
    NSString* contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

	self.title = item.name;
	itemLabel.text = item.name;
	itemLabelTextField.text = item.name;	
	
	// editable text based file
	if (contents != nil) {
    	textView.text = contents;
    	textView.hidden = NO;
    	textView.inputAccessoryView = [self inputAccessoryViewForItem:_item];
    	self.inputAccessoryViewDefinition = [self inputAccessoryViewDefinitionForItem:_item];	    
    	
        webView.hidden = YES;
	} else { // not text based file - let webview render
        textView.hidden = YES;
	    
		// delete the previous temp file
		if (tempFilePath != nil) {
			[[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
		}
		
    	self.tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:item.name];
    	[data writeToFile:tempFilePath atomically:YES];
    	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:tempFilePath]]];
    	webView.hidden = NO;	    
	}
	
	// hide action sheet if being displayed
    if (self.actionSheet.visible) {
        [self.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
    }	
	
	// hide popover if being displayed
	if (popoverController != nil && popoverController.popoverVisible) {
		[popoverController dismissPopoverAnimated:YES];
	}
		
	[[NSUserDefaults standardUserDefaults] setObject:[item dictionaryRepresentation] forKey:BPDefaultsLastItemDisplayed];
	[self applySettings];
	
	[self hideItemLoadingView];
}

- (void)itemManager:(BPItemManager*)itemManager loadItem:(BPItem*)item failedWithError:(NSError*)error {
	[self hideItemLoadingView];
}

- (void)itemManager:(BPItemManager *)itemManager createdFileItem:(BPItem *)item {
    NSLog(@"itemManager:createdFileItem");
}

- (UIImage*)imageIconForItem:(BPItem*)_item {
	UIImage* image = nil;
	
	if ([_item.iconName isEqualToString:@""]) {
		UIDocumentInteractionController* dic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:_item.path]];
		dic.name = item.name;
		if (dic.icons != nil && ([dic.icons count] > 0)) {
			image = [dic.icons objectAtIndex:0];
		}		
	} else {
		NSString* iconImagePath = [[BPApp sharedInstance] getLargeIconImagePathForIconNamed:_item.iconName];
		image = [UIImage imageWithContentsOfFile:iconImagePath];
	}
	return image;
}

- (void)showTextView {
}

- (void)hideTextView {
}


- (void)showWebView {
}

- (void)hideWebView {
}

- (void)showItemLoadingView {
	itemLoadingBackgroundView.frame = textView.frame;
	itemLoadingBackgroundView.center = textView.center;
	
	itemLoadingView.center = textView.center;
	
	[UIView beginAnimations:nil context:nil];
	itemLoadingBackgroundView.hidden = NO;	
	itemLoadingView.hidden = NO;
	itemLoadingView.alpha = 1.0;
	itemLoadingBackgroundView.alpha = 1.0;
	[UIView commitAnimations];
}

- (void)hideItemLoadingView {
	[UIView beginAnimations:nil context:nil];
	itemLoadingView.hidden = YES;
	itemLoadingBackgroundView.hidden = YES;
	itemLoadingView.alpha = 0.0;
	itemLoadingBackgroundView.alpha = 0.0;
	[UIView commitAnimations];	
}


- (void)applySettings {

	NSArray* sections = [settingsMetadata valueForKeyPath:@"sections"];
	
	for (NSDictionary* sectionMetadata in sections) {
		NSArray* rows = [sectionMetadata valueForKeyPath:@"rows"];
		for (NSDictionary* rowMetadata in rows) {
			NSString* defaultsKeyName = [rowMetadata valueForKeyPath:@"defaultsKeyName"];
			NSString* defaultsValue = [[NSUserDefaults standardUserDefaults] valueForKey:defaultsKeyName];
			NSString* defaultValue = (defaultsValue != nil) ? defaultsValue : [rowMetadata valueForKeyPath:@"defaultValue"];
			
			if ([defaultsKeyName isEqualToString:@"fontName"]) {
				textView.font = [UIFont fontWithName:defaultValue size:textView.font.pointSize];
			}
			
			if ([defaultsKeyName isEqualToString:@"fontSize"]) {
				
				NSArray* fontSizeDefs = [BPApp sharedInstance].fontSizeDefinitions;
				
				for (NSDictionary* fontSizeDef in fontSizeDefs){
					NSString* name = [fontSizeDef valueForKey:@"name"];
					if ([name isEqualToString:defaultValue]) {
						CGFloat fontSize = [[fontSizeDef valueForKey:@"value"] floatValue];
						textView.font = [UIFont fontWithName:textView.font.fontName size:fontSize];						
					}
				}
				
			}
			
			if ([defaultsKeyName isEqualToString:@"textColor"]) {
				SEL sel = NSSelectorFromString(defaultValue);
				UIColor* color = objc_msgSend([UIColor class], sel);
				textView.textColor = color;
				NSLog(@"defaultsValue = %@", defaultValue);
			}
			
			if ([defaultsKeyName isEqualToString:@"backgroundColor"]) {
				SEL sel = NSSelectorFromString(defaultValue);
				UIColor* color = objc_msgSend([UIColor class], sel);
				textView.backgroundColor = color;
				NSLog(@"defaultsValue = %@", defaultValue);
			}
			
			
		}
	}
	
}

- (UIView*)inputAccessoryViewForItem:(BPItem*)_item {
	if (!inputAccessoryViewCache) {
		inputAccessoryViewCache = [NSMutableDictionary dictionary];
	}
	NSDictionary *_inputAccessoryViewDefinition = [self inputAccessoryViewDefinitionForItem:_item];
	UIToolbar *_toolbar = (UIToolbar*)[inputAccessoryView viewWithTag:1];
	NSMutableArray *buttons = [NSMutableArray array];
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:flexibleSpace];
	NSArray *keyDefinitions = [_inputAccessoryViewDefinition valueForKey:@"keys"];
	for (NSDictionary *keyDefinition in keyDefinitions) {
		NSString *label = [keyDefinition valueForKey:@"label"];
		//NSString *text = [keyDefinition valueForKey:@"text"];
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"    %@    ", label] style:UIBarButtonItemStyleBordered target:self action:@selector(inputAccessoryViewButtonClicked:)];
		[buttons addObject:button];
		[buttons addObject:flexibleSpace];
	}
	_toolbar.items = buttons;
	
	return inputAccessoryView;
}

- (NSDictionary*)inputAccessoryViewDefinitionForItem:(BPItem*)_item {
	NSString *fileExtension = [_item.name pathExtension];
	NSString *fileType = [[BPConfig sharedInstance] typeForFileExtension:fileExtension];	
	NSDictionary *_inputAccessoryViewDefinition = [[BPConfig sharedInstance] keyboardAccessoryDefinitionForType:fileType];
	return _inputAccessoryViewDefinition;
}

- (void)inputAccessoryViewButtonClicked:(id)sender {
	UIBarButtonItem *barButtonItem = (UIBarButtonItem*)sender;
	NSString *label = barButtonItem.title;
	NSString *text = @"";
	NSArray *keys = [inputAccessoryViewDefinition valueForKey:@"keys"];
	for (NSDictionary *key in keys){
		if ([label isEqualToString:[NSString stringWithFormat:@"    %@    ", [key valueForKey:@"label"]]]) {
			text = [key valueForKey:@"text"];
		}
	}
	UIPasteboard *pb = [UIPasteboard generalPasteboard];
	NSString *savedString = pb.string;
	[pb setValue:text forPasteboardType:(NSString*)kUTTypeUTF8PlainText];
	[textView paste:self];
	
	// restore previous contents of pastborad back
	if (savedString != nil) {
		[pb setValue:savedString forPasteboardType:(NSString*)kUTTypeUTF8PlainText];
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

	[itemManager saveItem:self.item withText:textView.text];
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
    [items removeObject:toggleFullScreenButtonItem];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [items insertObject:toggleFullScreenButtonItem atIndex:0];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
}

#pragma mark -
#pragma mark View lifecycle


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	/*
	NSMutableArray* toolbarItems = [NSMutableArray arrayWithObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(toggleMasterView:)]];
	[toolbarItems addObjectsFromArray:self.toolbar.items];
	self.toolbar.items = toolbarItems;
	*/

	self.tempFilePath = nil;
	
	self.settingsMetadata = [[BPMetadata sharedInstance] metadataForPropertyName:@"settings"];	
	
	self.webView = [[UIWebView alloc] initWithFrame:textView.frame];
	webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	//webView.multipleTouchEnabled = YES;
	webView.scalesPageToFit = YES;
	[self.view addSubview:webView];	
	webView.hidden = YES;
	
	self.itemLoadingBackgroundView = [[UIView alloc] init];
	itemLoadingBackgroundView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:itemLoadingBackgroundView];
	itemLoadingBackgroundView.hidden = YES;
	
	[[NSBundle mainBundle] loadNibNamed:@"ItemLoadingView" owner:self options:nil];
	itemLoadingView.center = textView.center;
	[self.view addSubview:itemLoadingView];
	itemLoadingView.hidden = YES;
	
	[self hideItemLoadingView];
	
	itemLabelBarButtonItem.customView.backgroundColor = [UIColor clearColor];
	itemLabel.backgroundColor = [UIColor clearColor];
    
    self.toggleFullScreenButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(toggleFullScreen:)];
	
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
												  otherButtonTitles:BPItemActionRenameFile, BPItemActionRenameFolder, BPItemActionEmailFile, BPItemActionCopyFileToClipboard, BPItemActionWebPreview, nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											       selector:@selector(orientationDidChange:)
													    name:@"UIDeviceOrientationDidChangeNotification"
													  object:nil];
	
	[self clear];
}

- (void)toggleFullScreen:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:BPToggleFullScreenNotification object:self userInfo:nil];
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
	[itemLabelBarButtonItem release];
	[itemLabel release];
	[itemLabelTextField release];
	[detailDescriptionLabel release];
	[textView release];
	[inputAccessoryView release];
	[item release];
	[actionsButton release];
	[actionSheet release];
	[settingsButton release];
	[settingsMetadata release];
	[itemManager release];
	[webView release];
    
	[super dealloc];
}	


@end
