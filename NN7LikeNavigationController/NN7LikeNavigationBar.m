//
//  NN7LikeNavigationBar.m
//  NN7LikeNavigationController
//
//  Created by Naoto Horiguchi on 2013/09/18.
//  Copyright (c) 2013年 Naoto Horiguchi. All rights reserved.
//

#import "NN7LikeNavigationBar.h"

@interface NN7LikeNavigationBar ()

@property (nonatomic, strong) UIButton *backButton;

@end

@implementation NN7LikeNavigationBar

#define DEFAULT_IOS6_NAVIGATION_HEIGHT 44.f
#define DEFAULT_IOS7_NAVIGATION_HEIGHT 64.f

+ (float)_defaultHeight
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return DEFAULT_IOS6_NAVIGATION_HEIGHT;
    }else{
        return DEFAULT_IOS7_NAVIGATION_HEIGHT;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (id)init
{
    self = [self initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [NN7LikeNavigationBar _defaultHeight])];
    if (self) {
        
    }
    return self;
}

- (void)_initialize
{
    self.backgroundColor = [UIColor clearColor];
    
    _backButtonHidden = NO;
    
    _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:_backgroundView];
    [self addSubview:_contentView];
}

- (UIButton *)createBackButtonWithPreviousNavigationBarTitle:(NSString *)title
{
    _backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_backButton setTitle:title forState:UIControlStateNormal];
    _backButton.frame = (CGRect){
        10,
        0,
        88,
        44
    };
    return _backButton;
}

- (void)setLeftContentView:(UIView *)leftContentView
{
    [_leftContentView removeFromSuperview];
    
    
    _leftContentView = leftContentView;
    leftContentView.frame = (CGRect){
        .origin = {0, 0},
        .size = leftContentView.frame.size
    };
    
    [self.contentView addSubview:_leftContentView];
}

@end

