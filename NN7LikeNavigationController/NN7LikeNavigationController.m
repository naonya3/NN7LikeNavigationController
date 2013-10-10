//
//  NN7LikeNavigationController.h
//  NN7LikeNavigationController
//
//  Created by Naoto Horiguchi on 2013/09/12.
//  Copyright (c) 2013年 Naoto Horiguchi. All rights reserved.
//

#import "NN7LikeNavigationController.h"

#import <objc/runtime.h>

#define PanAreaSize 30.
#define MaxShadowAlpha .30


// TODO: blocksのなかで_visibleControllerにアクセスしてしまっているものをどうにかしてなおす
@interface PanHandlerView : UIView

@end

@implementation PanHandlerView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (point.x <= PanAreaSize) {
        return self;
    }
    return nil;
}

@end

@interface UIViewController (NN7LikeNavigationControllerSet)
- (void)setNN7NavigationController:(NN7LikeNavigationController *)nn7NavigationController;
//- (void)setNN7NavigationnBar:(NN7LikeNavigationBarItem *)nn7NavigationBarItem;
@end

@interface NN7LikeNavigationController () <UIGestureRecognizerDelegate>
{

}

- (void)_panGestureHandler:(UIPanGestureRecognizer *)recognizer;

@end

@implementation NN7LikeNavigationController
{
    UIPanGestureRecognizer *_panGestureRecognizer;
    
    //Panを優先的に受け取るため、最前面に表示されます
    PanHandlerView *_pangestureAreaView;
    
    //子ViewControllerを表示するコンテナ
    UIView *_containerView;
    
    UIViewController *_nextVisibleViewController;
    UIView *_coverShadowView;
    UIView *_gradationShadowView;
}

- (id)initWithRootViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        _viewControllers = @[].mutableCopy;
        _topViewController = viewController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Gesture
    {
        _pangestureAreaView = [[PanHandlerView alloc] initWithFrame:self.view.bounds];
        _pangestureAreaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _pangestureAreaView.backgroundColor = [UIColor clearColor];
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panGestureHandler:)];
        [_pangestureAreaView addGestureRecognizer:_panGestureRecognizer];
        _panGestureRecognizer.delegate = self;
    }
    
    // Container
    {
        // navigation bar
        _navigationBar = [[NN7LikeNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50.)];
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0,_navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - _navigationBar.frame.size.height)];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    // Shadow
    {
        _coverShadowView = [[UIView alloc] initWithFrame:self.view.bounds];
        _coverShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _coverShadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        
        _gradationShadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10., self.view.bounds.size.height)];
        _gradationShadowView.autoresizingMask =  UIViewAutoresizingFlexibleHeight;
        _gradationShadowView.backgroundColor = [UIColor colorWithPatternImage:[self _gradiation]];
    }
    
    // Layer
    [self.view addSubview:_containerView];
    [self.view addSubview:_pangestureAreaView];
    [self.view addSubview:_navigationBar];
    [self pushViewController:_topViewController animated:NO];
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

- (void)pushViewController:(UIViewController *)toViewController animated:(BOOL)animated
{
    [_viewControllers addObject:toViewController];
    
    // Setup next ViewController
    {
        [toViewController setNN7NavigationController:self];
        
        // TODO: setup navigationBar
    }
    
    // Prepare next viewController
    {
        toViewController.view.frame = _containerView.bounds;
        toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        if ([self _isOver5]) {
            [self addChildViewController:toViewController];
        } else {
            [toViewController viewWillAppear:animated];
        }
    }
    
    // Prepare Shadow
    {
        _coverShadowView.alpha = 0.;
        _gradationShadowView.alpha = 0.;
        _gradationShadowView.frame = CGRectMake(_containerView.frame.size.width - _gradationShadowView.frame.size.width,
                                                0,
                                                _gradationShadowView.frame.size.width,
                                                _gradationShadowView.frame.size.height);
        
        //TODO: shadow height は barの高さを考えて決める
    }
    
    // Setup View Layer
    {
        [_containerView addSubview:toViewController.view];
        [_containerView insertSubview:_coverShadowView belowSubview:toViewController.view];
        [_containerView insertSubview:_gradationShadowView aboveSubview:_coverShadowView];
    }
    
    // Remove Function
    void (^removed)() = ^{
        if ([self _isOver5]) {
            [_visibleViewController removeFromParentViewController];
        } else {
            [toViewController viewDidAppear:animated];
            [_visibleViewController viewWillDisappear:animated];
        }
        
        [_visibleViewController.view removeFromSuperview];
        
        if (![self _isOver5]) {
            [_visibleViewController viewDidDisappear:animated];
        }
        _visibleViewController = toViewController;
    };
    
    if (animated) {
        
        // set positions of start animating.
        CGRect visibledViewTargetRect = [[_visibleViewController view] frame];
        visibledViewTargetRect.origin.x = -(_containerView.frame.size.width / 2.);
        
        CGRect pushedViewTargetRect = toViewController.view.frame;
        pushedViewTargetRect.origin.x = _containerView.frame.size.width;
        
        toViewController.view.frame = pushedViewTargetRect;
        pushedViewTargetRect.origin.x = 0;
        
        // shadow
        CGRect gradationShadowTargetRect = _gradationShadowView.frame;
        gradationShadowTargetRect.origin.x = -_gradationShadowView.frame.size.width;
        
        [UIView animateWithDuration:0.24 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
            // View
            _visibleViewController.view.frame = visibledViewTargetRect;
            toViewController.view.frame = pushedViewTargetRect;
            
            // Shadow
            _coverShadowView.alpha = MaxShadowAlpha;
            _gradationShadowView.alpha = 1.;
            _gradationShadowView.frame = gradationShadowTargetRect;
            
        } completion:^(BOOL finished) {
            removed();
        }];
    } else {
        // remove
        removed();
    }
}

