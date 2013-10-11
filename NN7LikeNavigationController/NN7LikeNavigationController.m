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

@interface PanHandlerView : UIView

@end

@interface NNViewControllerContainer : UIView

@property (nonatomic, strong, readonly) UIViewController *viewController;
@property (nonatomic, strong) UIViewController *parentViewController;

- (id)initWithViewController:(UIViewController *)viewController parentViewController:(UIViewController *)parentViewController;
- (void)setViewController:(UIViewController *)viewController parentViewController:(UIViewController *)parentViewController;
- (void)removeFromSuperviewAndParentViewController;


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
            .size = viewController.view.frame.size
        };
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:viewController.view];
    }
}

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
    
    UIView *_visibleContainer;
    NNViewControllerContainer *_nVisibleContainer;
    
    UIView *_processToViewContainer;
    UIView *_processFromViewContainer;
    
    UIView *_coverShadowView;
    UIView *_gradationShadowView;
}

- (id)initWithRootViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        // delete
        _viewControllers = @[].mutableCopy;
        
        _nViewControllers = @[].mutableCopy;
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
        //_navigationBar = [[NN7LikeNavigationBar alloc] init];
        
        _containerView = [[UIView alloc] initWithFrame:self.view.bounds];
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
    NNViewControllerContainer *toViewContainer = [[NNViewControllerContainer alloc] initWithFrame:_containerView.bounds];
    [toViewContainer setViewController:toViewController parentViewController:self];
    
    [_nViewControllers addObject:toViewContainer];
    
    // Setup next ViewController
    {
        [toViewController setNN7NavigationController:self];
    }
    
    // Prepare Shadow
    {
        _coverShadowView.alpha = 0.;
        _gradationShadowView.alpha = 0.;
        _gradationShadowView.frame = CGRectMake(toViewContainer.frame.size.width - _gradationShadowView.frame.size.width,
                                                0,
                                                _gradationShadowView.frame.size.width,
                                                _gradationShadowView.frame.size.height);
        
        //TODO: shadow height は barの高さを考えて決める
    }
    
    // Setup View Layer
    {
        [_containerView addSubview:toViewContainer];
        [_containerView insertSubview:_coverShadowView belowSubview:toViewContainer];
        [_containerView insertSubview:_gradationShadowView aboveSubview:_coverShadowView];
    }
    
    // Remove Function
    void (^removed)() = ^{
        [_nVisibleContainer removeFromSuperview];
        _nVisibleContainer = toViewContainer;
    };
    
    if (animated) {
        // set positions of start animating.
        CGRect visibledViewTargetRect = [_nVisibleContainer frame];
        visibledViewTargetRect.origin.x = -(_containerView.frame.size.width / 2.);
        
        CGRect pushedViewTargetRect = toViewContainer.frame;
        pushedViewTargetRect.origin.x = _containerView.frame.size.width;
        
        toViewContainer.frame = pushedViewTargetRect;
        pushedViewTargetRect.origin.x = 0;
        
        // shadow
        CGRect gradationShadowTargetRect = _gradationShadowView.frame;
        gradationShadowTargetRect.origin.x = -_gradationShadowView.frame.size.width;
        
        [UIView animateWithDuration:0.24 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
            // View
            _nVisibleContainer.frame = visibledViewTargetRect;
            toViewContainer.frame = pushedViewTargetRect;
            
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

- (UIView *)_createContainerFromViewController:(UIViewController *)viewController
{
    [self addChildViewController:viewController];
    
    UIView *container = [[UIView alloc] initWithFrame:self.view.bounds];
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
            .size.height = CGRectGetHeight(self.view.frame) - CGRectGetHeight(navigationbar.frame)
        };
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [container addSubview:navigationbar];
        [container addSubview:viewController.view];
    } else {
        viewController.view.frame = (CGRect){
            .origin.x = 0,
            .origin.y = 0,
            .size = viewController.view.frame.size
        };
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [container addSubview:viewController.view];
    }
    
    return container;
}

