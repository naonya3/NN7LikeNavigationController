//
//  NN7LikeNavigationBar.m
//  NN7LikeNavigationController
//
//  Created by Naoto Horiguchi on 2013/09/18.
//  Copyright (c) 2013年 Naoto Horiguchi. All rights reserved.
//

#import "NN7LikeNavigationBar.h"

@implementation NN7LikeNavigationBar

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
    self = [super initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 54.f)];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (void)_initialize
{
    self.backgroundColor = [UIColor lightGrayColor];
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
