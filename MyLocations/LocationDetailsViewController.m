//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by Maijid  Moujaled on 12/19/11.
//  Copyright (c) 2011 Grinnell College. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "CategoryPickerViewController.h"


@implementation LocationDetailsViewController
{
    NSString *descriptionText;
    NSString *categoryName; //temporarily Store chosen category
}

@synthesize latitudeLabel, longitudeLabel, addressLabel, descriptionTextView, categoryLabel, dateLabel;
@synthesize placemark, coordinate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        descriptionText = @"";
        categoryName = @"No Category";
    }
    return  self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    return [NSString stringWithFormat:@"%@ %@, %@, %@ %@, %@",
            self.placemark.subThoroughfare, self.placemark.thoroughfare,
            self.placemark.locality, self.placemark.administrativeArea,
            self.placemark.postalCode, self.placemark.country];
} 

- (NSString *)formatDate:(NSDate *)theDate
{
    static NSDateFormatter *formatter = nil; //The static.. lazy loading. It will stay alive after the method has been called.. this way.. we wouldn't keep loading a formater every single time coz.. it takes a crap ton of resources. 
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    return [formatter stringFromDate:theDate];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.descriptionTextView.text = descriptionText;
    self.categoryLabel.text = @"";
    
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f",  self.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.longitude];
    
    if (self.placemark) {
        self.addressLabel.text = [self stringFromPlacemark:self.placemark];
    } else {
        self.addressLabel.text = @"No Address Found";
    }
    
    self.dateLabel.text = [self formatDate:[NSDate date]];

    //We're employing the use of this gesture recognizer to help us remove the keyboard after user clicks the screen. 
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(hideKeyboard:)]; //Create the gesture recognizer object and give it a method to call. Target is the object that the method should be sent to. 
    
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer]; //add it to the view. 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.descriptionTextView = nil;
    self.categoryLabel = nil;
    self.latitudeLabel = nil;
    self.longitudeLabel = nil;
    self.addressLabel = nil;
    self.dateLabel = nil;

}

- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (indexPath != nil && indexPath.section == 0 & indexPath.row == 0) {
        return;
    }
    
    [self.descriptionTextView resignFirstResponder];
}


- (void)closeScreen
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    NSLog(@"Description is %@", descriptionText);
    [self closeScreen]; 
    
}
- (IBAction)cancel:(id)sender
{
    [self closeScreen];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickCategory"]) {
        CategoryPickerViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.selectedCategoryName = categoryName;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 88;
    } else if (indexPath.section == 2 && indexPath.row == 2) 
    {
        CGRect rect = CGRectMake(100, 10, 190, 1000);
        self.addressLabel.frame = rect;
        [self.addressLabel sizeToFit];
        
        rect.size.height = self.addressLabel.frame.size.height;
        self.addressLabel.frame = rect;
        
        return self.addressLabel.frame.size.height + 20;
    }else {
        return 44;
    }
}

#pragma mark - UITextViewDelegate
//to update the contents of the ivar whenever the textview has been changed. We use this ivar just to prevent from loosing the text someone's typing. 
- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    descriptionText = [theTextView.text stringByReplacingCharactersInRange:range withString:text];
    return  YES;
}

- (void)textViewDidEndEditing:(UITextView *)theTextView
{
    descriptionText = theTextView.text;
}

//These methods to make the app a little more forgiving. Clicking the cell to trigger the keyboard and the textview. 

//This limits taps on rows to just the cells in the first two sections. 
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1) {
        return indexPath;
    } else {
        return  nil;
    }
}

//handles taps on rows. 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self.descriptionTextView becomeFirstResponder];
    }
}

-(void)categoryPicker:(CategoryPickerViewController *)picker didPickCategory:(NSString *)theCategoryName;
{
    categoryName = theCategoryName;
    self.categoryLabel.text = categoryName;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
