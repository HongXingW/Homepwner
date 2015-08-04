//
//  WHXDetailViewController.m
//  Homepwner
//
//  Created by LiBihui on 15/7/29.
//  Copyright (c) 2015年 LiBihui. All rights reserved.
//

#import "WHXDetailViewController.h"
#import "WHXImageStore.h"
#import "WHXItemStore.h"
#import "WHXItemTableViewController.h"
#import "WHXAssetTypeViewController.h"

@interface WHXDetailViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UIImageView * imageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;

@property (strong,nonatomic)UIPopoverController *imagePickerPopover;

@property (weak,nonatomic) IBOutlet UILabel *nameLabel;
@property (weak,nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak,nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *assetTypeButton;

@end

@implementation WHXDetailViewController

-(instancetype)initForNewItem:(BOOL)isNew{
    self = [super initWithNibName:nil bundle:nil];
    
    if(self){
        
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        if(isNew){
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
            
            self.navigationItem.rightBarButtonItem = doneItem;
            
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
            
            self.navigationItem.leftBarButtonItem = cancelItem;
        }
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(updateFonts) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    return self;
}
//禁止使用此初始化方法
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    @throw [NSException exceptionWithName:@"Wrong initializer" reason:@"use initForNewItem" userInfo:nil];
    return nil;
}

-(void)dealloc{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
}
-(void)save:(id)sender{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
    
}
-(void)cancel:(id)sender{
    [[WHXItemStore sharedStore] removeItem:_item];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImageView *imageView = [[UIImageView alloc] init];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    //告诉自动布局不要将自动缩放掩码转换为约束
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:imageView];
    _imageView = imageView;
    
    NSDictionary *nameMap = @{ @"imageView":self.imageView,@"dateLabel":self.dateLabel,@"toolBar":self.toolBar};
    //手动设置imageView的约束
    //下面那个奇怪的字符串时视觉化格式字符串
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|" options:0 metrics:nil views:nameMap];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dateLabel]-8-[imageView]-8-[toolBar]" options:0 metrics:nil views:nameMap];
    
    [self.view addConstraints:horizontalConstraints];
    [self.view addConstraints:verticalConstraints];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    [self prepareViewsForOrientation:io];
    
    WHXItem * item = _item;
    
    _nameField.text = item.itemName;
    _serialField.text = item.serialNumber;
    _valueField.text = [NSString stringWithFormat:@"%d",item.valueInDollars];
    
    //创建NSDateFormatter对象，用于将NSDate对象转换成简单的日期字符串
    static NSDateFormatter *dateFormatter = nil;
    if(!dateFormatter){
        
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateIntervalFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateIntervalFormatterNoStyle;
        
    }
    _dateLabel.text = [dateFormatter stringFromDate:item.dateCreated];
    
    NSString *key = _item.itemKey;
    if(key){
        UIImage *image = [[WHXImageStore sharedStore] imageForKey:key];
        _imageView.image =image;
    }else{
        _imageView.image = nil;
    }
    
    NSString *typeLabel = [_item.assetType valueForKey:@"label"];
    if(!typeLabel){
        typeLabel = @"None";
    }
    
    self.assetTypeButton.title = [NSString stringWithFormat:@"Type: %@",typeLabel];
    
    [self setDelegate];
    [self updateFonts];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    //取消当前第一响应对象
    [self.view endEditing:YES];
    
    WHXItem * item = self.item;
    item.itemName = _nameField.text;
    item.serialNumber = _serialField.text;
    item.valueInDollars = [_valueField.text intValue];
    
    
}
//替换编译器为item属性生成的存方法，设置title
-(void)setItem:(WHXItem *)item{
    _item = item;
    self.navigationItem.title = _item.itemName;
}

- (IBAction)takePicture:(id)sender {
    
    //如果imagePickerPopover指向的是有效的popverController对象且该对象可视，则释放之
    
    if([_imagePickerPopover isPopoverVisible]){
        [_imagePickerPopover dismissPopoverAnimated:YES];
        _imagePickerPopover = nil;
        return;
    }
    
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    
    //如果支持相机则拍照，否则从相册中选择
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePicker.delegate = self;
    //以模态形式显示UIImagePickerController对象
    //[self presentViewController:imagePicker animated:YES completion:nil];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        
        self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        
        _imagePickerPopover.delegate = self;
        
        [_imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }else{
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}
//通过UIImagePickerController拍照或从相册选择图片

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //通过info字典获取选择的照片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    _imageView.image = image;
    [_item setThumbnailFromImage:image];
    
    [[WHXImageStore sharedStore] setImage:image forKey:self.item.itemKey];
    
    //关闭UIImagePickerController对象
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    if(_imagePickerPopover){
        [_imagePickerPopover dismissPopoverAnimated:YES];
        _imagePickerPopover = nil;
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
//出现约束异常时会调用
-(void)viewDidLayoutSubviews{
    
    for(UIView *subview in self.view.subviews){
        if([subview hasAmbiguousLayout]){
            NSLog(@"AMBIGUOUS: %@",subview);
        }
    }
}
//如果iPhone横屏则隐藏imageView并将相机按钮设置为不可用
-(void)prepareViewsForOrientation:(UIInterfaceOrientation)orientation{
    
    //如果是iPad，不执行操作
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        
        return;
    }
    if(UIInterfaceOrientationIsLandscape(orientation)){
        self.imageView.hidden = YES;
        self.cameraButton.enabled = NO;
    }else{
        self.imageView.hidden = NO;
        self.cameraButton.enabled = YES;
    }
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    [self prepareViewsForOrientation:toInterfaceOrientation];
    
}
//点击别处取消popoverController界面时调用
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    NSLog(@"user dismissed popover");
    _imagePickerPopover = nil;
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
}
-(void)setDelegate{
    _nameField.delegate = self;
    _serialField.delegate = self;
    _valueField.delegate = self;

}
-(void)updateFonts{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    _nameLabel.font = font;
    _serialNumberLabel.font = font;
    _valueLabel.font = font;
    _dateLabel.font = font;
    
    _nameField.font = font;
    _serialField.font = font;
    _valueField.font = font;
    
}
- (IBAction)showAssetTypePicker:(id)sender {
    [self.view endEditing:YES];
    
    WHXAssetTypeViewController *avc = [[WHXAssetTypeViewController alloc] init];
    avc.item = _item;
    
    [self.navigationController pushViewController:avc animated:YES];
}
+(UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    BOOL isNew = NO;
    if([identifierComponents count] == 3){
        isNew = YES;
    }
    return [[self alloc] initForNewItem:isNew];
}

-(void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    //编码当前itemKey属性
    [coder encodeObject:_item.itemKey forKey:@"item.itemKey"];
    
    //保存UITextfield对象中的文本
    _item.itemName = _nameField.text;
    _item.serialNumber = _serialField.text;
    _item.valueInDollars = [_valueField.text intValue];
    //保存修改
    [[WHXItemStore sharedStore] saveChanges];
    
    [super encodeRestorableStateWithCoder:coder];
}
-(void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    
    NSString *itemKey = [coder decodeObjectForKey:@"item.itemKey"];
    for(WHXItem *item in [[WHXItemStore sharedStore] allItems]){
        
        if([itemKey isEqualToString:@"item.itemKey"]){
            
            self.item = item;
            break;
        }
    }
    [super decodeRestorableStateWithCoder:coder];
}
@end
