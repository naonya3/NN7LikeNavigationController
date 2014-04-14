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
@property (nonatomic, strong) UILabel *titleLabel;

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
    _backgroundView.backgroundColor = [UIColor colorWithRed:254.f / 255.f green:254.f / 255.f blue:254.f / 255.f alpha:1.f];
    
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _tintColor = [UIColor colorWithRed:0.f green:122.f / 255.f blue:255.f / 255.f alpha:1.f];
    
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _leftContentView.frame = (CGRect){
        .origin.x = 0.f,
        .origin.y = CGRectGetHeight(self.frame) - CGRectGetHeight(_leftContentView.frame),
        .size = _leftContentView.frame.size
    };
    
    _rightContentView.frame = (CGRect){
        .origin.x = CGRectGetWidth(self.frame) - CGRectGetWidth(_rightContentView.frame),
        .origin.y = CGRectGetHeight(self.frame) - CGRectGetHeight(_rightContentView.frame),
        .size = _rightContentView.frame.size
    };
    
    float titleMaxWidth = CGRectGetWidth(self.frame) - CGRectGetWidth(_rightContentView.frame) - CGRectGetWidth(_leftContentView.frame);
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(titleMaxWidth, CGFLOAT_MAX) lineBreakMode:_titleLabel.lineBreakMode];
    float mixX = CGRectGetWidth(self.frame) / 2.f - titleSize.width / 2.f;
    float maxX = CGRectGetWidth(self.frame) / 2.f + titleSize.width / 2.f;
    float finalTitleX;
    if (mixX >= CGRectGetMaxX(_leftContentView.frame) && maxX <= CGRectGetMinX(_rightContentView.frame)) {
        finalTitleX = CGRectGetWidth(self.frame) / 2.f - titleSize.width / 2.f;
    } else if (mixX >= CGRectGetMaxX(_leftContentView.frame) && maxX > CGRectGetMinX(_rightContentView.frame)) {
        finalTitleX = CGRectGetMinX(_rightContentView.frame) - titleSize.width;
    } else {
        finalTitleX = CGRectGetMaxX(_leftContentView.frame);
    }
    _titleLabel.frame = (CGRect){
        .origin.x = finalTitleX,
        .origin.y = CGRectGetHeight(self.frame) - CGRectGetHeight(_titleLabel.frame),
        .size.width = titleSize.width,
        .size.height = CGRectGetHeight(_titleLabel.frame)
        
    };
    
    _titleLabel.hidden = (_titleView != nil);
    _titleView.frame = (CGRect){
        .origin.x = MAX(CGRectGetMaxX(_leftContentView.frame),CGRectGetWidth(self.frame) / 2.f - _titleView.frame.size.width / 2.f),
        .origin.y = CGRectGetHeight(self.frame) - CGRectGetHeight(_titleView.frame),
        .size.width = MIN(titleMaxWidth, _titleView.frame.size.width),
        .size.height = _titleView.frame.size.height
    };
}

- (UILabel *)createTitleLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    label.font = [UIFont boldSystemFontOfSize:18.f];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 1;
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    return label;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [_titleLabel removeFromSuperview];
    _titleLabel = [self createTitleLabel];
    _titleLabel.text = title;
    [self.contentView addSubview:_titleLabel];
    [self layoutSubviews];
}

- (void)setTitleView:(UIView *)titleView
{
    [_titleView removeFromSuperview];
    _titleView = titleView;
    if (_titleView) {
        [self.contentView addSubview:_titleView];
    }
    [self layoutSubviews];
}

- (void)setLeftContentView:(UIView *)leftContentView
{
    [_leftContentView removeFromSuperview];
    _leftContentView = leftContentView;
    [self.contentView addSubview:_leftContentView];
    [self layoutSubviews];
}

- (void)setRightContentView:(UIView *)rightContentView
{
    [_rightContentView removeFromSuperview];
    _rightContentView = rightContentView;
    [self.contentView addSubview:_rightContentView];
    [self layoutSubviews];
}

@end
