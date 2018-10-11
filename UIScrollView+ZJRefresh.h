//
//  UIScrollView+ZJRefresh.h
//  HWRefresh
//
//  Created by LD on 2018/6/4.
//  Copyright © 2018年 hero_wqb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (ZJRefresh)
-(void)addZJHeaderRefreshWithCallBackBlock:(void(^)(void))block;
//让下拉刷新控件停止刷新
- (void)endHeaderZJRefreshing;


//添加上拉刷新回调
- (void)addFooterZJRefreshWithCallbackBlock:(void(^)(void))block;
//让上拉刷新控件停止刷新
- (void)endFoorerZJRefreshing;
@end
