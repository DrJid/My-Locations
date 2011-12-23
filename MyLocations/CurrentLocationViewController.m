//
//  FirstViewController.m
//  MyLocations
//
//  Created by Maijid  Moujaled on 12/19/11.
//  Copyright (c) 2011 Grinnell College. All rights reserved.
//

#import "CurrentLocationViewController.h"
#import "LocationDetailsViewController.h"
#import "NSMutableString+AddText.h"
#import <QuartzCore/QuartzCore.h>

//This is a class extension These methods need to be visible throughout the entire object. 
@interface CurrentLocationViewController()
-(void)updateLabels; //Forward declaration.
- (void)startLocationManager;
- (void)stopLocationManager;
- (void)configureGetButton;
- (void)loadSoundEffect;
- (void)unloadSoundEffect;
- (void)playSoundEffect;
- (void)showLogoView;
- (void)hideLogoViewAnimated:(BOOL)animated;
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
    
    UIActivityIndicatorView *spinner;

    UIImageView *logoImageView;
    BOOL firstTime;

}

@synthesize messageLabel, latitudeLabel, longitudeLabel, addressLabel, tagButton, getButton;
@synthesize managedObjectContext, latitudeTextLabel, longitudeTextLabel, panelView;



//This is our initwithCoder method. I'm guessing this method is what helps us initialise and use the object. Remember that all objects have to be initialised before we can use them! 
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        locationManager = [[CLLocationManager alloc] init];
        geocoder = [[CLGeocoder alloc] init];
        firstTime = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateLabels];
    [self configureGetButton];
    
    if (firstTime) {
        [self showLogoView];
    } else {
        [self hideLogoViewAnimated:NO];
    }

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
    self.longitudeTextLabel = nil;
    self.latitudeTextLabel = nil;
    self.panelView = nil;
    logoImageView = nil;


}



- (NSString *)stringFromPlaceMark:(CLPlacemark *)thePlacemark
{
    
    NSMutableString *line1 = [NSMutableString stringWithCapacity:100];
    [line1 addText:thePlacemark.subThoroughfare  withSeparator:@""];
    [line1 addText:thePlacemark.thoroughfare withSeparator:@" "];
    
    NSMutableString *line2 = [NSMutableString stringWithCapacity:100];
    [line2 addText:thePlacemark.locality withSeparator:@""];
    [line2 addText:thePlacemark.administrativeArea withSeparator:@" "];
    [line2 addText:thePlacemark.postalCode withSeparator:@" "];
    
    
    if (line1.length == 0) {
        [line2 appendString:@"\n"];
        return line2;
    } else {
    [line1 appendString:@"\n"];
    [line2 appendString:line1];
    
    return line1;
    }
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
        
        self.latitudeTextLabel.hidden = NO;
        self.longitudeTextLabel.hidden = NO;
        
    } else {
        self.messageLabel.text = @"Press the Button to Start";
        self.latitudeLabel.text = @"";
        self.longitudeLabel.text = @"";
        self.addressLabel.text = @"";
        self.tagButton.hidden = YES;
        self.latitudeTextLabel.hidden = YES;
        self.longitudeTextLabel.hidden = YES;
        
        
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
        
        //iOS will send didTimeOut to self after 60s. Rmb. Selector is the name of the method. 
        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}

- (void)configureGetButton
{
    if (updatingLocation) {
        [self.getButton setTitle:@"Stop" forState:UIControlStateNormal];
        
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        spinner.center = CGPointMake(self.getButton.bounds.size.width - spinner.bounds.size.width/2.0f - 10, self.getButton.bounds.size.height / 2.0f);
        [spinner startAnimating];
        [self.getButton addSubview:spinner];
        
    } else {
        [self.getButton setTitle:@"Get My Location" forState:UIControlStateNormal];
        
        [spinner removeFromSuperview];
        spinner = nil;
    }
}

-(void)stopLocationManager
{
    if (updatingLocation) {
        
        //Just as we schedule a call to didTimeout from startLocationManager, we need to cancel it when stopLocationManager is called. 
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
        
        [locationManager stopUpdatingLocation];
        locationManager.delegate = nil;
        updatingLocation = NO;
    }
}

- (void)didTimeOut:(id)obj
{
    NSLog(@"***Time out");
    
    if (location == nil) {
        [self   stopLocationManager];
        
        lastLocationError = [NSError errorWithDomain:@"MyLocationsErrorDomain" code:1 userInfo:nil];
        
        [self updateLabels];
        [self configureGetButton];
    }
}


