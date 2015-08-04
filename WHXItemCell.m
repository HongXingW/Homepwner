//
//  WHXItemCell.m
//  Homepwner
//
//  Created by LiBihui on 15/7/31.
//  Copyright (c) 2015年 LiBihui. All rights reserved.
//

#import "WHXItemCell.h"

@interface WHXItemCell()

@end

@implementation WHXItemCell

- (IBAction)showImage:(id)sender {
    if(_actionBlock){
        _actionBlock();
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
