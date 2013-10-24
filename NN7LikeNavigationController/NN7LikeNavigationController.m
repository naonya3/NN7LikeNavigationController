//
//  NN7LikeNavigationController.h
//  NN7LikeNavigationController
//
//  Created by Naoto Horiguchi on 2013/09/12.
//  Copyright (c) 2013年 Naoto Horiguchi. All rights reserved.
//

#import "NN7LikeNavigationController.h"

#import <objc/runtime.h>

#define PanAreaSize 20.
#define MaxShadowAlpha .30

@interface PanHandlerView : UIView

@end

@interface NNViewControllerContainer : UIView
{
    BOOL _isAnimating;
}

@property (nonatomic, strong, readonly) UIViewController *viewController;
@property (nonatomic, strong) UIViewController *parentViewController;

- (id)initWithViewController:(UIViewController *)viewController parentViewController:(UIViewController *)parentViewController;
- (void)setViewController:(UIViewController *)viewController parentViewController:(UIViewController *)parentViewController;
- (void)removeFromSuperviewAndParentViewController;
- (CGRect)contentFrame;

@end

@implementation NNViewControllerContainer

- (id)initWithViewController:(UIViewController *)viewController parentViewController:(UIViewController *)parentViewController
{
    self = [super init];
    if (self) {
        [self setViewController:viewController parentViewController:parentViewController];
    }
    return self;
}

- (void)removeFromSuperviewAndParentViewController
{
    [super removeFromSuperview];
    [self.viewController removeFromParentViewController];
}

- (void)setParentViewController:(UIViewController *)parentViewController
{
    _parentViewController = parentViewController;
    [parentViewController addChildViewController:_viewController];
}

- (void)setViewController:(UIViewController *)viewController parentViewController:(UIViewController *)parentViewController
{
    _viewController = viewController;
    self.parentViewController = parentViewController;
    
    NN7LikeNavigationBar *navigationbar = viewController.nn7NavigationBar;
    if (navigationbar) {
        navigationbar.frame = (CGRect){
            .origin.x = 0,
            .origin.y = 0,
            .size = navigationbar.frame.size
        };
        navigationbar.autoresizingMask = UIViewAutoresizingNone | UIViewAutoresizingFlexibleWidth;
        
        viewController.view.frame = (CGRect){
            .origin.x = 0,
            .origin.y = navigationbar.frame.size.height,
            .size.width = CGRectGetWidth(viewController.view.frame),
            .size.height = CGRectGetHeight(self.frame) - CGRectGetHeight(navigationbar.frame)
        };
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:navigationbar];
        [self addSubview:viewController.view];
    } else {
        viewController.view.frame = (CGRect){
            .origin.x = 0,
            .origin.y = 0,
            .size = self.bounds.size
        };
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:viewController.view];
    }
}

- (CGRect)contentFrame
{
    return _viewController.view.frame;
}

@end

@implementation PanHandlerView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (point.x <= PanAreaSize && CGRectContainsPoint(self.frame, point)) {
        return self;
    }
    return nil;
}

@end

@interface UIViewController (NN7LikeNavigationControllerSet)
- (void)setNN7NavigationController:(NN7LikeNavigationController *)nn7NavigationController;
@end

@interface NN7LikeNavigationController () <UIGestureRecognizerDelegate>
{
    BOOL _isAnimation;
}

- (void)_panGestureHandler:(UIPanGestureRecognizer *)recognizer;

@end

@implementation NN7LikeNavigationController
{
    UIPanGestureRecognizer *_panGestureRecognizer;
    
    //Panを優先的に受け取るため、最前面に表示されます
    PanHandlerView *_pangestureAreaView;
    
    //子ViewControllerを表示するコンテナ
    UIView *_contentView;
    NSMutableArray *_viewContainers;

    NNViewControllerContainer *_visibleContainer;

    UIView *_coverShadowView;
    UIView *_gradationShadowView;
}

