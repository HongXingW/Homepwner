//
//  WHXImageStore.m
//  Homepwner
//
//  Created by LiBihui on 15/7/29.
//  Copyright (c) 2015年 LiBihui. All rights reserved.
//

#import "WHXImageStore.h"

@interface WHXImageStore()
@property (nonatomic,strong)NSMutableDictionary *dictionary;
@property (nonatomic) NSMutableArray *privateItems;

@end

@implementation WHXImageStore

+(instancetype)sharedStore{
    static WHXImageStore *sharedStore = nil;

    //可以在多核设备中正确返回唯一的WHXImageStore对象
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedStore = [[self alloc] initPrivate];
    });
    
    return sharedStore;
}
-(instancetype)init{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use+[WHXImageStore sharedStore]" userInfo:nil];
}
-(instancetype)initPrivate{
    self = [super init];
    if(self){
        _dictionary = [[NSMutableDictionary alloc] init];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
    }
    return self;
}

-(void)setImage:(id)image forKey:(NSString *)key{
    self.dictionary[key] = image;
    //获取图片的全路径
    NSString *imagePath = [self imagePathForKey:key];
    //从图片提取jpeg格式的数据
    //NSData *data = UIImageJPEGRepresentation(image, 0.5);
    //提取png格式的数据
    NSData *data1 = UIImagePNGRepresentation(image);
    //将数据写入文件
    [data1 writeToFile:imagePath atomically:YES];
}

-(UIImage *)imageForKey:(NSString *)key{
    
    UIImage * result = self.dictionary[key];
    
    if(!result){
        NSString * imagePath = [self imagePathForKey:key];
        result = [UIImage imageWithContentsOfFile:imagePath];
        //如果能够通过文件创建图片就存入缓存
        if(result){
            self.dictionary[key] = result;
        }else{
            NSLog(@"Error : unable to find %@",[self imagePathForKey:key]);
        }
    }
    
    return result;
}

-(NSString *)imagePathForKey:(NSString *)key{
    
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString * documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:key];
}

-(void)deleteImageForKey:(NSString *)key{
    if(!key){
        return;
    }
    [self.dictionary removeObjectForKey:key];
    //删除相应图片
    NSString *imagePath = [self imagePathForKey:key];
    
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    
}
-(void)clearCache:(NSNotification *)note{
    NSLog(@"flushing %d images out of the cache",[self.dictionary count]);
    [_dictionary removeAllObjects];
}

@end
