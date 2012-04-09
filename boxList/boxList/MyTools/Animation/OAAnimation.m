//
//  OAAnimation.m
//  ipadOA
//
//  Created by zrz on 11-1-9.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OAAnimation.h"
#import "OACallBack.h"

#define animationMark		@"OAAnimation No."
#define OAADurationDefault  1.5

@implementation OAAnimation

@synthesize animationType = _animationType , duration = _duration , callBackObj = _callBackObj;
@synthesize overAction = _overAction , animationAtion = _animationAtion , close = _close;		

static int count = 0;

- (id)initWithType:(OAAnimationType)type
{
	if (self = [super init]) {
		_animationType = type;
		_duration = OAADurationDefault;
		count++;
		_No = count;
		_close = NO;
		_condition = [[NSCondition alloc] init];
	}
	return self;
}

- (void)addOverTarget:(id)target action:(SEL)action
{
	if (!_overAction) {
		_overAction = [[OACallBack alloc] init];
	}
	[_overAction addTarget:target Function:action];
}

- (void)addAnimationTarget:(id)target action:(SEL)action
{
	if (!_animationAtion) {
		_animationAtion = [[OACallBack alloc] init];
	}
	[_animationAtion addTarget:target Function:action];
}

- (void)isAnimationOver
{
	if (_selfOk == TRUE && _subOk == TRUE) {
		[_overAction call];
	}
}

- (void)setAnimation
{
	if (_close) {
		return;
	}
	if (_animationType == OAAnimationTypeOfNoAnimation) {
		_selfOk = TRUE;
		[_animationAtion call:_callBackObj];
		[self isAnimationOver];
	}else {
		NSString *markStr = animationMark;
		[UIView beginAnimations:[markStr stringByAppendingFormat:@"%d" , _No] context:nil];
		[UIView setAnimationDuration:_duration];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[_animationAtion call:_callBackObj];
		if (_animationType == OAAnimationTypeOfNormal) {
			_selfOk = TRUE;
		}
        _timer = [NSTimer scheduledTimerWithTimeInterval:_duration 
                                                  target:self 
                                                selector:@selector(isAnimationOver)
                                                userInfo:nil
                                                 repeats:NO];
		[UIView commitAnimations];
	}
}

- (void)doIt
{
	[_condition lock];
	if (_close) {
		return;
	}
	_selfOk = FALSE;
	if (!_array) {
		_subOk = TRUE;
	}else {
		if (![_array count]) {
			_subOk = TRUE;
		}else {
			_subOk = FALSE;
			int total = [_array count];
			OAAnimation *lastAnimation = [_array objectAtIndex:(total - 1)];
			_nowAdded = [[lastAnimation overAction] count];
			[lastAnimation addOverTarget:self action:@selector(subAnimationOver)];
			OAAnimation *subAnimation = [_array objectAtIndex:0];
			[subAnimation doIt];
		}
	}
	if (_animationAtion) {
		[self setAnimation];
	}else {
		_selfOk = TRUE;
		[self isAnimationOver];
	}
	[_condition unlock];
}

- (void)addSubAnimation:(OAAnimation*)subAnimation
{
	if (!_array) {
		_array = [[NSMutableArray alloc] init];
	}
	int total = [_array count];
	if (total) {
		//remove the delegate in the lastone
		OAAnimation* lastAnimation = [_array objectAtIndex:(--total)];
		
		[lastAnimation addOverTarget:subAnimation action:@selector(doIt)];
	}
	[_array addObject:subAnimation];
}

- (void)doNext{
	
}

- (void)removeOverAt:(int)index
{
	[_overAction removeElementAt:index];
}

- (void)removeAnimationAt:(int)index
{
	[_animationAtion removeElementAt:index];
}

- (void)dealloc
{
	[_callBackObj release];
	[_array release];
	[_animationAtion release];
	[_overAction release];
	[super dealloc];
}

- (void)subAnimationOver
{
	if (_animationType == OAAnimationTypeOfLoop) {
		OAAnimation *subAnimation = [_array objectAtIndex:0];
		[subAnimation doIt];
	}else {
		_subOk = TRUE;
		[self isAnimationOver];
	}
}


- (void)closeIt
{
	if (_array && [_array count]) {
		for (OAAnimation *subAnimation in _array) {
			[subAnimation closeIt];
		}
	}
    if (_timer && [_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
	_close = YES;
}

- (void)openIt
{
	[_condition lock];
	if (_array && [_array count]) {
		for (OAAnimation *subAnimation in _array) {
			[subAnimation openIt];
		}
	}
	_close = NO;
	[_condition unlock];
}

@end
