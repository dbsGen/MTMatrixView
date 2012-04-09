//
//  MTSubMatrixCell.m
//  boxList
//
//  Created by zrz on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MTSubMatrixCell.h"

@implementation MTSubMatrixCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _imageView.frame = self.bounds;
}

- (UIImage*)image
{
    return _imageView.image;
}

- (void)setImage:(UIImage *)image
{
    _imageView.image = image;
}

@end
