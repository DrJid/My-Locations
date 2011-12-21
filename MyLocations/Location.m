//
//  Location.m
//  MyLocations
//
//  Created by Maijid  Moujaled on 12/20/11.
//  Copyright (c) 2011 Grinnell College. All rights reserved.
//

#import "Location.h"


@implementation Location

@dynamic latitude;
@dynamic longitude;
@dynamic date;
@dynamic locationDescription;
@dynamic category;
@dynamic placemark;

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (NSString *)title
{
    if (self.description.length > 0) {
        return self.locationDescription;
    } else 
        return @"(No description)";
}

- (NSString *)subtitle
{
    return self.category;
}
@end
