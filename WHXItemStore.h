//
//  WHXItemStore.h
//  Homepwner
//
//  Created by LiBihui on 15/7/28.
//  Copyright (c) 2015年 LiBihui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHXItem.h"

@interface WHXItemStore : NSObject

+(instancetype)sharedStore;
-(WHXItem *)createItem;
-(NSArray *)allItems;
-(void)removeItem:(WHXItem *)item;
-(void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
-(BOOL)saveChanges;
-(NSArray *)allAssetTypes;
@end