- (void)popViewControllerAnimated:(BOOL)animated
{
    [self _preparePopUp:animated];
    if (animated) {
        [self _startPopTransition:^{
            [self _finishPopup:animated];
        }];
    } else {
        _nextVisibleViewController.view.frame = _containerView.bounds;
        [_containerView addSubview:_nextVisibleViewController.view];
        [self _finishPopup:animated];
    }
}

- (BOOL)_isOver5
{
    return [[UIDevice currentDevice].systemVersion floatValue] >= 5.;
}

- (void)_startPopTransition:(void(^)())completionBlock
{
    CGRect rect = _visibleViewController.view.frame;
    rect.origin.x = self.view.frame.size.width;
    rect.origin.y = 0;
    
    CGRect next = _nextVisibleViewController.view.frame;
    next.origin.x = 0;
    next.origin.y = 0;
    
    CGRect shadowRect = _gradationShadowView.frame;
    shadowRect.origin.x = _containerView.frame.size.width - _gradationShadowView.frame.size.width;
    
    [UIView animateWithDuration:0.24 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
        _visibleViewController.view.frame = rect;
        _nextVisibleViewController.view.frame = next;
        
        // shadow
        _coverShadowView.alpha = 0.;
        _gradationShadowView.alpha = 0.;
        _gradationShadowView.frame = shadowRect;
        
    } completion:^(BOOL finished) {
        if (completionBlock)
            completionBlock();
    }];
}

- (void)_cancelPopTransition:(void(^)())completionBlock
{
    CGRect rect = _visibleViewController.view.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGRect next = _nextVisibleViewController.view.frame;
    next.origin.x = - self.view.frame.size.width / 2.;
    next.origin.y = 0;
    
    CGRect shadowRect = _gradationShadowView.frame;
    shadowRect.origin.x = -_gradationShadowView.frame.size.width;
    
    [UIView animateWithDuration:0.24 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
        _visibleViewController.view.frame = rect;
        _nextVisibleViewController.view.frame = next;
        
        // shadow
        _coverShadowView.alpha = MaxShadowAlpha;
        _gradationShadowView.alpha = 1.;
        _gradationShadowView.frame = shadowRect;
        
    } completion:^(BOOL finished) {
        
        [_nextVisibleViewController.view removeFromSuperview];
        if ([self _isOver5]) {
            [_nextVisibleViewController removeFromParentViewController];
        } else {
            [_nextVisibleViewController viewWillDisappear:YES];
            [_nextVisibleViewController.view removeFromSuperview];
            [_nextVisibleViewController viewDidDisappear:YES];
        }
        
        if (completionBlock)
            completionBlock();
    }];
}

#pragma mark - Gesture

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //上でhitTestしてるからいらないかも
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if (point.x <= PanAreaSize) {
        return YES;
    }
    return NO;
}

