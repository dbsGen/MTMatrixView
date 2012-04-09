//
//  MTMatrixListView.m
//  boxList
//
//  Created by zrz on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MTMatrixListView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MTMatrixListView

@synthesize spaceWidth = _spaceWidth, spaceHeight = _spaceHeight, matrixDelegate = _matrixDelegate;
@synthesize headerHeight = _headerHeight;

static CATransition *__reloadTransition;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _spaceHeight = 150;
        _spaceWidth = 150;
        _startRange.location = 0;
        _startRange.length = 0;
        _endRange.location = 0;
        _endRange.length = 0;
        [super setDelegate:self];
        _sizes = [[NSMutableArray alloc] init];
        _cached = [[NSMutableDictionary alloc] init];
        if (!__reloadTransition) {
            __reloadTransition = [[CATransition alloc] init];
            __reloadTransition.type = @"fade";
        }
        self.contentSize = (CGSize){320, 480};
        [self reloadDatas];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self reloadDatas];
}

- (void)dealloc
{
    [_touchStartIndex   release];
    _matrixDelegate = nil;
    [_sizes     release];
    [_cached    release];
    [super      dealloc];
}

- (void)reloadDatas
{
    CGRect rect = self.frame;
    _transverse = rect.size.width / _spaceWidth;
    if (!_transverse) 
        _transverse = 1;
    _left = (rect.size.width - _transverse * _spaceWidth) / 2;
    int sectionCount = [_matrixDelegate numberOfSectionsInMatrixView:self];
    [_sizes removeAllObjects];
    CGFloat top = 0;
    for (int n = 0 ; n < sectionCount ; n++) {
        NSMutableArray *nArray = [NSMutableArray array];
        CGFloat headerHeight = 5;
        if ([_matrixDelegate respondsToSelector:@selector(matrixView:headerHeightOfSection:)]) {
            headerHeight = [_matrixDelegate matrixView:self headerHeightOfSection:n];
        }
        [nArray addObject:[NSValue valueWithMTSize:(MTSize){top, headerHeight}]];
        top += headerHeight;
        int totle = [_matrixDelegate matrixView:self numberOfSection:n];
        int lineNum = totle;
        for (int m = 0 ; m < lineNum; m++) {
            //if you want to define each orther row height , here white the delegate.
            if (m > 1 && m % _transverse == 0) {
                top += _spaceHeight;
            }
            [nArray addObject:[NSValue valueWithMTSize:(MTSize){top, _spaceHeight}]];
        }
        top += _spaceHeight;
        [_sizes addObject:nArray];
    }
    [self removeSubviewsInDRange:(MTDRange){_startRange, _endRange}];
    _startRange = (MTRange){0,0};
    _endRange = (MTRange){0,0};
    _topBounds = (MTSize){0,0};
    _bottomBounds = (MTSize){0,0};
    [self showSubviewInRect:(CGRect){self.contentOffset, 
        self.bounds.size}];
    if (top < rect.size.height) {
        top = rect.size.height + 0.5;
    }
    self.contentSize = CGSizeMake(self.bounds.size.width, top);
}

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate
{
    m_delegate = delegate;
}

- (MTMatrixViewCell*)dequeueReusableCellWithIdentifier:(NSString*)indentify
{
    NSMutableArray *array = [_cached objectForKey:indentify];
    MTMatrixViewCell *cell = [array count] ? [array lastObject] : nil;
    if (cell) {
        [[cell retain] autorelease];
        [array removeObject:cell];
    }
    return cell;
}

#pragma mark - self method

- (void)removeSubview:(UIView*)view
{
    if (![[self subviews] containsObject:view]) 
        return;
    view.tag = -1;
    if ([view isKindOfClass:[MTMatrixViewCell class]]) {
        NSString *indentify = ((MTMatrixViewCell*)view).reuseIdentifier;
        NSMutableArray *array = [_cached objectForKey:indentify];
        if (!array) {
            array = [NSMutableArray array];
            [_cached setObject:array
                        forKey:indentify];
        }
        [array addObject:view];
    }
    [view removeFromSuperview];
}

