//
//  HudView.m
//  MyLocations
//
//  Created by Maijid  Moujaled on 12/20/11.
//  Copyright (c) 2011 Grinnell College. All rights reserved.
//

#import "HudView.h"

@implementation HudView

@synthesize text;

- (void)showAnimated:(BOOL)animated
{
    if (animated) {
        //Set up initial states. 
        self.alpha = 0.0f;
        self.transform = CGAffineTransformMakeScale(1.3f, 1.3f); //View is initially stretched out. 
        
        //Call UIViewbeginAnimations. and set other attributes of the transformation. How long it takes. etc. 
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        //Set up the new state. 
        self.alpha = 1.0f;
        self.transform = CGAffineTransformIdentity; //This just means the scale is back to normal. 
        
        //This commits.. makes it start and stop. 
        [UIView commitAnimations];
    }
}

//This is a convenience instructor
+ (HudView *)hudInView:(UIView *)view animated:(BOOL)animated
{
    HudView *hudView = [[HudView alloc] initWithFrame:view.bounds]; 
    hudView.opaque = NO;
    
    [view addSubview:hudView];
    view.userInteractionEnabled = NO; //Whie the HUD is showing, we don't want the user to interact with the screen anymore. 
        
    [hudView showAnimated:animated];
    
    return hudView;
}

- (void)drawRect:(CGRect)rect
{
    const CGFloat boxWidth = 96.0f;
    const CGFloat boxHeight = 96.0f;
    
    CGRect boxRect = CGRectMake(roundf(self.bounds.size.width - boxWidth) / 2.0f,
                                roundf(self.bounds.size.height - boxHeight) / 2.0f,
                                boxWidth,
                                boxHeight);
    
    //for drawing rectangles with rounded corners. 
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:10.0f];
    [[UIColor colorWithWhite:0.0f alpha:0.75] setFill];
    [roundedRect fill];
    
    //Load Checkmark image in. 
    UIImage *image = [UIImage imageNamed:@"Checkmark"];
    
    CGPoint imagePoint = CGPointMake(self.center.x - roundf(image.size.width / 2.0f),
                                     self.center.y - roundf(image.size.height / 2.0f) - boxHeight / 8.0f);
    
    [image drawAtPoint:imagePoint];
    
    //Do some text.. we decided to make our own drawing..just coz it's also simple.. 
    UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
    
    CGSize textSize = [self.text sizeWithFont:font];
    
    CGPoint textPoint = CGPointMake(
                                    self.center.x - roundf(textSize.width / 2.0f),
                                    self.center.y - roundf(textSize.height / 2.0f) + boxHeight / 4.0f);
    
    [self.text drawAtPoint:textPoint withFont:font];
}


@end
