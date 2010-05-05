    //
//  NewItemViewController.m
//  text
//
//  Created by Brian Pfeil on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NewItemViewController.h"


@implementation NewItemViewController

@synthesize itemType, titleLabel, titleText, inputValueTextField, inputValueText;

- (NSString*)getInputValue {
	return inputValueTextField.text;
}

#pragma mark -
#pragma mark Button Handlers

- (IBAction)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)okButtonPressed:(id)sender {
	
	// create item
	NSString *itemName = inputValueTextField.text;
	NSString *currentDisplayedDirectoryPath = [[BPItemManager sharedInstance] currentDisplayedDirectoryPath];
	
	BPItem *item = nil;
	
	if (itemType == kItemTypeFile) {
		item = [[BPItemManager sharedInstance] createFileItemWithFileName:itemName atDirectoryPath:currentDisplayedDirectoryPath];		
	} else if (itemType == kItemTypeFolder) {
		item = [[BPItemManager sharedInstance] createFolderItemWithFolderName:itemName atDirectoryPath:currentDisplayedDirectoryPath];
	}
	
	// select item
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:item forKey:kKeyItem];
	[[NSNotificationCenter defaultCenter] postNotificationName:BPSelectItemInItemListNotification object:dict];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)inputValueTextFieldTextDidChangeNotification:(NSNotification*)notification {
	UITextField *textField = [notification object];
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(inputValueTextFieldTextDidChangeNotification:)
												 name:UITextFieldTextDidChangeNotification
											   object:inputValueTextField];
	
	
	titleLabel.text = titleText;
	inputValueTextField.text = inputValueText;
	[inputValueTextField becomeFirstResponder];
    [super viewDidLoad];
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
    [super dealloc];
}


@end