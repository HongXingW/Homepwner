//
//  WHXImageViewController.m
//  Homepwner
//
//  Created by LiBihui on 15/8/1.
//  Copyright (c) 2015年 LiBihui. All rights reserved.
//

#import "WHXImageViewController.h"


@interface WHXImageViewController ()

@end

@implementation WHXImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.view = imageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //必须将view转换为UIImageView对象，以便向其发送setImage消息
    UIImageView *imageView = (UIImageView *)self.view;
    imageView.image = _image;
}

@end
