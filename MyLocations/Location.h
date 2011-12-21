//
//  Location.h
//  MyLocations
//
//  Created by Maijid  Moujaled on 12/20/11.
//  Copyright (c) 2011 Grinnell College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject <MKAnnotation> //We're gonna make our location objects conform to this protocol so that MapView can show them. 


//Core Data stores everything as objects not as primitive values. 
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * locationDescription;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * photoId;

//This used to be id but we changed it to CL Placemark coz we already knew what it was. 
@property (nonatomic, retain) CLPlacemark * placemark;

- (BOOL)hasPhoto;
- (NSString *)photoPath;
- (UIImage *)photoImage;

- (void)removePhotoFile;

@end
