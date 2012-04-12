//
//  BLRootViewController.m
//  boxList
//
//  Created by zrz on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BLRootViewController.h"
#import "MTSubMatrixCell.h"
#import "OACallBack.h"

@interface MTDObject : NSObject
{
    id obj1, obj2, obj3;
}

@property (nonatomic, retain)   id obj1, obj2, obj3;

@end

@implementation MTDObject

@synthesize obj1, obj2, obj3;

- (void)dealloc
{
    [obj1   release];
    [obj2   release];
    [obj3   release];
    [super  dealloc];
}

@end

@implementation BLRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        n = 10;
        _matrixView = [[MTMatrixListView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
        _matrixView.matrixDelegate = self;
        [self.view addSubview:_matrixView];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"add"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(addClicked:)];
        self.navigationItem.rightBarButtonItem = barButton;
        [barButton release];
    }
    return self;
}

- (void)dealloc
{
    [_matrixView release];
    [_cache     release];
    [super      dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfSectionsInMatrixView:(MTMatrixListView*)matrixView
{
    return 1;
}

- (MTMatrixViewCell*)matrixView:(MTMatrixListView*)matrixView 
                cellOfIndexPath:(NSIndexPath*)indexPath
{
    static NSString *indentify = @"ass you can";
    MTSubMatrixCell *cell = (MTSubMatrixCell*)[matrixView dequeueReusableCellWithIdentifier:indentify];
    if (!cell) {
        cell = [[MTSubMatrixCell alloc] initWithFrame:CGRectMake(0, 0, 130, 130)
                                       reuseIdentifier:indentify];
        cell.backgroundColor = [UIColor redColor];
    }
    NSString *name = [NSString stringWithFormat:@"%d.JPG", indexPath.row + 1];
    UIImage *image = [_cache objectForKey:name];
    if (!image) {
        MTDObject *obj = [[MTDObject alloc] init];
        obj.obj1 = name;
        obj.obj2 = indexPath;
        [self performSelectorInBackground:@selector(loadImageFile:)
                               withObject:obj];
        [obj release];
    }
    cell.image = image;
    return cell;
}

- (void)loadImageFile:(MTDObject*)obj
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:obj.obj1]];
    MTDObject *_obj = [[MTDObject alloc] init];
    _obj.obj1 = image;
    [image release];
    _obj.obj2 = obj.obj2;
    _obj.obj3 = obj.obj1;
    
    [self performSelectorOnMainThread:@selector(loadOver:)
                           withObject:_obj 
                        waitUntilDone:NO];
    [_obj release];
    [pool drain];
}

- (void)loadOver:(MTDObject*)obj
{
    MTSubMatrixCell *cell = (MTSubMatrixCell*)[_matrixView cellWithIndexPath:obj.obj2];
    cell.image = obj.obj1;
}

- (NSInteger)matrixView:(MTMatrixListView*)matrixView
        numberOfSection:(NSInteger)section
{
    return n;
}


- (void)matrixView:(MTMatrixListView *)matrixView touchIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", indexPath);
}

- (void)addClicked:(id)button
{
    NSLog(@"%@", button);
    NSMutableArray *nArray = [NSMutableArray array];
   [nArray addObject:[NSIndexPath indexPathForRow:n
                                        inSection:0]];
    [nArray addObject:[NSIndexPath indexPathForRow:n + 1
                                         inSection:0]];
    n += 2;
    [_matrixView insertCells:nArray
               withAnimation:YES];
}

@end