- (void)popViewControllerAnimated:(BOOL)animated
{
    NNViewControllerContainer *toViewContainer = _nViewControllers[_nViewControllers.count - 2];
    NNViewControllerContainer *fromViewContainer = _nVisibleContainer;
    
    [self _nPreparePopUpFromViewController:fromViewContainer toViewController:toViewContainer];
    
    if (animated) {
        [self _nStartPopTransition:^{
            [self _nFinishPopupFromViewController:fromViewContainer toViewController:toViewContainer];
        }];
    } else {
        toViewContainer.frame = _containerView.bounds;
        [_containerView addSubview:toViewContainer];
        [self _nFinishPopupFromViewController:fromViewContainer toViewController:toViewContainer];
    }
}

- (void)_startPopTransition:(void(^)())completionBlock
{
    UIViewController *toViewController = _viewControllers[_viewControllers.count - 2];
    UIViewController *fromViewController = _visibleViewController;
    
    UIView *fromViewContainer = _visibleContainer;
    UIView *toViewContainer = _processToViewContainer;
    
    CGRect rect = fromViewContainer.frame;
    rect.origin.x = self.view.frame.size.width;
    rect.origin.y = 0;
    
    CGRect next = toViewController.view.frame;
    next.origin.x = 0;
    next.origin.y = 0;
    
    CGRect shadowRect = _gradationShadowView.frame;
    shadowRect.origin.x = _containerView.frame.size.width - _gradationShadowView.frame.size.width;
    
    [UIView animateWithDuration:0.24 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromViewContainer.frame = rect;
        toViewContainer.frame = next;
        
        // shadow
        _coverShadowView.alpha = 0.;
        _gradationShadowView.alpha = 0.;
        _gradationShadowView.frame = shadowRect;
        
    } completion:^(BOOL finished) {
        if (completionBlock)
            completionBlock();
    }];
}

- (void)_nStartPopTransition:(void(^)())completionBlock
{
    NNViewControllerContainer *toViewContainer = _nViewControllers[_nViewControllers.count - 2];
    NNViewControllerContainer *fromViewContainer = _nVisibleContainer;
    
    CGRect rect = fromViewContainer.frame;
    rect.origin.x = self.view.frame.size.width;
    rect.origin.y = 0;
    
    CGRect next = toViewContainer.frame;
    next.origin.x = 0;
    next.origin.y = 0;
    
    CGRect shadowRect = _gradationShadowView.frame;
    shadowRect.origin.x = _containerView.frame.size.width - _gradationShadowView.frame.size.width;
    
    [UIView animateWithDuration:0.24 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromViewContainer.frame = rect;
        toViewContainer.frame = next;
        
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
    UIViewController *toViewController = _viewControllers[_viewControllers.count - 2];
    UIViewController *fromViewController = _visibleViewController;
    
    UIView *fromViewContainer = _visibleContainer;
    UIView *toViewContainer = _processToViewContainer;
    
    CGRect rect = fromViewController.view.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGRect next = toViewController.view.frame;
    next.origin.x = - self.view.frame.size.width / 2.;
    next.origin.y = 0;
    
    CGRect shadowRect = _gradationShadowView.frame;
    shadowRect.origin.x = -_gradationShadowView.frame.size.width;
    
    [UIView animateWithDuration:0.24 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromViewContainer.frame = rect;
        toViewContainer.frame = next;
        
        // shadow
        _coverShadowView.alpha = MaxShadowAlpha;
        _gradationShadowView.alpha = 1.;
        _gradationShadowView.frame = shadowRect;
        
    } completion:^(BOOL finished) {
        
        [toViewContainer removeFromSuperview];
        [toViewController removeFromParentViewController];
        
        if (completionBlock)
            completionBlock();
    }];
}


