//
//  WHXDetailViewController.h
//  Homepwner
//
//  Created by LiBihui on 15/7/29.
//  Copyright (c) 2015年 LiBihui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHXItem.h"
@interface WHXDetailViewController : UIViewController<UIViewControllerRestoration>

@property (strong,nonatomic) WHXItem * item;
@property (nonatomic,copy) void (^dismissBlock)(void);

-(instancetype)initForNewItem:(BOOL)isNew;
@end
