//
//  LocationDetailsViewController.h
//  MyLocations
//
//  Created by Maijid  Moujaled on 12/19/11.
//  Copyright (c) 2011 Grinnell College. All rights reserved.
//

//#import <CoreLocation/CoreLocation.h> I didn't need to do this because i simply put this into the MyLocations-Prefix. pre compiled header. 



#import "CategoryPickerViewController.h"

@class Location;

@interface LocationDetailsViewController : UITableViewController <UITextViewDelegate, CategoryPickerViewControllerDelegate>

@property (nonatomic,strong) IBOutlet UITextView *descriptionTextView;
@property (nonatomic,strong) IBOutlet UILabel *categoryLabel;
@property (nonatomic,strong) IBOutlet UILabel *latitudeLabel;
@property (nonatomic,strong) IBOutlet UILabel *longitudeLabel;
@property (nonatomic,strong) IBOutlet UILabel *addressLabel;
@property (nonatomic,strong) IBOutlet UILabel *dateLabel;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) CLPlacemark *placemark;

@property (nonatomic,strong) Location *locationToEdit;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