- (void)_preparePopUp:(BOOL)animated
{
    _nextVisibleViewController = _viewControllers[_viewControllers.count-2];
    
    if ([self _isOver5]) {
        [self addChildViewController:_nextVisibleViewController];
    } else {
        [_nextVisibleViewController viewWillAppear:animated];
    }
    
    _nextVisibleViewController.view.frame = CGRectMake(- (self.view.frame.size.width / 2.), 0, self.view.frame.size.width, self.view.frame.size.height);
    [_containerView insertSubview:_nextVisibleViewController.view belowSubview:_visibleViewController.view];
    
    // shadow
    CGRect rect = _gradationShadowView.frame;
    rect.origin.x = -_gradationShadowView.frame.size.width;
    _gradationShadowView.frame = rect;
    [_containerView insertSubview:_coverShadowView aboveSubview:_nextVisibleViewController.view];
    [_containerView insertSubview:_gradationShadowView aboveSubview:_coverShadowView];
    
    if (![self _isOver5]) {
        [_nextVisibleViewController viewDidDisappear:animated];
    }
}

- (void)_finishPopup:(BOOL)animated
{
    if ([self _isOver5]) {
        [_visibleViewController.view removeFromSuperview];
        [_visibleViewController removeFromParentViewController];
    } else {
        [_visibleViewController viewWillDisappear:animated];
        [_visibleViewController.view removeFromSuperview];
        [_visibleViewController viewDidDisappear:animated];
    }
    
    [_viewControllers removeLastObject];
    _visibleViewController = _nextVisibleViewController;
}

- (void)_panGestureHandler:(UIPanGestureRecognizer *)recognizer
{
    if (_viewControllers.count <= 1) {
        return;
    }
    
    float moveX = [recognizer translationInView:self.view].x;
    CGRect targetRect = CGRectOffset(_visibleViewController.view.frame, moveX, 0);
    
    // shadow
    CGRect shadowRect = _gradationShadowView.frame;
    shadowRect.origin.x = targetRect.origin.x - shadowRect.size.width;
    _gradationShadowView.frame = shadowRect;
    
    _coverShadowView.alpha = MaxShadowAlpha * (1. - _visibleViewController.view.frame.origin.x / self.view.frame.size.width);
    _gradationShadowView.alpha = 1. - _visibleViewController.view.frame.origin.x / self.view.frame.size.width;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // setup next view controller
        [self _preparePopUp:YES];
        _visibleViewController.view.frame = targetRect;
        CGRect nextTargetRect = CGRectOffset(_nextVisibleViewController.view.frame, moveX / 2., 0);
        _nextVisibleViewController.view.frame = nextTargetRect;
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        _visibleViewController.view.frame = targetRect;
        CGRect nextTargetRect = CGRectOffset(_nextVisibleViewController.view.frame, moveX / 2., 0);
        _nextVisibleViewController.view.frame = nextTargetRect;
        
    } else {
        CGPoint point = [recognizer locationInView:self.view];
        if ((point.x > self.view.frame.size.width / 2 && [recognizer velocityInView:self.view].x > - 10) || [recognizer velocityInView:self.view].x > 300) {
            [self _startPopTransition:^{
                [self _finishPopup:YES];
            }];
        } else {
            [self _cancelPopTransition:nil];
        }
    }
    
    [recognizer setTranslation:CGPointZero inView:self.view];
}


// TODO: 4.3でキモイ（4.3でグラデーションがかからない）
- (UIImage *)_gradiation
{
    UIGraphicsBeginImageContext(CGSizeMake(10, 10));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextAddRect(context, CGRectMake(0, 0, 10, 10));
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {
        0.0f, 0.0f, 0.0f, 0.3f,
        0.0f, 0.0f, 0.0f, 0.0f,
    };
    
    size_t count = sizeof(components)/ (sizeof(CGFloat)* 4);
    
    CGPoint startPoint = CGPointMake(10, 0);
    CGPoint endPoint = CGPointMake(0, 0);
    
    CGFloat locations[] = { 0.0f, 1.0f};
    CGGradientRef gradientRef =
    CGGradientCreateWithColorComponents(colorSpaceRef, components, locations, count);
    
    CGContextDrawLinearGradient(context,
                                gradientRef,
                                startPoint,
                                endPoint,
                                kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRestoreGState(context);
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation UIViewController (NN7LikeNavigationControllerSet)

- (void)setNN7NavigationController:(NN7LikeNavigationController *)nn7NavigationController
{
    objc_setAssociatedObject(self, _cmd, nn7NavigationController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIViewController (NN7LikeNavigationController)

- (NN7LikeNavigationController *)nn7NavigationController
{
    return objc_getAssociatedObject(self, @selector(setNN7NavigationController:));
}

- (void)setNn7NavigationBar:(NN7LikeNavigationBar *)nn7NavigationBar
{
    objc_setAssociatedObject(self, _cmd, nn7NavigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NN7LikeNavigationBar *)nn7NavigationBar
{
    return objc_getAssociatedObject(self, @selector(setNn7NavigationBar:));
}


@end
