//
//  DetailViewController.m
//  text
//
//  Created by Brian Pfeil on 4/28/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"

enum TextViewActions {
	EMAIL,
	COPY_TO_CLIPBOARD
};


@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end



@implementation DetailViewController

@synthesize toolbar, popoverController, detailItem, detailDescriptionLabel, textView, rootViewController, actionsButton, actionSheet;


#pragma mark -
#pragma mark Object insertion

- (IBAction)insertNewObject:(id)sender {
	
	[rootViewController insertNewObject:sender];	
}

#pragma mark ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *fileName = [NSString stringWithString:@"<filename here>"];

	switch (buttonIndex) {
		case EMAIL:
		{
			NSString *body = [textView emailText];
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
    if (buttonIndex	== 0) {
        // email request details
		/*
        MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
        vc.mailComposeDelegate = self;		
        [vc setSubject:[NSString stringWithFormat:@"HTTP Request: %@", request.name]];        
        [vc setMessageBody:[request toEmail] isHTML:NO];
        vc.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentModalViewController:vc animated:YES];
        [vc release];        
		 */
    } else if (buttonIndex == 1) {
        // copy curl command
       /* 
		*/
    }
}

#pragma mark -
#pragma mark Managing the detail item

- (void)orientationDidChange:(NSNotification *)notification {
	// reload the table view to correct UILabel widths
	//[NSTimer scheduledTimerWithTimeInterval:0.25 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
	//[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(resizePerformRequestButton) userInfo:nil repeats:NO];
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

#pragma mark -
#pragma mark Mail Composer Delegate

// Dismisses the email composition interface when users tap Cancel or Send.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {	
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
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


- (void)configureView {
    // Update the user interface for the detail item.
    detailDescriptionLabel.text = [[detailItem valueForKey:@"timeStamp"] description];
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
	 self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															delegate:self
												  cancelButtonTitle:nil
											destructiveButtonTitle:nil
												  otherButtonTitles:@"Email", @"Copy to Clipboard", nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											       selector:@selector(orientationDidChange:)
													    name:@"UIDeviceOrientationDidChangeNotification"
													  object:nil];    	
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
	
	[detailItem release];
	[detailDescriptionLabel release];
    
	[super dealloc];
}	


@end
