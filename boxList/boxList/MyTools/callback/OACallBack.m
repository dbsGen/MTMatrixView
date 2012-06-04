//
//  OACallBack.m
//  ipadOA
//
//  Created by zrz on 11-1-5.
//  Copyright 2011 zrz. All rights reserved.
//

#import "OACallBack.h"

@implementation OACallBackElement
@synthesize delegate = _delegate , function = _function , object = _object ;

- (id)initWithTarget:(id)target Function:(SEL)tfunction withObject:(id)tobject
{
	if (self = [super init]) {
		_delegate	=	target;
		_function	=	tfunction;
		_object		=	tobject;
		[_delegate retain];
		[_object retain];
	}
	return self;
}

+ (id)callBackElementWithTarget:(id)target Function:(SEL)tfunction withObject:(id)tobject
{
	OACallBackElement *element=[[[OACallBackElement alloc] 
								initWithTarget:target 
								      Function:tfunction
								    withObject:tobject]
							   autorelease];
	return element;
}

- (void)call
{
	[_delegate performSelector:_function withObject:_object];
}

- (void)call:(id)tobject
{
	_object = tobject;
	[self call];
}

- (void)dealloc
{
	[_delegate release];
	[_object release];
	[super dealloc];
}

@end



@implementation OACallBack
@synthesize count = _count, content = _content;

- (void)addTarget:(id)target Function:(SEL)function
{
	OACallBackElement *newElement = [OACallBackElement callBackElementWithTarget:target 
																		Function:function 
																	  withObject:nil];
	if (!_elements) {
		_elements = [[NSMutableArray alloc] init];
	}
	[_elements addObject:newElement];
	_count++;
}

- (void)call:(id)object
{
	for (int n = 0 ; n<_count ; n++ ) {
		OACallBackElement *theTarget=[_elements objectAtIndex:n];
		[theTarget call:object];
	}
}

- (void)call
{
	for (int n = 0 ; n<_count ; n++ ) {
		OACallBackElement *theTarget=[_elements objectAtIndex:n];
		[theTarget call];
	}
}

- (void)removeElementAt:(int)index
{
	[_elements removeObjectAtIndex:index];
	_count--;
}

- (void)removeLastElement
{
	[_elements removeLastObject];
	_count--;
}

- (void)dealloc
{
	[_elements release];
	[super dealloc];
}

@end
