//
//  WHXImageStore.h
//  Homepwner
//
//  Created by LiBihui on 15/7/29.
//  Copyright (c) 2015年 LiBihui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WHXImageStore : NSObject
+(instancetype)sharedStore;

-(void)setImage:(UIImage *)image forKey:(NSString *)key;
-(UIImage *)imageForKey:(NSString *)key;
-(void)deleteImageForKey:(NSString *)key;
-(NSString *)imagePathForKey:(NSString *)key;


@end
