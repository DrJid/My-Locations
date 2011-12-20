//
//  CategoryPickerViewController.h
//  MyLocations
//
//  Created by Maijid  Moujaled on 12/20/11.
//  Copyright (c) 2011 Grinnell College. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryPickerViewController;

@protocol CategoryPickerViewControllerDelegate <NSObject>
-(void)categoryPicker:(CategoryPickerViewController *)picker didPickCategory:(NSString *)categoryName;
@end

@interface CategoryPickerViewController : UITableViewController
@property (nonatomic, weak) id <CategoryPickerViewControllerDelegate> delegate;
@property (nonatomic,strong) NSString *selectedCategoryName;

@end
