//
//  NN7LikeNavigationBar.m
//  NN7LikeNavigationController
//
//  Created by Naoto Horiguchi on 2013/09/18.
//  Copyright (c) 2013年 Naoto Horiguchi. All rights reserved.
//

#import "NN7LikeNavigationBar.h"

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
    self.backgroundColor = [UIColor whiteColor];
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_contentView];
}

@end


//@implementation NN7LikeNavigationBarItem

//- (void)hoge
//{
//    NSLog(@"hoge");
//}

//@end
