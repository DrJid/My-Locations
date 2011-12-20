//
//  LocationDetailsViewController.h
//  MyLocations
//
//  Created by Maijid  Moujaled on 12/19/11.
//  Copyright (c) 2011 Grinnell College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class LocationDetailsViewController;


@protocol LocationDetailsViewControllerDelegate <NSObject>
- (void)locationDetailViewControllerDidCancel:(LocationDetailsViewController *)controller;
- (void)locationDetailViewController:(LocationDetailsViewController *)controller didFinishTagging:(CLLocation *)location;
@end

@interface LocationDetailsViewController : UITableViewController



@property (nonatomic, weak) id <LocationDetailsViewControllerDelegate> delegate;

@property (nonatomic,strong) IBOutlet UITextView *descriptionTextView;
@property (nonatomic,strong) IBOutlet UILabel *categoryLabel;
@property (nonatomic,strong) IBOutlet UILabel *latitudeLabel;
@property (nonatomic,strong) IBOutlet UILabel *longitudeLabel;
@property (nonatomic,strong) IBOutlet UILabel *addressLabel;
@property (nonatomic,strong) IBOutlet UILabel *dateLabel;


- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
