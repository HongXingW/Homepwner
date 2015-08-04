//
//  WHXItemTableViewController.m
//  Homepwner
//
//  Created by LiBihui on 15/7/28.
//  Copyright (c) 2015年 LiBihui. All rights reserved.
//

#import "WHXItemTableViewController.h"
#import "WHXItem.h"
#import "WHXItemStore.h"
#import "WHXDetailViewController.h"
#import "WHXItemCell.h"
#import "WHXImageViewController.h"
#import "WHXImageStore.h"


@interface WHXItemTableViewController ()<UITableViewDataSource,UIPopoverControllerDelegate>
@property (nonatomic,strong) UIPopoverController *imagePopover;
@end

@implementation WHXItemTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    //创建UINib对象
    UINib *nib = [UINib nibWithNibName:@"WHXItemCell" bundle:nil];
    //通过该对象注册相应的nib文件
    [self.tableView registerNib:nib forCellReuseIdentifier:@"WHXItemCell"];
    
    self.tableView.restorationIdentifier = @"WHXItemTableViewControllerTableView";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[[WHXItemStore sharedStore] allItems] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    //获取WHXItemCell对象，返回的可能是现有对象，也可能是新创建的对象
    WHXItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WHXItemCell" forIndexPath:indexPath];
    
    NSArray *items = [[WHXItemStore sharedStore] allItems];
    
    WHXItem *item = items[indexPath.row];
    
    cell.nameLabel.text = item.itemName;
    cell.serialNumberLabel.text = item.serialNumber;
    cell.valueLabel.text = [NSString stringWithFormat:@"$%d",item.valueInDollars];
    
    //NSLog(@"test---%@",item.thumbnail);
        
    cell.thumbnailView.image = item.thumbnail;
    
    //__weak *weakCell = cell;
    cell.actionBlock = ^{
        //NSLog(@"going to show image for %@",item);
        //WHXItemCell *strongCell = weakCell;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            
            NSString *itemKey = item.itemKey;
            UIImage *img = [[WHXImageStore sharedStore] imageForKey:itemKey];
            //如果WHXItem对象没有图片，就直接返回
            if(!img){
                return ;
            }
            //根据UITableView对象的坐标系获取UIImageView对象的位置和大小
            CGRect rect = [self.view convertRect:cell.thumbnailView.bounds fromView:cell.thumbnailView];
            
            //创建WHXImageViewController对象并为image赋值
            WHXImageViewController *ivc = [[WHXImageViewController alloc] init];
            ivc.image = img;
            //根据UIImageView对象的位置和大小
            //显示一个大小为600*600点的UIPopoverController对象
            
            _imagePopover = [[UIPopoverController alloc] initWithContentViewController:ivc];
            
            _imagePopover.delegate = self;
            _imagePopover.popoverContentSize = CGSizeMake(600, 600);
            [_imagePopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
            
        }
    };
    return cell;
}
//关闭popoverController时
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    _imagePopover = nil;
}

- (IBAction)addNewItem:(id)sender {
    WHXItem * newItem = [[WHXItemStore sharedStore] createItem];
    
    WHXDetailViewController * detailViewController = [[WHXDetailViewController alloc] initForNewItem:YES];
    
    detailViewController.item = newItem;
    
    detailViewController.dismissBlock = ^{
        [self.tableView reloadData];
    };
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    //设置恢复标识
    navController.restorationIdentifier = NSStringFromClass([navController class]);
    
    //ipad以表单样式显示viewController
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    //淡入淡出效果
    //navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        
        NSArray * items =[[WHXItemStore sharedStore] allItems];
        WHXItem * item = items[indexPath.row];
        [[WHXItemStore sharedStore] removeItem:item];
        //删除表格视图中相应表格行
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    [[WHXItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WHXDetailViewController * detailViewController  = [[WHXDetailViewController alloc] initForNewItem:NO];
    
    NSArray *items = [[WHXItemStore sharedStore] allItems];
    WHXItem *item = items[indexPath.row];
    
    detailViewController.item = item;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

+(UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    return [[self alloc] init];
}
//保存WHXItemTableViewController的编辑状态
-(void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [coder encodeBool:self.isEditing forKey:@"TableViewIsEditing"];
    [super encodeRestorableStateWithCoder:coder];
}

-(void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    
    self.editing = [coder decodeBoolForKey:@"TableViewIsEditing"];
    [super decodeRestorableStateWithCoder:coder];
}

-(NSString *)modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view{
    
    NSString *identifier = nil;
    
    if(idx && view){
        //为NSIndexPath参数所对应的WHXItem对象设置唯一标识符
        WHXItem *item = [[WHXItemStore sharedStore] allItems][idx.row];
        identifier = item.itemKey;
    }
    return identifier;
}

-(NSIndexPath *)indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view{
    
    NSIndexPath *indexPath = nil;
    
    if(identifier && view){
        
        NSArray *items = [[WHXItemStore sharedStore] allItems];
        for(WHXItem *item in items){
            
            if([identifier isEqualToString:item.itemKey]){
                
                int row = [items indexOfObjectIdenticalTo:item];
                indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                break;
            }
        }
    }
    return indexPath;
}
-(instancetype)init{
    self = [super initWithStyle:UITableViewStylePlain];
    
    if(self){
        
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Homepwner";
        
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        //self.navigationItem.title = @"Homepwner";
        //创建UIBarButtonItem对象，将其目标设置为当前对象，动作方法设置为addNewItem
        UIBarButtonItem *bbItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        
        navItem.rightBarButtonItem = bbItem;
        navItem.leftBarButtonItem = self.editButtonItem;
        
    }
    return self;
}
-(instancetype)initWithStyle:(UITableViewStyle)style{
    return [self init];
}

@end
