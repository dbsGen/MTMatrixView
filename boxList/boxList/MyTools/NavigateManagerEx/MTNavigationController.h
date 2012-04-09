//
//  MTNavigationController.h
//  DateManager
//
//  Created by apple on 12-1-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CAAnimation;
#define kDefaultViewControllers     @"defaultViewControllers"

@interface MTNavigationController : UIViewController
{
    UINavigationBar *_navigationBar;
    UIView          *_contentView;
    CGFloat         _barHeight,
                    _shadowHeight;
    UILabel         *_titleLabel;
    NSString        *_viewControllerKey;
    
    NSMutableDictionary *_viewControllersDictionary;
    NSMutableArray      *_showingViewControllers;
    UIImage         *_backgroundImage;
}

@property (nonatomic, readonly) UINavigationBar *navigationBar;
@property (nonatomic, readonly) UIView          *contentView;
@property (nonatomic, retain)   CAAnimation     *pushAnimation,
                                                *popAnimation;
@property (nonatomic, readonly) UILabel         *titleLabel;
@property (nonatomic, retain)   NSArray         *viewControllers;
@property (nonatomic, retain)   NSString        *viewControllerKey;
@property (nonatomic, assign)   BOOL            navigationBarHidden;
@property (nonatomic, readonly) UIViewController    *visibleViewController; //this interface will not get the preform view.
@property (nonatomic, readonly) UIViewController    *topViewController;

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated;

- (void)setBarHeight:(CGFloat)barheight 
        shadowHeight:(CGFloat)shadowheight;

- (id)initwithBarHeight:(CGFloat)barHeight 
           shadowHeight:(CGFloat)shadowHeight;

- (void)setBackGroundImage:(UIImage*)image;

//as uikit
- (void)pushViewController:(UIViewController *)viewController 
                  animated:(BOOL)animated;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;
- (void)setViewControllerKey:(NSString *)viewControllerKey animated:(BOOL)animated;

@end

@protocol MTNavigationController <NSObject>

@optional
- (BOOL)navigationBarHidden;

@end
