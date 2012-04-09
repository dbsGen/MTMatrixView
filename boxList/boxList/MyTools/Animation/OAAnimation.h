//
//  OAAnimation.h
//  ipadOA
//
//  Created by zrz on 11-1-9.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OACallBack;

enum {
	OAAnimationTypeOfLoop	= 1,
	OAAnimationTypeOfNormal,
	OAAnimationTypeOfNoAnimation
};
typedef int OAAnimationType;

@interface OAAnimation : NSObject {
@public
	OAAnimationType		_animationType;
	id					_callBackObj;
	NSTimeInterval		_duration;
@private	
	int					_No;
	int					_nowAdded;					//the end animation delegate num
	BOOL				_ended;						//is this animation set the end one
	BOOL				_selfOk;
	BOOL				_subOk;
	BOOL				_close;
	NSMutableArray		*_array;
	OACallBack			*_overAction;				//call when animation end
	OACallBack			*_animationAtion;			//animation ation
	NSCondition			*_condition;
    NSTimer             *_timer;
}

@property (readonly)BOOL close;
@property (nonatomic) OAAnimationType	animationType;
@property (nonatomic) NSTimeInterval	duration;
@property (nonatomic,retain) id			callBackObj;
@property (nonatomic,retain) OACallBack	*overAction , *animationAtion;

- (id)initWithType:(OAAnimationType)type;

- (void)addSubAnimation:(OAAnimation*)subAnimation;

- (void)addOverTarget:(id)target action:(SEL)action;
- (void)removeOverAt:(int)index;
- (void)addAnimationTarget:(id)target action:(SEL)action;
- (void)removeAnimationAt:(int)index;

- (void)doIt;
- (void)closeIt;
- (void)openIt;

@end
