//
//  PlayerCell.h
//  CompleteRatings
//
//  Created by App Development on 10/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerCell : UITableViewCell
@property (nonatomic,strong) IBOutlet UILabel *nameLabel;
@property (nonatomic,strong) IBOutlet UILabel *gameLabel;
@property (nonatomic,strong) IBOutlet UIImageView *ratingImageView;

@end
