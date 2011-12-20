//
//  FirstViewController.h
//  MyLocations
//
//  Created by Maijid  Moujaled (aka. Dr.Jid) on 12/19/11.
//  Copyright (c) 2011 Grinnell College. All rights reserved.
//



@interface CurrentLocationViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic,strong) IBOutlet UILabel *messageLabel;
@property (nonatomic,strong) IBOutlet UILabel *latitudeLabel;
@property (nonatomic,strong) IBOutlet UILabel *longitudeLabel;
@property (nonatomic,strong) IBOutlet UILabel *addressLabel;
@property (nonatomic,strong) IBOutlet UIButton *tagButton;
@property (nonatomic,strong) IBOutlet UIButton *getButton;




@end