//This allows us to send data from one screen to another. We set them up here in the prepareForSegue Method. Already created properties for these in the LcoationDeatails... of course.. and here is where we fill it up. 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TagLocation"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        controller.coordinate = location.coordinate;
        controller.placemark = placemark;
    }
}

- (IBAction)getLocation:(id)sender 
{
    
    if (firstTime) {
        firstTime = NO;
        [self hideLogoViewAnimated:YES];
    }
    
    if (updatingLocation) {
        [self stopLocationManager];
        
    } else { 
        //We do these so that whenever the button is pressed, we start with a clean slate.
        location = nil;
        lastLocationError = nil;
        placemark = nil;
        lastGeocodingError = nil; 
        
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
    
    
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
     //   NSLog(@"called timeinterval");
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
       // NSLog(@"Horizontal accuracy negative");

        return;
    }
    
    //This calculates the distance between the new reading and the previous reading. 
    CLLocationDistance distance= MAXFLOAT;
    if (location != nil) {
        distance = [newLocation distanceFromLocation:location];
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
            
            if (distance > 0) {
                performingReverseGeocoding = NO;
            }
            
            //Our Reversegeocoding magic -- GLGeocoder does not use a delegate.  but something called a block. 
            if (!performingReverseGeocoding) {
                NSLog(@"Going to geocode");
                
                performingReverseGeocoding = YES;
                [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                    NSLog(@"*** Found placemarks: %@, error: %@", placemarks, error);
                    
                    lastGeocodingError = error;
                    if (error == nil && [placemarks count] > 0) {
                        if (placemark == nil) {
                            NSLog(@"FIRST TIME!");

                        }
                        placemark = [placemarks lastObject];
                    } else {
                        placemark = nil;
                    }
                    
                    performingReverseGeocoding = NO;
                    [self updateLabels];
                }];
            }
            
        } else if (distance < 1.0) {
            NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:location.timestamp];
            if (timeInterval > 10) {
                NSLog(@"*** Force Done!");
                [self stopLocationManager];
                [self updateLabels];
                [self configureGetButton];
            }
        }
    }
}

#pragma mark - Logo View

- (void)showLogoView
{
    self.panelView.hidden = YES;
    
    logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]];
    logoImageView.center = CGPointMake(160.0f, 140.0f);
    [self.view addSubview:logoImageView];
}

- (void)hideLogoViewAnimated:(BOOL)animated
{
    self.panelView.hidden = NO;
    
    if (animated) {
        
        self.panelView.center = CGPointMake(600.0f, 140.0f);
        
        CABasicAnimation *panelMover = [CABasicAnimation animationWithKeyPath:@"position"];
        panelMover.removedOnCompletion = NO;
        panelMover.fillMode = kCAFillModeForwards;
        panelMover.duration = 0.6f;
        panelMover.fromValue = [NSValue valueWithCGPoint:self.panelView.center];
        panelMover.toValue = [NSValue valueWithCGPoint:CGPointMake(160.0f, self.panelView.center.y)];
        panelMover.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        panelMover.delegate = self;
        [self.panelView.layer addAnimation:panelMover forKey:@"panelMover"];
        
        CABasicAnimation *logoMover = [CABasicAnimation animationWithKeyPath:@"position"];
        logoMover.removedOnCompletion = NO;
        logoMover.fillMode = kCAFillModeForwards;
        logoMover.duration = 0.5f;
        logoMover.fromValue = [NSValue valueWithCGPoint:logoImageView.center];
        logoMover.toValue = [NSValue valueWithCGPoint:CGPointMake(-160.0f, logoImageView.center.y)];
        logoMover.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [logoImageView.layer addAnimation:logoMover forKey:@"logoMover"];
        
        CABasicAnimation *logoRotator = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        logoRotator.removedOnCompletion = NO;
        logoRotator.fillMode = kCAFillModeForwards;
        logoRotator.duration = 0.5f;
        logoRotator.fromValue = [NSNumber numberWithFloat:0];
        logoRotator.toValue = [NSNumber numberWithFloat:-2*M_PI];
        logoRotator.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [logoImageView.layer addAnimation:logoRotator forKey:@"logoRotator"];
        
    } else {
        [logoImageView removeFromSuperview];
        logoImageView = nil;
    }
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.panelView.layer removeAllAnimations];
    self.panelView.center = CGPointMake(160.0f, 140.0f);
    
    [logoImageView.layer removeAllAnimations];
    [logoImageView removeFromSuperview];
    logoImageView = nil;
}
@end
