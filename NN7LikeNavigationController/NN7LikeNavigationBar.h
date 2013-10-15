//
//  NN7LikeNavigationBar.h
//  NN7LikeNavigationController
//
//  Created by Naoto Horiguchi on 2013/09/18.
//  Copyright (c) 2013年 Naoto Horiguchi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NN7LikeNavigationBar : UIView

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, strong) UIView *leftContentView;
@property (nonatomic, strong) UIView *rightContentView;
//@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;

// default NO
@property (nonatomic) BOOL backButtonHidden;

//- (void)pushNavigationContent:(UIView *)content animated:(BOOL)animated;
//- (UIView *)popNavigationContentAnimated:(BOOL)animated;



@end

//@interface NN7LikeNavigationBarItem : NSObject
//
//- (void)hoge;
//
//@end