- (void)removeSubviewsInDRange:(MTDRange)drange
{
    if (drange.range1.location == drange.range2.location) {
        for (int n = drange.range1.length ; 
             n <= drange.range2.length;
             n ++) {
            UIView *subView = [self viewWithTag:tagWithRowAndSction(n, drange.range1.location)];
            [self removeSubview:subView];
        }
    }else {
        for (int n = drange.range1.length, 
             t = [[_sizes objectAtIndex:drange.range1.location] count];
             n < t; n++) {
            UIView *subView = [self viewWithTag:tagWithRowAndSction(n, drange.range1.location)];
            [self removeSubview:subView];
        }
        for (int n = drange.range1.location + 1; 
             n <= drange.range2.location - 1; n++) {
            for (int m = 0 , t = [[_sizes objectAtIndex:n] count]; 
                 m < t; m ++) {
                UIView *subView = [self viewWithTag:tagWithRowAndSction(m, n)];
                [self removeSubview:subView];
            }
        }
        for (int n = 0; n <= drange.range2.length; n++) {
            UIView *subView = [self viewWithTag:tagWithRowAndSction(n, drange.range2.location)];
            [self removeSubview:subView];
        }
    }
}

- (MTMatrixViewCell*)cellWithIndexPath:(NSIndexPath*)indexPath
{
    if (!indexPath) {
        return nil;
    }
    return (id)[self viewWithTag:tagWithIndexPath(indexPath)];
}

#define addContent(tSection, num, tWidth)\
{\
    MTSize size = [[[_sizes objectAtIndex:tSection] objectAtIndex:num] MTSizeValue];\
    if (!num) {\
        if ([_matrixDelegate respondsToSelector:@selector(matrixView:headerOfSection:)]) {\
            UIView *view = [_matrixDelegate matrixView:self headerOfSection:tSection];\
            view.tag = tagWithRowAndSction(0, tSection);\
            view.frame = (CGRect){0, size.offset, tWidth, size.height};\
            [self addSubview:view];\
        }\
    }else {\
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:num - 1 \
                                                    inSection:tSection];\
        MTMatrixViewCell *cell = [_matrixDelegate matrixView:self \
        cellOfIndexPath:indexPath];\
        cell.center = (CGPoint){_left + _spaceWidth / 2 +  (num - 1) % _transverse * _spaceWidth, \
        size.offset + _spaceHeight / 2};\
        cell.tag = tagWithRowAndSction(num, tSection);\
        [self insertSubview:cell atIndex:0];\
    }\
}

- (void)addSubviewInDRange:(MTDRange)drange
{
    CGFloat width = self.bounds.size.width;
    if (drange.range1.location == drange.range2.location) {
        for (int n = drange.range1.length ; 
             n <= drange.range2.length;
             n ++) {
            addContent(drange.range1.location, n, width);
        }
    }else {
        for (int n = drange.range1.length, 
             t = [[_sizes objectAtIndex:drange.range1.location] count];
             n < t; n++) {
            addContent(drange.range1.location, n, width);
        }
        for (int l = drange.range1.location + 1; 
             l <= drange.range2.location - 1; l++) {
            for (int m = 0 , t = [[_sizes objectAtIndex:l] count]; 
                 m < t; m ++) {
                addContent(l, m, width);
            }
        }
        for (int n = 0; n <= drange.range2.length; n++) {
            addContent(drange.range2.location, n, width);
        }
    }
}

- (void)showSubviewInRect:(CGRect)rect
{
    if (![_sizes count] ||
        (rect.origin.y >= _topBounds.offset &&
         rect.origin.y <= _topBounds.offset + _topBounds.height &&
        rect.origin.y + rect.size.height >= _bottomBounds.offset &&
         rect.origin.y + rect.size.height <= _bottomBounds.height + _bottomBounds.offset)) {
        return;
    }
    MTRange startRange = {0,0};
    MTRange endRange = {0,0};
    getRangeWithSizes(_sizes, rect, &startRange, &endRange);
    if (endRange.location == 0 && endRange.length == 0) {
        int count = [_sizes count];
        if (count) {
            endRange.location = count - 1;
            endRange.length = [[_sizes objectAtIndex:
                                endRange.location] count] - 1;
        }
    }
    if (startRange.length == _startRange.length &&
        startRange.location == _startRange.location &&
        endRange.length == _endRange.length &&
        endRange.location == _endRange.location) {
        return;
    }
    //do
    
    MTDRange drange = rangeOutCompare((MTDRange){_startRange, _endRange}, 
                                     (MTDRange){startRange, endRange});
    [self removeSubviewsInDRange:drange];
    
    drange = rangeOutCompare((MTDRange){startRange, endRange}, 
                            (MTDRange){_startRange, _endRange});
    [self addSubviewInDRange:drange];
    
    
    //end
    _startRange = startRange;
    _endRange = endRange;
    _topBounds = [[[_sizes objectAtIndex:_startRange.location] 
                   objectAtIndex:_startRange.length] MTSizeValue];
    _bottomBounds = [[[_sizes objectAtIndex:_endRange.location] 
                      objectAtIndex:_endRange.length] MTSizeValue];
}