- (void)_nCancelPopTransition:(void(^)())completionBlock
{
    NNViewControllerContainer *toViewContainer = _nViewControllers[_nViewControllers.count - 2];
    NNViewControllerContainer *fromViewContainer = _nVisibleContainer;
    
    
    CGRect rect = fromViewContainer.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGRect next = toViewContainer.frame;
    next.origin.x = - self.view.frame.size.width / 2.;
    next.origin.y = 0;
    
    CGRect shadowRect = _gradationShadowView.frame;
    shadowRect.origin.x = -_gradationShadowView.frame.size.width;
    
    [UIView animateWithDuration:0.24 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromViewContainer.frame = rect;
        toViewContainer.frame = next;
        
        // shadow
        _coverShadowView.alpha = MaxShadowAlpha;
        _gradationShadowView.alpha = 1.;
        _gradationShadowView.frame = shadowRect;
        
    } completion:^(BOOL finished) {
        [toViewContainer removeFromSuperviewAndParentViewController];
        
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

- (void)_preparePopUpFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    [self addChildViewController:toViewController];
    
    _processToViewContainer = [self _createContainerFromViewController:toViewController];
    
    _processToViewContainer.frame = CGRectMake(- (self.view.frame.size.width / 2.), 0, self.view.frame.size.width, self.view.frame.size.height);
    [_containerView insertSubview:_processToViewContainer belowSubview:_visibleContainer];
    
    // shadow
    CGRect rect = _gradationShadowView.frame;
    rect.origin.x = -_gradationShadowView.frame.size.width;
    _gradationShadowView.frame = rect;
    [_containerView insertSubview:_coverShadowView aboveSubview:_processToViewContainer];
    [_containerView insertSubview:_gradationShadowView aboveSubview:_coverShadowView];
}

- (void)_nPreparePopUpFromViewController:(NNViewControllerContainer *)fromViewContainer toViewController:(NNViewControllerContainer *)toViewContainer
{
    toViewContainer.parentViewController = self;
    toViewContainer.frame = CGRectMake(- (self.view.frame.size.width / 2.), 0, self.view.frame.size.width, self.view.frame.size.height);
    [_containerView insertSubview:toViewContainer belowSubview:fromViewContainer];
    
    // shadow
    _coverShadowView.alpha = MaxShadowAlpha;
    _gradationShadowView.alpha = 1.;
    _gradationShadowView.frame = (CGRect){
        .origin.x = -CGRectGetWidth(_gradationShadowView.frame),
        .origin.y = 0.,
        .size = _gradationShadowView.frame.size
    };
    
    [_containerView insertSubview:_coverShadowView aboveSubview:toViewContainer];
    [_containerView insertSubview:_gradationShadowView aboveSubview:_coverShadowView];
}

- (void)_finishPopupFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    [fromViewController.view removeFromSuperview];
    [fromViewController removeFromParentViewController];
    [_viewControllers removeLastObject];
    _visibleViewController = toViewController;
    _visibleContainer = _processToViewContainer;
}

- (void)_nFinishPopupFromViewController:(NNViewControllerContainer *)fromViewContainer toViewController:(NNViewControllerContainer *)toViewContainer
{
    [fromViewContainer removeFromSuperviewAndParentViewController];
    [_nViewControllers removeLastObject];
    _nVisibleContainer = toViewContainer;
}

- (void)_panGestureHandler:(UIPanGestureRecognizer *)recognizer
{
    if (_nViewControllers.count <= 1) {
        return;
    }
    
    NNViewControllerContainer *toViewContainer = _nViewControllers[_nViewControllers.count - 2];
    NNViewControllerContainer *fromViewContainer = _nVisibleContainer;
    
    float moveX = [recognizer translationInView:self.view].x;
    CGRect targetRect = CGRectOffset(fromViewContainer.frame, moveX, 0);
    
    // shadow
    CGRect shadowRect = _gradationShadowView.frame;
    shadowRect.origin.x = targetRect.origin.x - shadowRect.size.width;
    _gradationShadowView.frame = shadowRect;
    
    _coverShadowView.alpha = MaxShadowAlpha * (1. - fromViewContainer.frame.origin.x / self.view.frame.size.width);
    _gradationShadowView.alpha = 1. - fromViewContainer.frame.origin.x / self.view.frame.size.width;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // setup next view controller
        [self _nPreparePopUpFromViewController:fromViewContainer toViewController:toViewContainer];
        
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
            [self _nStartPopTransition:^{
                [self _nFinishPopupFromViewController:fromViewContainer toViewController:toViewContainer];
            }];
        } else {
            [self _nCancelPopTransition:nil];
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
