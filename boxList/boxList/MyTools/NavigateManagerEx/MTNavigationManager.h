//
//  MTNavigationManager.h
//  Bottle
//
//  Created by apple on 11-11-9.
//  Copyright (c) 2011年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAAnimation.h"
#import "MTNavigationController.h"

@interface MTNavigationManager : NSObject{
    MTNavigationController *navigationController;
    NSMutableDictionary *viewCache;
    UIView  *interView;
    UILabel *titleLabel;
    OAAnimation *_animation;
    CGFloat labelWidth;
    UILabel *buttonLabel;
    
    //height of content view
}

+ (MTNavigationManager*)defaultManager;

@property (nonatomic, retain) MTNavigationController *navigationController;

- (void)pushViewController:(UIViewController*)ctrl;
- (void)pushViewController:(UIViewController*)ctrl cache:(BOOL)isCache;
- (void)pushViewController:(UIViewController*)ctrl cache:(BOOL)isCache animation:(BOOL)animation;

- (void)pushAutoChangeViewController:(UIViewController *)ctrl;

#define pushViewControllerEX(Class) pushViewControllerEx:[Class class]

- (void)pushViewControllerEx:(Class)_class;
- (void)pushViewControllerEx:(Class)_class cache:(BOOL)isCache;
- (void)pushViewControllerEx:(Class)_class cache:(BOOL)isCache animation:(BOOL)animation;

- (UIViewController*)popViewController:(BOOL)animation;

- (void)setViewControllers:(NSArray*)viewControllers;
- (void)setViewControllers:(NSArray*)viewControllers cache:(BOOL)isCache;
- (void)setViewControllers:(NSArray*)viewControllers cache:(BOOL)isCache animation:(BOOL)animation;

#define toClass(Class)  [Class class]
- (void)setViewControllersEx:(Class*)vcClasses;

- (UIViewController*)controller:(Class)_class;

- (void)setNavigateTitle:(NSString*)tTitle;

@end

@protocol MTNavigationManagerDelegate <NSObject>

@optional

- (void)mtViewDidAppear:(BOOL)animated;
- (void)mtViewDidDisappear:(BOOL)animated;
- (void)mtViewDidAppearPop:(BOOL)animated;

@end
