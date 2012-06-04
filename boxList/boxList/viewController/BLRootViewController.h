//
//  BLRootViewController.h
//  boxList
//
//  Created by zrz on 12-3-26.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTMatrixListView.h"

@interface BLRootViewController : UIViewController
<MTMatrixListDelegate> {
    NSMutableDictionary *_cache;
    MTMatrixListView    *_matrixView;
    NSMutableArray      *_array;
    NSCondition         *_lock;
    int n;
}


@end
