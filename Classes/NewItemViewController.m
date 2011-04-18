    //
//  NewItemViewController.m
//  text
//
//  Created by Brian Pfeil on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NewItemViewController.h"

@interface NewItemViewController()
- (void)selectInputValueTextFieldText:(id)sender;
- (void)dismissAndSelectItemInItemList:(BPItem*)item;
- (void)selectItemInItemList:(BPItem*)item;
@end



@implementation NewItemViewController

@synthesize itemManager, data, mode, okBarButtonItem, cancelBarButtonItem, itemType, titleLabel, messageLabel, titleText, inputValueTextField, inputValueText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (NSString*)getInputValue {
	return inputValueTextField.text;
}

- (void)setItemManager:(BPItemManager *)_itemManager {
    itemManager = _itemManager;
    itemManager.delegate = self;
}

#pragma mark -
#pragma mark Button Handlers

- (IBAction)cancelButtonPressed:(id)sender {	
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)okButtonPressed:(id)sender {
		
	// create item
	NSString *itemName = inputValueTextField.text;
	BPItem *currentDisplayedDirectoryItem = [BPItemManager sharedInstance].currentDisplayedDirectoryItem;
	NSString *currentDisplayedDirectoryPath = currentDisplayedDirectoryItem.path;
	
	BPItem *item = nil;
	NSError *err;	
	
	if ([mode isEqualToString:BPItemPropertyModifyModeNew]) {
		if ([itemType isEqualToString:BPItemPropertyTypeFile]) {
			[itemManager createFileItemWithFileName:itemName atDirectoryPath:currentDisplayedDirectoryPath storageType:currentDisplayedDirectoryItem.storageType];
            return;
		} else if ([itemType isEqualToString:BPItemPropertyTypeFolder]) {
			[itemManager createFolderItemWithFolderName:itemName atDirectoryPath:currentDisplayedDirectoryPath storageType:currentDisplayedDirectoryItem.storageType];
            return;
		}		
	} else if ([mode isEqualToString:BPItemPropertyModifyModeRename]) {
		BPItem *_item = [data valueForKey:kKeyItem];
		NSString *path = nil;
		if ([_item.type isEqualToString:BPItemPropertyTypeFile]) {
			path = [[_item directoryPath] stringByAppendingPathComponent:itemName];
		} else if ([_item.type isEqualToString:BPItemPropertyTypeFolder]) {
			path = [[_item.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:itemName];
		}
		item = [[BPItemManager sharedInstance] moveItem:_item toPath:(NSString*)path error:&err];
	}
		
	[self dismissModalViewControllerAnimated:YES];
	
	// select item
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:item forKey:kKeyItem];
	[[NSNotificationCenter defaultCenter] postNotificationName:BPSelectItemInItemListNotification object:dict];	
}

- (void)inputValueTextFieldTextDidChangeNotification:(NSNotification*)notification {
	UITextField *textField = [notification object];
	NSString *text = textField.text;
	
	// no '/' in file or folder names
	if ([text rangeOfString:@"/"].length > 0) {
		inputValueIsValid = NO;		
		messageLabel.text = @"Name cannot include a forward slash '/'";
		
	} else {
		inputValueIsValid = YES;
		messageLabel.text = @"";
	}
	
	okBarButtonItem.enabled = inputValueIsValid;
	NSLog(@"%@", textField.text);
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	inputValueIsValid = YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(inputValueTextFieldTextDidChangeNotification:)
												 name:UITextFieldTextDidChangeNotification
											   object:inputValueTextField];
	
	
	titleLabel.text = titleText;
	inputValueTextField.text = inputValueText;
	[inputValueTextField becomeFirstResponder];
	
	// keyboard must finish animating in before we can do the text selection
	[self performSelector:@selector(selectInputValueTextFieldText:) withObject:self afterDelay:0.5];
}

- (void)selectInputValueTextFieldText:(id)sender {
	[inputValueTextField selectAll:self];
	[UIMenuController sharedMenuController].menuVisible = NO;		
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (inputValueIsValid) {
		[self okButtonPressed:self];
	}

	return NO;
}

- (void)dismissAndSelectItemInItemList:(BPItem*)item {
	[self dismissModalViewControllerAnimated:YES];
    [self selectItemInItemList:item];
}

- (void)selectItemInItemList:(BPItem*)item {
	// select item
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:item forKey:kKeyItem];
	[[NSNotificationCenter defaultCenter] postNotificationName:BPSelectItemInItemListNotification object:dict];    
}

# pragma mark -
#pragma mark BPItemManagerDelegate
- (void)itemManager:(BPItemManager*)itemManager createdFileItem:(BPItem*)item {
    [self dismissAndSelectItemInItemList:item];
}

- (void)itemManager:(BPItemManager*)itemManager createFileItemFailedWithError:(NSError*)error {
    //[self dismissAndSelectItemInItemList:item];
}

- (void)itemManager:(BPItemManager*)itemManager createdFolderItem:(BPItem*)item {
    [self dismissAndSelectItemInItemList:item];
}

- (void)itemManager:(BPItemManager*)itemManager createFolderItemFailedWithError:(NSError*)error {
    //[self dismissAndSelectItemInItemList:item];
}

- (void)itemManager:(BPItemManager*)itemManager movedItem:(BPItem*)item {
    [self dismissAndSelectItemInItemList:item];    
}

- (void)itemManager:(BPItemManager*)itemManager moveItem:(BPItem*)item failedWithError:(NSError*)error {
    [self dismissAndSelectItemInItemList:item];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[data release];
	[mode release];	
	[itemType release];
	[titleLabel release];
	[messageLabel release];
	[okBarButtonItem release];
	[cancelBarButtonItem release];
	[titleText release];
	[inputValueTextField release];
	[inputValueText release];
	
    [super dealloc];
}


@end
