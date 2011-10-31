//
//  Player.h
//  CompleteRatings
//
//  Created by App Development on 10/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *game;
@property (nonatomic,assign) int rating;

@end