- (NSIndexPath*)indexPathWithCell:(MTMatrixViewCell*)cell
{
    return indexPathWithTag(cell.tag);
}

#pragma mark - control

- (void)insertCells:(NSArray*)indexPaths withAnimation:(BOOL)animation
{
    
}

- (void)deleteCells:(NSArray*)indexPaths withAnimation:(BOOL)animation
{
    for (NSIndexPath *indexPath in indexPaths) {
        
    }
}

- (void)reloadCells:(NSArray*)indexPaths withAnimation:(BOOL)animation
{
    for (NSIndexPath *indexPath in indexPaths) {
        MTMatrixViewCell *cell = [self cellWithIndexPath:indexPath];
        [self removeSubview:cell];
        cell = [_matrixDelegate matrixView:self 
                           cellOfIndexPath:indexPath];
        MTSize size = [[[_sizes objectAtIndex:indexPath.section] 
                        objectAtIndex:indexPath.row + 1] MTSizeValue];
        cell.center = (CGPoint){_left + _spaceWidth / 2 +
            indexPath.row % _transverse * _spaceWidth, 
            size.offset + _spaceHeight / 2};
        cell.tag = tagWithRowAndSction(indexPath.row + 1, indexPath.section);
        [self addSubview:cell];
        if (animation) {
            [cell.layer addAnimation:__reloadTransition
                              forKey:@"cellReload"];
        }
    }
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(scrollViewDidScroll:)])
        [m_delegate scrollViewDidScroll:scrollView];
    //移动时
    [self showSubviewInRect:(CGRect){self.contentOffset, 
        self.bounds.size}];
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(scrollViewDidZoom:)])
        [m_delegate scrollViewDidZoom:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([m_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
        [m_delegate scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([m_delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)])
        [m_delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([m_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
        [m_delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
        [m_delegate scrollViewWillBeginDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
        [m_delegate scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
        [m_delegate scrollViewDidEndScrollingAnimation:scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [m_delegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if ([m_delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
        [m_delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)])
        return [m_delegate scrollViewShouldScrollToTop:scrollView];
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [m_delegate scrollViewDidScrollToTop:scrollView];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self];
    [_touchStartIndex release];
    _touchStartIndex = [indexOfPoint(_sizes, point, _transverse, _spaceWidth, _spaceHeight, _left) retain];
    if (_touchStartIndex && [_matrixDelegate respondsToSelector:@selector(matrixView:touchBeginIndexPath:)]) {
        [_matrixDelegate matrixView:self touchBeginIndexPath:_touchStartIndex];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self];
    NSIndexPath *endIndexPath = indexOfPoint(_sizes, point, _transverse, _spaceWidth, _spaceHeight, _left);
    if (endIndexPath && [_matrixDelegate respondsToSelector:@selector(matrixView:touchEndIndexPath:)]) {
        [_matrixDelegate matrixView:self touchEndIndexPath:endIndexPath];
    }
    if (endIndexPath && [endIndexPath compare:_touchStartIndex] == NSOrderedSame) {
        if ([_matrixDelegate respondsToSelector:@selector(matrixView:touchIndexPath:)]) {
            [_matrixDelegate matrixView:self touchIndexPath:_touchStartIndex];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self];
    NSIndexPath *indexPath = indexOfPoint(_sizes, point, _transverse, _spaceWidth, _spaceHeight, _left);
    if (indexPath && [_matrixDelegate respondsToSelector:@selector(matrixView:scanIndexPath:)]) {
        [_matrixDelegate matrixView:self scanIndexPath:indexPath];
    }
}

@end
