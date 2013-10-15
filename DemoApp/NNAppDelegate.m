//
//  NNAppDelegate.m
//  NN7LikeNavigationController
//
//  Created by Naoto Horiguchi on 2013/09/17.
//  Copyright (c) 2013年 Naoto Horiguchi. All rights reserved.
//

#import "NNAppDelegate.h"

#import "NN7LikeNavigationController.h" // Insert *-Prefix.pch this line useful!!!
#import "NN7LikeDemoViewController.h"

@implementation NNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [[NN7LikeNavigationController alloc] initWithRootViewController:[NN7LikeDemoViewController new]];
    
    return YES;
}


@end
