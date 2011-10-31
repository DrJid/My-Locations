//
//  PlayersViewController.h
//  CompleteRatings
//
//  Created by App Development on 10/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerDetailsViewController.h"

@interface PlayersViewController : UITableViewController <PlayerDetailsViewControllerDelegate>

@property (nonatomic,strong) NSMutableArray *players;

@end
