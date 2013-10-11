//
//  NN7LikeNavigationController.h
//  NN7LikeNavigationController
//
//  Created by Naoto Horiguchi on 2013/09/12.
//  Copyright (c) 2013年 Naoto Horiguchi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NN7LikeNavigationBar.h"

@interface NN7LikeNavigationController : UIViewController

@property (nonatomic, copy) NSMutableArray *viewContainers;
@property (nonatomic, strong, readonly) UIViewController *topViewController;

- (id)initWithRootViewController:(UIViewController *)viewController;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)popViewControllerAnimated:(BOOL)animated;

@end

@interface UIViewController (NN7LikeNavigationController)

@property (nonatomic, strong) NN7LikeNavigationBar *nn7NavigationBar;
@property (nonatomic, strong, readonly) NN7LikeNavigationController *nn7NavigationController;

@end
