//
//  OACallBack.h
//  ipadOA
//
//  Created by zrz on 11-1-5.
//  Copyright 2011 zrz. All rights reserved.
//

@interface OACallBackElement : NSObject
{
	id		_delegate;
	SEL		_function;
	id		_object;
}

@property (nonatomic,retain)	id	delegate;
@property (nonatomic,readonly)	SEL	function;
@property (nonatomic,retain)	id	object;

- (id)initWithTarget:(id)target Function:(SEL)tfunction withObject:(id)tobject;

+ (id)callBackElementWithTarget:(id)target Function:(SEL)tfunction withObject:(id)tobject;
@end


@interface OACallBack : NSObject{
@public
	int				_count;
    id              _content;
@private
	NSMutableArray	*_elements;
}
@property (nonatomic,readonly)	int	count;
@property (nonatomic, retain)   id  content;

//ctrl the elements
- (void)addTarget:(id)target Function:(SEL)function;
- (void)removeElementAt:(int)index;
- (void)removeLastElement;

//callback
- (void)call;
- (void)call:(id)object;
@end