- (id)initWithRootViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        _viewContainers = @[].mutableCopy;
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
        _pangestureAreaView.clipsToBounds = YES;
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panGestureHandler:)];
        [_pangestureAreaView addGestureRecognizer:_panGestureRecognizer];
        _panGestureRecognizer.delegate = self;
    }
    
    // Container
    {
        // navigation bar
        //_navigationBar = [[NN7LikeNavigationBar alloc] init];
        
        _contentView = [[UIView alloc] initWithFrame:self.view.bounds];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
    [self.view addSubview:_contentView];
    [self.view addSubview:_pangestureAreaView];;
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
    if (_isAnimation)
        return;
    
    NNViewControllerContainer *toViewContainer = [[NNViewControllerContainer alloc] initWithFrame:_contentView.bounds];
    [toViewContainer setViewController:toViewController parentViewController:self];
    toViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [_viewContainers addObject:toViewContainer];
    
    // TODO: ここ移動させたい
    if (!toViewContainer.viewController.nn7NavigationBar.backButtonHidden) {
        UIButton *backButton = [toViewContainer.viewController.nn7NavigationBar createBackButtonWithPreviousNavigationBarTitle:@"タイトルが入ります"];
        [backButton addTarget:self action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(backButton.frame), CGRectGetMaxY(backButton.frame))];
        [view addSubview:backButton];
        toViewContainer.viewController.nn7NavigationBar.leftContentView = view;
    }
    
    // Setup next ViewController
    {
        [toViewController setNN7NavigationController:self];
    }
    
    // Prepare Shadow
    {
        _coverShadowView.alpha = 0.;
        _coverShadowView.frame = [_visibleContainer contentFrame];
        
        _gradationShadowView.alpha = 0.;
        _gradationShadowView.frame = CGRectMake(toViewContainer.frame.size.width - _gradationShadowView.frame.size.width,
                                                CGRectGetMinY([_visibleContainer contentFrame]),
                                                CGRectGetWidth(_gradationShadowView.frame),
                                                CGRectGetHeight(_gradationShadowView.frame));
    }
    
    // Prepare Panarea
    {
        _pangestureAreaView.frame = [toViewContainer contentFrame];
    }

    // Setup View Layer
    {
        [_contentView addSubview:toViewContainer];
        [_contentView insertSubview:_coverShadowView belowSubview:toViewContainer];
        [_contentView insertSubview:_gradationShadowView aboveSubview:_coverShadowView];
    }
    
    // Remove Function
    void (^removed)() = ^{
        [_visibleContainer removeFromSuperview];
        _visibleContainer = toViewContainer;
    };
    
    if (animated) {
        _isAnimation = YES;
        // set positions of start animating.
        CGRect visibledViewTargetRect = [_visibleContainer frame];
        visibledViewTargetRect.origin.x = -(_contentView.frame.size.width / 2.);
        
        CGRect pushedViewTargetRect = toViewContainer.frame;
        pushedViewTargetRect.origin.x = _contentView.frame.size.width;
        
        toViewContainer.frame = pushedViewTargetRect;
        pushedViewTargetRect.origin.x = 0;
        
        // shadow
        CGRect gradationShadowTargetRect = _gradationShadowView.frame;
        gradationShadowTargetRect.origin.x = -_gradationShadowView.frame.size.width;
        
        
        toViewContainer.viewController.nn7NavigationBar.contentView.alpha = 0.;
        [UIView animateWithDuration:0.24 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
            // View
            _visibleContainer.frame = visibledViewTargetRect;
            _visibleContainer.viewController.nn7NavigationBar.contentView.alpha = 0;
            toViewContainer.frame = pushedViewTargetRect;
            
            // Shadow
            _coverShadowView.alpha = MaxShadowAlpha;
            _gradationShadowView.alpha = 1.;
            _gradationShadowView.frame = gradationShadowTargetRect;
            
            // NavigationBar
            toViewContainer.viewController.nn7NavigationBar.contentView.alpha = 1.;
            
        } completion:^(BOOL finished) {
            _isAnimation = NO;
            removed();
        }];
    } else {
        // remove
        removed();
    }
}

