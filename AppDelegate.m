//
//  AppDelegate.m
//  Homepwner
//
//  Created by LiBihui on 15/7/28.
//  Copyright (c) 2015年 LiBihui. All rights reserved.
//

#import "AppDelegate.h"
#import "WHXItemTableViewController.h"
#import "WHXItemStore.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    return YES;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if(!self.window.rootViewController){
     
        WHXItemTableViewController *itemViewController = [[WHXItemTableViewController alloc] init];
        //创建一个UINavigationController对象
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:itemViewController];
        //将UINavigationController对象的类名设置为恢复标识
        navController.restorationIdentifier = NSStringFromClass([navController class]);
        
        self.window.rootViewController = navController;
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

    //NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    BOOL success = [[WHXItemStore sharedStore] saveChanges];
    if(success){
        NSLog(@"save all items");
    }else{
        NSLog(@"could not save any of the items");
    }
}

-(UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    //创建一个新的UINavigationController对象
    UIViewController *vc = [[UINavigationController alloc] init];
    
    //恢复标识路径中的最后一个对象就是UINavigationController对象的恢复标识
    vc.restorationIdentifier = [identifierComponents lastObject];
    //如果恢复标识路径中只有一个对象
    //就将UINavigationController对象设置为UIWindow的恢复标识
    if([identifierComponents count] == 1){
        self.window.rootViewController = vc;
    }
    
    return vc;
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    //NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //NSLog(@"%@",NSStringFromSelector(_cmd));
}

-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder{
    
    return YES;
}

-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder{
    
    return YES;
}
@end
