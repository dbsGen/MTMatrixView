//
//  MTNavigationController.m
//  DateManager
//
//  Created by apple on 12-1-20.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTNavigationController.h"
#import "UIImage+MTResize.h"
#import "MTLogger.h"
#import <QuartzCore/QuartzCore.h>
#import "MTSource.h"

void setBackGroundImage(UIImage *image)
{
    
}

@interface MTNavigationController()

- (void)addSubViewController:(UIViewController*)viewCtrl 
                    animated:(BOOL)animated;

@end

@implementation MTNavigationController

@synthesize navigationBar = _navigationBar, contentView = _contentView, pushAnimation = _pushAnimation;
@synthesize popAnimation = _popAnimation, titleLabel = _titleLabel, visibleViewController;
@synthesize topViewController, viewControllers, viewControllerKey = _viewControllerKey;
@synthesize navigationBarHidden = _navigationBarHidden;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [self initwithBarHeight:44 shadowHeight:5];
    if (self) {
    }
    return self;
}

- (id)initwithBarHeight:(CGFloat)barHeight 
           shadowHeight:(CGFloat)shadowHeight
{
    self = [super initWithNibName:nil
                           bundle:nil];
    if (self) {
        _barHeight = barHeight;
        _shadowHeight = shadowHeight;
        
        UIScreen *screen = [UIScreen mainScreen];
        CGRect frame = screen.bounds;
        _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, _barHeight + _shadowHeight)];
        _navigationBar.backgroundColor = [UIColor clearColor];
        _navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
        UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:_navigationBar];
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y + _barHeight, frame.size.width, frame.size.height - _barHeight)];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:_contentView atIndex:0];
        
        UIDevice *device = [UIDevice currentDevice];
        CGFloat version = [[device systemVersion] floatValue];
        if (version >= 5.0) {
            UIImage *image;
            if (self.interfaceOrientation == UIInterfaceOrientationPortrait || 
                self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
            {
                image = [_backgroundImage transformToSize:CGSizeMake(frame.size.width, _barHeight + _shadowHeight)];
            }else {
                image = [_backgroundImage transformToSize:CGSizeMake(frame.size.height, _barHeight + _shadowHeight)];
            }
            [self.navigationBar setBackgroundImage:image
                                     forBarMetrics:UIBarMetricsDefault];
        }
        
        CATransition *animation = [[CATransition alloc] init];
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromRight;
        _pushAnimation = animation;
        
        animation = [[CATransition alloc] init];
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromLeft;
        _popAnimation = animation;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 
                                                                frame.size.width - 100, 44)];
        _titleLabel.userInteractionEnabled = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.shadowColor = [UIColor blackColor];
        _titleLabel.shadowOffset = CGSizeMake(1, 1);
        _titleLabel.font = [UIFont boldSystemFontOfSize:19];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
        UIViewAutoresizingFlexibleHeight;
        [_navigationBar addSubview:_titleLabel];
        
        _viewControllersDictionary = [[NSMutableDictionary alloc] init];
        _showingViewControllers = [NSMutableArray array];
        [_viewControllersDictionary setObject:_showingViewControllers
                                       forKey:kDefaultViewControllers];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    UIViewController *viewCtrl = [self visibleViewController];
    return [viewCtrl shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    UIDevice *device = [UIDevice currentDevice];
    CGFloat version = [[device systemVersion] floatValue];
    if (version >= 5.0) {
        CGRect rect = [UIScreen mainScreen].bounds;
        UIImage *image;
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait || 
            toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
        {
            image = [_backgroundImage transformToSize:CGSizeMake(rect.size.width, _barHeight + _shadowHeight)];
        }else {
            image = [_backgroundImage transformToSize:CGSizeMake(rect.size.height, _barHeight + _shadowHeight)];
        }
        [self.navigationBar setBackgroundImage:image
                                 forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)setBarHeight:(CGFloat)barheight shadowHeight:(CGFloat)shadowheight
{
    _barHeight = barheight;
    _shadowHeight = shadowheight;
    
    UIScreen *screen = [UIScreen mainScreen];
    CGRect frame = screen.bounds;
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait || 
        self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        [MTSource setHeight:_barHeight + _shadowHeight
                   withView:_navigationBar];
        [MTSource setHeight:frame.size.height - _barHeight 
                   withView:_contentView];
    }else {
        [MTSource setHeight:_barHeight + _shadowHeight
                   withView:_navigationBar];
        [MTSource setHeight:frame.size.width - _barHeight
                   withView:_contentView];
    }
    UIDevice *device = [UIDevice currentDevice];
    CGFloat version = [[device systemVersion] floatValue];
    if (version >= 5.0) {
        UIImage *image;
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait || 
            self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
        {
            image = [_backgroundImage transformToSize:CGSizeMake(frame.size.width, _barHeight + _shadowHeight)];
        }else {
            image = [_backgroundImage transformToSize:CGSizeMake(frame.size.height, _barHeight + _shadowHeight)];
        }
        [self.navigationBar setBackgroundImage:image
                                 forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)pushViewController:(UIViewController *)viewController 
                  animated:(BOOL)animated
{
    if ([_showingViewControllers containsObject:viewController]) {
        MTLog(@"这个界面已经在当前显示的界面栈里边了!");
        return;
    }
    UIViewController *tView = [_showingViewControllers lastObject];
    if ([[_contentView subviews] containsObject:tView.view]) 
        [tView.view removeFromSuperview];
    [_showingViewControllers addObject:viewController];
    [self addSubViewController:viewController animated:animated];
    
    if (animated) {
        [_contentView.layer addAnimation:_pushAnimation
                                  forKey:@"contentViewPushIn"];
    }
    [_navigationBar pushNavigationItem:viewController.navigationItem
                              animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *tView = [_showingViewControllers lastObject];
    if ([[_contentView subviews] containsObject:tView.view]) 
        [tView.view removeFromSuperview];
    [[tView retain] autorelease];
    [_showingViewControllers removeObject:tView];
    tView = [_showingViewControllers lastObject];
    [self addSubViewController:tView animated:animated];
    
    if (animated) {
        [_contentView.layer addAnimation:_popAnimation
                                  forKey:@"contentViewPopOut"];
    }
    [_navigationBar popNavigationItemAnimated:animated];
    return tView;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![_showingViewControllers containsObject:viewController]) {
        MTLog(@"这个界面不在当前显示的界面栈里边了!");
        return nil;
    }
    //现在显示的界面移除。
    UIViewController *tView = [_showingViewControllers lastObject];
    if ([[_contentView subviews] containsObject:tView.view]) 
        [tView.view removeFromSuperview];
    NSMutableArray *outArr = [NSMutableArray array];
    while (tView != viewController) {
        [outArr addObject:tView];
        [_showingViewControllers removeObject:tView];
        tView = [_showingViewControllers lastObject];
        [_navigationBar popNavigationItemAnimated:NO];
    }
    [self addSubViewController:tView
                      animated:animated];
    if (animated) {
        [_contentView.layer addAnimation:_popAnimation
                                  forKey:@"contentViewPopOut"];
    }
    return outArr; 
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    return [self popToViewController:[_showingViewControllers objectAtIndex:0]
                            animated:animated];
}

- (void)addSubViewController:(UIViewController*)viewCtrl
                    animated:(BOOL)animated
{
    [MTSource setTop:0 withView:viewCtrl.view];
    [_contentView addSubview:viewCtrl.view];
    if ([viewCtrl respondsToSelector:@selector(navigationBarHidden)]) {
        self.navigationBarHidden = (BOOL)[viewCtrl performSelector:@selector(navigationBarHidden)];
    }
    /*static UIBarButtonItem *spaceItem = nil;
    if (!spaceItem) spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSMutableArray *items = [NSMutableArray array];
    if (viewCtrl.navigationItem.leftBarButtonItem) {
        [items addObject:viewCtrl.navigationItem.leftBarButtonItem];
    }else {
        CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (systemVersion >= 5.0 &&
            [viewCtrl.navigationItem.leftBarButtonItems count]) {
            [items addObjectsFromArray:viewCtrl.navigationItem.leftBarButtonItems];
        }
    }
    [items addObject:spaceItem];
    
    if (viewCtrl.navigationItem.rightBarButtonItem) {
        [items addObject:viewCtrl.navigationItem.rightBarButtonItem];
    }else {
        CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (systemVersion >= 5.0 &&
            [viewCtrl.navigationItem.rightBarButtonItems count]) {
            [items addObjectsFromArray:viewCtrl.navigationItem.rightBarButtonItems];
        }
    }
    [_navigationBar setItems:items animated:animated];*/
}

- (UIViewController*)visibleViewController
{
    return [_showingViewControllers lastObject];
}

- (UIViewController*)topViewController
{
    @try {
        return [_showingViewControllers objectAtIndex:0];
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (NSArray*)viewControllers
{
    return _showingViewControllers;
}

- (void)setViewControllers:(NSArray *)tviewControllers
{
    [self setViewControllers:tviewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)tviewControllers animated:(BOOL)animated
{
    UIViewController *ctrl = [_showingViewControllers lastObject];
    if ([[_contentView subviews] containsObject:ctrl.view]) {
        [ctrl.view removeFromSuperview];
    }
    [_showingViewControllers setArray:tviewControllers];
    NSMutableArray *nArr = [NSMutableArray array];
    [tviewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *ctrl = obj;
        [nArr addObject:ctrl.navigationItem];
    }];
    [_navigationBar setItems:nArr animated:animated];
    if (animated) {
        [_contentView.layer addAnimation:_popAnimation
                                  forKey:@"contentViewPopOut"];
    }
    [self addSubViewController:[tviewControllers lastObject] animated:animated];
}

- (void)setViewControllerKey:(NSString *)viewControllerKey
{
    [self setViewControllerKey:viewControllerKey animated:NO];
}

- (void)setViewControllerKey:(NSString *)viewControllerKey animated:(BOOL)animated
{
    if ([viewControllerKey isEqualToString:_viewControllerKey]) {
        return;
    }
    [viewControllerKey retain];
    [_viewControllerKey release];
    _viewControllerKey = viewControllerKey;
    
    UIViewController *tViewCtrl = [_showingViewControllers lastObject];
    if ([[_contentView subviews] containsObject:tViewCtrl.view]) {
        [tViewCtrl.view removeFromSuperview];
    }
    _showingViewControllers = [_viewControllersDictionary objectForKey:viewControllerKey];
    if (!_showingViewControllers) {
        _showingViewControllers = [NSMutableArray array];
        [_viewControllersDictionary setObject:_showingViewControllers
                                       forKey:viewControllerKey];
    }
    
    NSMutableArray *nArr = [NSMutableArray array];
    [_showingViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *ctrl = obj;
        [nArr addObject:ctrl.navigationItem];
    }];
    [_navigationBar setItems:nArr animated:animated];
    if (animated) {
        [_contentView.layer addAnimation:_popAnimation
                                  forKey:@"contentViewPopOut"];
    }
    [self addSubViewController:[_showingViewControllers lastObject] animated:animated];
}

- (void)setBackGroundImage:(UIImage*)_image
{
    [_image retain];
    [_backgroundImage release];
    _backgroundImage = _image;
    UIDevice *device = [UIDevice currentDevice];
    CGFloat version = [[device systemVersion] floatValue];
    if (version >= 5.0) {
        CGRect rect = [UIScreen mainScreen].bounds;
        UIImage *image;
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait || 
            self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
        {
            image = [_backgroundImage transformToSize:CGSizeMake(rect.size.width, _barHeight + _shadowHeight)];
        }else {
            image = [_backgroundImage transformToSize:CGSizeMake(rect.size.height, _barHeight + _shadowHeight)];
        }
        [self.navigationBar setBackgroundImage:image
                                 forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    [self setNavigationBarHidden:navigationBarHidden
                        animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated
{
    if (_navigationBarHidden == navigationBarHidden) {
        return;
    }
    CGRect bounds = [UIScreen mainScreen].bounds;
    _navigationBarHidden = navigationBarHidden;
    _navigationBar.hidden = _navigationBarHidden;
    if (_navigationBarHidden) {
        bounds.origin.y = 0;
        _contentView.frame = bounds;
    }else {
        bounds.origin.y = _barHeight;
        _contentView.frame = bounds;
    }
    if (animated) {
        CATransition *animation = [CATransition animation];
        [_navigationBar.layer addAnimation:animation
                                    forKey:@"animationNavigationBar"];
        [UIView beginAnimations:@"animationContentView"
                        context:nil];
        [UIView commitAnimations];
    }
}

@end
