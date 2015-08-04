//
//  WHXItemCell.h
//  Homepwner
//
//  Created by LiBihui on 15/7/31.
//  Copyright (c) 2015年 LiBihui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHXItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (nonatomic,copy) void (^actionBlock)(void);

@end