- (void)popViewControllerAnimated:(BOOL)animated
{
    if (_viewContainers.count <= 1 || _isAnimation) {
        return;
    }
    
    NNViewControllerContainer *toViewContainer = _viewContainers[_viewContainers.count - 2];
    NNViewControllerContainer *fromViewContainer = _visibleContainer;
    
    [self _preparePopUpFromViewController:fromViewContainer toViewController:toViewContainer];
    
    if (animated) {
        _isAnimation = YES;
        [self _startPopTransition:^{
            [self _finishPopupFromViewController:fromViewContainer toViewController:toViewContainer];
            _isAnimation = NO;
        }];
    } else {
        toViewContainer.frame = _contentView.bounds;
        [_contentView addSubview:toViewContainer];
        [self _finishPopupFromViewController:fromViewContainer toViewController:toViewContainer];
    }
}


- (void)_startPopTransition:(void(^)())completionBlock
{
    NNViewControllerContainer *toViewContainer = _viewContainers[_viewContainers.count - 2];
    NNViewControllerContainer *fromViewContainer = _visibleContainer;
    
    CGRect rect = fromViewContainer.frame;
    rect.origin.x = self.view.frame.size.width;
    rect.origin.y = 0;
    
    CGRect next = toViewContainer.frame;
    next.origin.x = 0;
    next.origin.y = 0;
    
    CGRect shadowRect = _gradationShadowView.frame;
    shadowRect.origin.x = _contentView.frame.size.width - _gradationShadowView.frame.size.width;
    
    [UIView animateWithDuration:0.24 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromViewContainer.frame = rect;
        toViewContainer.frame = next;
        
        // shadow
        _coverShadowView.alpha = 0.;
        _gradationShadowView.alpha = 0.;
        _gradationShadowView.frame = shadowRect;
        
        toViewContainer.viewController.nn7NavigationBar.contentView.alpha = 1.0;
        fromViewContainer.viewController.nn7NavigationBar.contentView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        if (completionBlock)
            completionBlock();
    }];
}

- (void)_cancelPopTransition:(void(^)())completionBlock
{
    NNViewControllerContainer *toViewContainer = _viewContainers[_viewContainers.count - 2];
    NNViewControllerContainer *fromViewContainer = _visibleContainer;
    
    CGRect rect = fromViewContainer.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGRect next = toViewContainer.frame;
    next.origin.x = - self.view.frame.size.width / 2.;
    next.origin.y = 0;
    
    CGRect shadowRect = _gradationShadowView.frame;
    shadowRect.origin.x = -_gradationShadowView.frame.size.width;
    
    _pangestureAreaView.frame = [fromViewContainer contentFrame];
    
    
    [UIView animateWithDuration:0.24 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromViewContainer.frame = rect;
        toViewContainer.frame = next;
        
        // shadow
        _coverShadowView.alpha = MaxShadowAlpha;
        _gradationShadowView.alpha = 1.;
        _gradationShadowView.frame = shadowRect;
        
        toViewContainer.viewController.nn7NavigationBar.contentView.alpha = 0.0;
        fromViewContainer.viewController.nn7NavigationBar.contentView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        toViewContainer.userInteractionEnabled = YES;
        fromViewContainer.userInteractionEnabled = YES;
        
        [toViewContainer removeFromSuperviewAndParentViewController];
        if (completionBlock)
            completionBlock();
    }];
}

- (UIViewController *)visibleViewContorller
{
    return _visibleContainer.viewController;
}

#pragma mark - Gesture

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //上でhitTestしてるからいらないかも
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if (point.x <= PanAreaSize && !_isAnimation) {
        return YES;
    }
    return NO;
}

