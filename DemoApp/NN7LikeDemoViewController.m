//
//  NN7LikeDemoViewController.m
//  NN7LikeNavigationController
//
//  Created by Naoto Horiguchi on 2013/09/18.
//  Copyright (c) 2013年 Naoto Horiguchi. All rights reserved.
//

#import "NN7LikeDemoViewController.h"

@interface NN7LikeDemoViewController ()

@end

@implementation NN7LikeDemoViewController

- (id)initWithBar
{
    self = [super initWithNibName:@"NN7LikeDemoViewController" bundle:nil];
    if (self) {
        NN7LikeNavigationBar *bar = [[NN7LikeNavigationBar alloc] init];
        bar.title = @"Page Title";
        self.nn7NavigationBar = bar;
    }
    return self;
}

- (id)initWithoutBar
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setWantsFullScreenLayout:YES];
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    self.view.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)backButtonTouchHandler:(id)sender
{
    [self.nn7NavigationController popViewControllerAnimated:YES];
}

- (IBAction)withBarButtonTouchHandler:(id)sender
{
    [self.nn7NavigationController pushViewController:[[NN7LikeDemoViewController alloc] initWithBar] animated:YES];
}

- (IBAction)withoutBarButtonTouchHandler:(id)sender
{
    [self.nn7NavigationController pushViewController:[[NN7LikeDemoViewController alloc] initWithoutBar] animated:YES];
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
