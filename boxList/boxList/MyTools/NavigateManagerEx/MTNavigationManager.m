//
//  MTNavigationManager.m
//  Bottle
//
//  Created by apple on 11-11-9.
//  Copyright (c) 2011年 zrz. All rights reserved.
//

#import "MTNavigationManager.h"
#import <objc/runtime.h>
#import "MTSource.h"


#define InterViewWidth	210.0f
#define InterViewLeft	((320.0f - InterViewWidth) / 2)
#define BackWidth       50.0f
#define ContentHeight   300.0f

#define newCtroller(obj, Class) {\
if ([Class isSubclassOfClass:[UITableViewController class]]){\
UIViewController *viewController = [[Class alloc] initWithStyle:UITableViewStylePlain];\
obj = viewController;\
}else if ([Class isSubclassOfClass:[UIViewController class]]) {\
UIViewController *viewController = [[Class alloc] initWithNibName:nil bundle:nil];\
obj = viewController;\
}\
}

@interface MTNavigationManager(Private)

- (void)setBackTitle:(UIViewController*)controller;

@end

@implementation MTNavigationManager

@synthesize navigationController;

static MTNavigationManager* _defaultManager = nil;

+ (MTNavigationManager*)defaultManager{
    if (!_defaultManager) {
        _defaultManager = [[MTNavigationManager alloc] init];
    }
    return _defaultManager;
}

#pragma mark - malloc

- (id)init
{
    self = [super init];
    if (self) {
        viewCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [navigationController   release];
    [interView  release];
    [titleLabel release];
    [_animation  release];
    [buttonLabel    release];
    [viewCache release];
    [super  dealloc];
}

- (void)pushViewController:(UIViewController*)ctrl
{
    [self pushViewController:ctrl cache:NO];
}

- (void)pushViewController:(UIViewController*)ctrl cache:(BOOL)isCache
{
    [self pushViewController:ctrl cache:isCache animation:YES];
}

- (void)pushViewController:(UIViewController*)ctrl cache:(BOOL)isCache animation:(BOOL)animation
{
    NSAssert(ctrl, @"you want to push a nil controller to the navigation");
    BOOL ret = ![navigationController.viewControllers containsObject:ctrl];
    NSAssert1(ret, @"controller : %@ , is in navigation stack now", ctrl);
    UIViewController *tViewCtrl = [navigationController.viewControllers lastObject];
    if ([tViewCtrl respondsToSelector:@selector(mtViewDidDisappear:)]) 
        [(id<MTNavigationManagerDelegate>)tViewCtrl mtViewDidDisappear:animation];
    else [tViewCtrl viewDidDisappear:animation];
    [navigationController pushViewController:ctrl animated:animation];
    tViewCtrl = [navigationController.viewControllers lastObject];
    [self setBackTitle:ctrl];
    if ([tViewCtrl respondsToSelector:@selector(mtViewDidAppear:)]) 
        [(id<MTNavigationManagerDelegate>)tViewCtrl mtViewDidAppear:animation];
    else [tViewCtrl viewDidAppear:animation];
    if (isCache) {
        NSString *key = [NSString stringWithUTF8String:object_getClassName(ctrl)];
        [viewCache setObject:ctrl forKey:key];
    }
}

- (void)pushAutoChangeViewController:(UIViewController *)ctrl
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:navigationController.viewControllers];
    if ([array containsObject:ctrl]) {
        [ctrl retain];
        [array removeObject:ctrl];
        [array addObject:ctrl];
        [ctrl release];
        [navigationController setViewControllers:array
                                        animated:YES];
    }else {
        [self pushViewController:ctrl];
    }
}

- (void)pushViewControllerEx:(Class)_class
{
    [self pushViewControllerEx:_class cache:YES];
}

- (void)pushViewControllerEx:(Class)_class cache:(BOOL)isCache
{
    [self pushViewControllerEx:_class cache:isCache animation:YES];
}

- (void)pushViewControllerEx:(Class)_class cache:(BOOL)isCache animation:(BOOL)animation
{
    NSString *key = [NSString stringWithUTF8String:class_getName(_class)];
    UIViewController *ctrl = [viewCache objectForKey:key];
    if (!ctrl) {
        newCtroller(ctrl, _class);
    }
    NSAssert(ctrl, @"the class is not be suported.");
    BOOL ret = [navigationController.viewControllers containsObject:ctrl];
    if (ret) {
        newCtroller(ctrl, _class);
        NSAssert(ctrl, @"the class is not be suported.");
        [ctrl autorelease];
    }
    [self pushViewController:ctrl cache:isCache animation:animation];
    [self setBackTitle:ctrl];
}

- (UIViewController*)popViewController:(BOOL)animation
{
    UIViewController *tViewCtrl = [navigationController.viewControllers lastObject];
    if ([tViewCtrl respondsToSelector:@selector(mtViewDidDisappear:)]) 
        [(id<MTNavigationManagerDelegate>)tViewCtrl mtViewDidDisappear:animation];
    else [tViewCtrl viewDidDisappear:animation];
    UIViewController *ctrl = [navigationController popViewControllerAnimated:animation];
    tViewCtrl = [navigationController.viewControllers lastObject];
    if ([tViewCtrl respondsToSelector:@selector(mtViewDidAppearPop:)]) 
        [(id<MTNavigationManagerDelegate>)tViewCtrl mtViewDidAppearPop:animation];
    else if ([tViewCtrl respondsToSelector:@selector(mtViewDidAppear:)])
        [(id<MTNavigationManagerDelegate>)tViewCtrl mtViewDidAppear:animation];
    else [tViewCtrl viewDidAppear:animation];
    [self setBackTitle:[navigationController.viewControllers lastObject]];
    return ctrl;
}

