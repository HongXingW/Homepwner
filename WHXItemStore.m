//
//  WHXItemStore.m
//  Homepwner
//
//  Created by LiBihui on 15/7/28.
//  Copyright (c) 2015年 LiBihui. All rights reserved.
//

#import "WHXItemStore.h"
#import "WHXImageStore.h"

@interface WHXItemStore()

@property (nonatomic) NSMutableArray *privateItems;
@property (nonatomic,strong) NSMutableArray *allAssetTypes;
@property (nonatomic,strong) NSManagedObjectContext *context;
@property (nonatomic,strong) NSManagedObjectModel *model;

@end

@implementation WHXItemStore
+(instancetype)sharedStore{
    static WHXItemStore *sharedStore = nil;
    
    if(!sharedStore){
        sharedStore = [[self alloc] initPrivate];
    }
    return sharedStore;
}
-(instancetype)init{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use+[WhxItemStore shareStore]" userInfo:nil];
    return nil;
}
-(instancetype)initPrivate{
    self = [super init];
    if(self){
        //_privateItems = [[NSMutableArray alloc] init];
        
        //NSString *path = [self itemArchivePath];
        //_privateItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        //如果之前没有保存过privateItems，就创建一个新的
        /*if(!_privateItems){
            _privateItems = [[NSMutableArray alloc] init];
        }*/
        
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        //该对象负责文件的存取
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        
        //设置SQLite文件路径
        NSString *path = [self itemArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;
        
        if(![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]){
            
            @throw [NSException exceptionWithName:@"openfailure" reason:[error localizedDescription] userInfo:nil];
        }
        
        //创建NSManagedObjectContext对象
        _context = [[NSManagedObjectContext alloc] init];
        _context.persistentStoreCoordinator = psc;
        
        [self loadAllItems];
    }
    return self;
}
#pragma mark - methods to operate items
-(NSArray *)allItems{
    NSMutableArray * items = self.privateItems;
    //[items addObject:@"no more!"];
    return items;
}
-(WHXItem *)createItem{
    //WHXItem * item = [[WHXItem alloc] init];
    
    double order;
    if([self.allItems count] == 0){
        order = 1.0;
    }else{
        //最后一个对象的顺序加1
        order = [[self.privateItems lastObject] orderingValue] + 1.0;
    }
    NSLog(@"Adding after %d items, order = %.2f",[self.privateItems count],order);
    
    WHXItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"WHXItem" inManagedObjectContext:self.context];
    
    item.orderingValue = order;
    
    [self.privateItems addObject:item];
    return item;
}
-(void)removeItem:(WHXItem *)item{
    NSString *key = item.itemKey;
    [[WHXImageStore sharedStore] deleteImageForKey:key];
    
    [self.context deleteObject:item];
    
    [self.privateItems removeObjectIdenticalTo:item];
}
-(void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex{
    
    if(fromIndex == toIndex){
        return;
    }else{
        WHXItem *item = _privateItems[fromIndex];
        [_privateItems removeObjectAtIndex:fromIndex];
        [_privateItems insertObject:item atIndex:toIndex];
        
        //为移动的对象计算新的ordervalue
        double lowerBound = 0;
        //在数组中，该对象之前是否有其他对象
        if(toIndex>0){
            lowerBound = [self.privateItems[(toIndex-1)] orderingValue];
        }else{
            lowerBound = [self.privateItems[1] orderingValue]-2;
        }
        
        double upperBound = 0;
        //数组中该对象之后是否有其他对象
        if(toIndex<[self.privateItems count] -1){
            
            upperBound = [self.privateItems[(toIndex +1)] orderingValue];
        }else{
            upperBound = [self.privateItems[(toIndex -1)] orderingValue] + 2;
        }
        
        double newOrderValue = (lowerBound + upperBound)/2.0;
        
        NSLog(@"moving to order %f",newOrderValue);
        
        item.orderingValue = newOrderValue;
    }
}
#pragma mark - file
//获取文件路径
-(NSString *)itemArchivePath{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //从ducumentDirectories数组获取第一个路径，即文档目录路径
    NSString *documentDirectory =  [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
    
}
-(BOOL)saveChanges{
    //NSString *path = [self itemArchivePath];
    //固化成功返回yes
    //return [NSKeyedArchiver archiveRootObject:_privateItems toFile:path];
    
    NSError *error;
    BOOL successful = [self.context save:&error];
    if(!successful){
        NSLog(@"Error saving: %@",[error localizedDescription]);
    }
    return successful;
}
-(void)loadAllItems{
    
    if(!self.privateItems){
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        //设置实体描述
        NSEntityDescription * ett = [NSEntityDescription entityForName:@"WHXItem" inManagedObjectContext:self.context];
        
        request.entity = ett;
        //排序描述
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES];
        
        request.sortDescriptors = @[sd];
        
        NSError *error;
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        
        if(!result){
            [NSException raise:@"Fetch failed" format:@"Reason: %@",[error localizedDescription]];
        }
        
        self.privateItems = [[NSMutableArray alloc] initWithArray:result];
    }
}

-(NSArray *)allAssetTypes{
    
    if(!_allAssetTypes){
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *edc = [NSEntityDescription entityForName:@"WHXAssetType" inManagedObjectContext:self.context];
        
        request.entity = edc;
        
        NSError *error = nil;
        
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        
        if(!result){
            [NSException raise:@"Fetch failed" format:@"Reason: %@",[error localizedDescription]];
        }
        _allAssetTypes = [result mutableCopy];
    }
    
    if([_allAssetTypes count] == 0){
        
        NSManagedObject *type;
        type = [NSEntityDescription insertNewObjectForEntityForName:@"WHXAssetType" inManagedObjectContext:self.context];
        [type setValue:@"Furniture" forKey:@"label"];
        [_allAssetTypes addObject:type];
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"WHXAssetType" inManagedObjectContext:self.context];
        [type setValue:@"Electronics" forKey:@"label"];
        [_allAssetTypes addObject:type];
    }
    return _allAssetTypes;
    
}

@end
