//
//  WHXImageTransformer.m
//  Homepwner
//
//  Created by Bihui Li on 15/8/3.
//  Copyright (c) 2015年 LiBihui. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "WHXImageTransformer.h"

@implementation WHXImageTransformer

+(Class)transformedValueClass{
    return [NSData class];
}

-(id)transformedValue:(id)value{
    if(!value){
        return nil;
    }
    if([value isKindOfClass:[NSData class]]){
        return value;
    }
    return UIImagePNGRepresentation(value);
}

@end