- (UIViewController*)controller:(Class)_class
{
    NSString *key = [NSString stringWithUTF8String:class_getName(_class)];
    UIViewController *ctrl = [viewCache objectForKey:key];
    if (!ctrl) {
        newCtroller(ctrl, _class);
        if (ctrl) {
            [viewCache setObject:ctrl forKey:key];
            [ctrl release];
        }
    }
    return ctrl;
}

- (void)setNavigationController:(MTNavigationController *)_navigate
{
    [navigationController   release];
    navigationController = _navigate;
    [navigationController retain];
    UIView *view = [_navigate.navigationBar valueForKey:@"_titleView"];
    view.hidden = YES;
    if (!interView) {
        interView =  [[UIView alloc] initWithFrame:CGRectMake(InterViewLeft, 0, InterViewWidth, _navigate.navigationBar.frame.size.height)];
        interView.backgroundColor = [UIColor clearColor];
        interView.clipsToBounds = YES;
        interView.userInteractionEnabled = NO;
    }
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] initWithFrame:interView.bounds];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.shadowColor = [UIColor blackColor]; 
    }
    
    [interView addSubview:titleLabel];
    [_navigate.navigationBar addSubview:interView];
    
    if (!_animation) {
        _animation = [[OAAnimation alloc] initWithType:OAAnimationTypeOfNormal];
        _animation.duration = 8;
        [_animation addAnimationTarget:self action:@selector(moveLabel)];
        [_animation addOverTarget:self action:@selector(moveOver)];
    }
    [_animation closeIt];
    
    if (!buttonLabel) {
        buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, BackWidth - 5, 30)];
        buttonLabel.font = [UIFont systemFontOfSize:14];
        buttonLabel.minimumFontSize = 10;
        buttonLabel.adjustsFontSizeToFitWidth = YES;
        buttonLabel.textAlignment = UITextAlignmentCenter;
        buttonLabel.textColor = [UIColor whiteColor];
        buttonLabel.lineBreakMode = UILineBreakModeHeadTruncation;
        buttonLabel.backgroundColor = [UIColor clearColor];
    }
}

- (void)resetLabel
{
	[MTSource setLeft:InterViewWidth withView:titleLabel];
}

- (void)moveOver
{
	if (_animation.close == NO) {
		[self resetLabel];
		[_animation doIt];
	}
}

- (void)moveLabel
{
	[MTSource setLeft:-labelWidth withView:titleLabel];
}

- (void)popViewController
{
    [self popViewController:YES];
}

- (void)setBackTitle:(UIViewController*)controller
{
    int totle = [navigationController.viewControllers count];
    if (totle > 1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 5, BackWidth, 29);
        [button setBackgroundImage:[UIImage imageNamed:@"navigation_back.png"]
                          forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(popViewController)
         forControlEvents:UIControlEventTouchUpInside];
        //================it's too up,this turn it down
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BackWidth, 34)];
        [tempView addSubview:button];
        //================end
        UIBarButtonItem *backButton = 
        [[UIBarButtonItem alloc] initWithCustomView:tempView];
        controller.navigationItem.leftBarButtonItem = backButton;
        [backButton release];
        [tempView release];
    }else {
        controller.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)setNavigateTitle:(NSString*)tTitle
{
	titleLabel.text = tTitle;
	labelWidth = [MTSource widthOfLabel:titleLabel];
	if (labelWidth > InterViewWidth) {
		if (_animation.close == YES) {
			[_animation openIt];
			[_animation doIt];
		}
		[MTSource setWidth:labelWidth withView:titleLabel];
	}else {
		titleLabel.frame = interView.bounds;
		[_animation closeIt];
		[MTSource setLeft:0 withView:titleLabel];
	}
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers cache:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers cache:(BOOL)isCache
{
    [self setViewControllers:viewControllers cache:isCache animation:YES];
}
 
- (void)setViewControllers:(NSArray*)_viewControllers cache:(BOOL)isCache animation:(BOOL)animation
{
    if (isCache) {
        for (UIViewController* ctrl in _viewControllers) {
            NSString *key = [NSString stringWithUTF8String:object_getClassName(ctrl)];
            UIViewController *nCtrl = [viewCache objectForKey:key];
            if (!nCtrl) {
                [viewCache setObject:ctrl forKey:key];
            }
        }
    }
    UIViewController *tViewCtrl = [navigationController.viewControllers lastObject];
    if ([tViewCtrl respondsToSelector:@selector(mtViewDidDisappear:)]) 
        [(id<MTNavigationManagerDelegate>)tViewCtrl mtViewDidDisappear:animation];
    else [tViewCtrl viewDidDisappear:animation];
    [navigationController setViewControllers:_viewControllers animated:animation];
    tViewCtrl = [navigationController.viewControllers lastObject];
    if ([tViewCtrl respondsToSelector:@selector(mtViewDidAppear:)]) 
        [(id<MTNavigationManagerDelegate>)tViewCtrl mtViewDidAppear:animation];
    else [tViewCtrl viewDidAppear:animation];
    [self setBackTitle:[navigationController.viewControllers lastObject]];
}

- (void)setViewControllersEx:(Class *)vcClasses
{
    Class *tp = vcClasses;
    NSMutableArray *array = [NSMutableArray array];
    while (*tp) {
        NSString *key = [NSString stringWithUTF8String:class_getName(*tp)];
        UIViewController *ctrl = [viewCache objectForKey:key];
        if (!ctrl) {
            newCtroller(ctrl, *tp);
            NSAssert(ctrl, @"the class is not be suported.");
        }
        [array addObject:ctrl];
        tp++;
    }
    [self setViewControllers:array cache:YES];
}

@end