- (void)_preparePopUpFromViewController:(NNViewControllerContainer *)fromViewContainer toViewController:(NNViewControllerContainer *)toViewContainer
{
    toViewContainer.userInteractionEnabled = NO;
    fromViewContainer.userInteractionEnabled = NO;
    
    toViewContainer.parentViewController = self;
    toViewContainer.frame = CGRectMake(- (self.view.frame.size.width / 2.), 0, self.view.frame.size.width, self.view.frame.size.height);
    [_contentView insertSubview:toViewContainer belowSubview:fromViewContainer];
    
    // shadow
    _coverShadowView.alpha = MaxShadowAlpha;
    _coverShadowView.frame = [toViewContainer contentFrame];
    
    _gradationShadowView.alpha = 1.;
    _gradationShadowView.frame = (CGRect){
        .origin.x = -CGRectGetWidth(_gradationShadowView.frame),
        .origin.y = CGRectGetMinY([toViewContainer contentFrame]),
        .size = _gradationShadowView.frame.size
    };
    
    _pangestureAreaView.frame = [toViewContainer contentFrame];
    
    toViewContainer.viewController.nn7NavigationBar.contentView.alpha = 0.;
    
    [_contentView insertSubview:_coverShadowView aboveSubview:toViewContainer];
    [_contentView insertSubview:_gradationShadowView aboveSubview:_coverShadowView];
}

- (void)_finishPopupFromViewController:(NNViewControllerContainer *)fromViewContainer toViewController:(NNViewControllerContainer *)toViewContainer
{
    toViewContainer.userInteractionEnabled = YES;
    fromViewContainer.userInteractionEnabled = YES;
    
    [fromViewContainer removeFromSuperviewAndParentViewController];
    [_viewContainers removeLastObject];
    _visibleContainer = toViewContainer;
}

- (void)_panGestureHandler:(UIPanGestureRecognizer *)recognizer
{
    if (_viewContainers.count <= 1) {
        return;
    }
    
    NNViewControllerContainer *toViewContainer = _viewContainers[_viewContainers.count - 2];
    NNViewControllerContainer *fromViewContainer = _visibleContainer;
    
    float moveX = [recognizer translationInView:self.view].x;
    CGRect targetRect = CGRectOffset(fromViewContainer.frame, moveX, 0);
    
    // shadow
    CGRect shadowRect = _gradationShadowView.frame;
    shadowRect.origin.x = targetRect.origin.x - shadowRect.size.width;
    _gradationShadowView.frame = shadowRect;
    
    _coverShadowView.alpha = MaxShadowAlpha * (1. - fromViewContainer.frame.origin.x / self.view.frame.size.width);
    _gradationShadowView.alpha = 1. - fromViewContainer.frame.origin.x / self.view.frame.size.width;
    
    toViewContainer.viewController.nn7NavigationBar.contentView.alpha = fromViewContainer.frame.origin.x / self.view.frame.size.width;
    fromViewContainer.viewController.nn7NavigationBar.contentView.alpha = 1. - fromViewContainer.frame.origin.x / self.view.frame.size.width;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // setup next view controller
        [self _preparePopUpFromViewController:fromViewContainer toViewController:toViewContainer];
        
        fromViewContainer.frame = targetRect;
        CGRect nextTargetRect = CGRectOffset(toViewContainer.frame, moveX / 2., 0);
        toViewContainer.frame = nextTargetRect;
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        fromViewContainer.frame = targetRect;
        CGRect nextTargetRect = CGRectOffset(toViewContainer.frame, moveX / 2., 0);
        toViewContainer.frame = nextTargetRect;
        
    } else {
        CGPoint point = [recognizer locationInView:self.view];
        if ((point.x > self.view.frame.size.width / 2 && [recognizer velocityInView:self.view].x > - 10) || [recognizer velocityInView:self.view].x > 300) {
            _isAnimation = YES;
            [self _startPopTransition:^{
                [self _finishPopupFromViewController:fromViewContainer toViewController:toViewContainer];
                _isAnimation = NO;
            }];
        } else {
            _isAnimation = YES;
            [self _cancelPopTransition:^{
                _isAnimation = NO;
            }];
        }
    }
    
    [recognizer setTranslation:CGPointZero inView:self.view];
}

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
