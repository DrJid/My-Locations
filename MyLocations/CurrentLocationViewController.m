//
//  FirstViewController.m
//  MyLocations
//
//  Created by Maijid  Moujaled on 12/19/11.
//  Copyright (c) 2011 Grinnell College. All rights reserved.
//

#import "CurrentLocationViewController.h"

//This is a class extension These methods need to be visible throughout the entire object. 
@interface CurrentLocationViewController()
-(void)updateLabels; //Forward declaration.
- (void)startLocationManager;
- (void)stopLocationManager;
- (void)configureGetButton;
@end

@implementation CurrentLocationViewController 
{
    CLLocationManager *locationManager; //This is the object that will give us the GPS coordinates. We'll create this object with initwithcoder method. Where? Right here in this .m file. 
    CLLocation *location;
    BOOL updatingLocation;
    NSError *lastLocationError;
    
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    BOOL performingReverseGeocoding;
    NSError *lastGeocodingError;
}

@synthesize messageLabel, latitudeLabel, longitudeLabel, addressLabel, tagButton, getButton;




//This is our initwithCoder method. I'm guessing this method is what helps us initialise and use the object. Remember that all objects have to be initialised before we can use them! 
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        locationManager = [[CLLocationManager alloc] init];
        geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateLabels];
    [self configureGetButton];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    self.messageLabel = nil;
    self.latitudeLabel = nil;
    self.longitudeLabel = nil;
    self.addressLabel = nil;
    self.tagButton = nil;
    self.getButton = nil;
}

- (NSString *)stringFromPlaceMark:(CLPlacemark *)thePlacemark
{
    return [NSString stringWithFormat:@"%@ %@\n%@ %@ %@",
            thePlacemark.subThoroughfare, thePlacemark.thoroughfare,
            thePlacemark.locality, thePlacemark.administrativeArea, thePlacemark.postalCode];
}


- (void)updateLabels
{
    if (location != nil) {
        self.messageLabel.text = @"GPS Coordinates";
        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", location.coordinate.latitude];
        self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", location.coordinate.longitude];
        self.tagButton.hidden = NO;
        
        if (placemark != nil) {
            self.addressLabel.text = [self stringFromPlaceMark:placemark];
        } else if (performingReverseGeocoding) {
            self.addressLabel.text = @"Searching for Address...";
        } else if (lastGeocodingError != nil) {
            self.addressLabel.text = @"Error finding Address";
        } else {
            self.addressLabel.text = @"No Address Found";
        }
        
    } else {
        self.messageLabel.text = @"Press the Button to Start";
        self.latitudeLabel.text = @"";
        self.longitudeLabel.text = @"";
        self.addressLabel.text = @"";
        self.tagButton.hidden = YES;
        
        
        //All these are just to help us keep the User posted. 
        NSString *statusMessage;
        
        if (lastLocationError != nil) {
            if ([lastLocationError.domain isEqualToString:kCLErrorDomain] && lastLocationError.code ==kCLErrorDenied) {
                statusMessage = @"App Location Services Disabled";
            } else {
                statusMessage = @"Error Getting Location";
            }
        } else if (![CLLocationManager locationServicesEnabled]) { //to see if user disabled location services completely on device. 
            statusMessage = @"Device Location Services Disabled ";
        } else if (updatingLocation) {
            statusMessage = @"Searching...";
        } else {
            statusMessage = @"Press the Button to Start";
        }
        
        self.messageLabel.text = statusMessage;
    }
}
- (void)startLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [locationManager startUpdatingLocation];
        updatingLocation = YES;
    }
}

- (void)configureGetButton
{
    if (updatingLocation) {
        [self.getButton setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [self.getButton setTitle:@"Get My Location" forState:UIControlStateNormal];
    }
}

-(void)stopLocationManager
{
    if (updatingLocation) {
        [locationManager stopUpdatingLocation];
        locationManager.delegate = nil;
        updatingLocation = NO;
    }
}

- (IBAction)getLocation:(id)sender 
{
    if (updatingLocation) {
        [self stopLocationManager];
        
    } else { 
        location = nil;
        lastLocationError = nil;
        
        [self startLocationManager];
    }
    
    [self updateLabels];
    [self configureGetButton];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError %@", error);
    
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    
    [self stopLocationManager];
    lastLocationError = error;
    
    [self updateLabels];
    [self configureGetButton];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation %@", newLocation);
    
    
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
     //   NSLog(@"called timeinterval");
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
       // NSLog(@"Horizontal accuracy negative");

        return;
    }
    //This is where we determine if the new reading is more useful than the previous one. location will be nil if this is the first ever location were getting. 
    if (location == nil || location.horizontalAccuracy > newLocation.horizontalAccuracy) {
       NSLog(@"Called the checking method");
        lastLocationError = nil;
        location = newLocation;
        [self updateLabels];
        
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            NSLog(@"*** We're done!");
            [self stopLocationManager];
            [self configureGetButton];
            
            //Our Reversegeocoding magic -- GLGeocoder does not use a delegate.  but something called a block. 
            if (!performingReverseGeocoding) {
                NSLog(@"Going to geocode");
                
                performingReverseGeocoding = YES;
                [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                    NSLog(@"*** Found placemarks: %@, error: %@", placemarks, error);
                    lastGeocodingError = error;
                    if (error == nil && [placemarks count] > 0) {
                        placemark = [placemarks lastObject];
                    } else {
                        placemark = nil;
                    }
                    
                    performingReverseGeocoding = NO;
                    [self updateLabels];
                }];
            }
        }
    }
}

@end
