//
//  ZJRefreshComponent.h
//  HWRefresh
//
//  Created by LD on 2018/6/5.
//  Copyright © 2018年 hero_wqb. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ZJRefreshContentOffset @"contentOffset"
#define ZJRefreshContentSize   @"contentSize"
typedef enum {
    ZJRefreshStateNormal = 0,  //普通状态
    ZJRefreshStatePulling,     //释放即可刷新的状态
    ZJRefreshStateRefreshing,  //正在刷新中的状态
} ZJRefreshState;
typedef enum {
    refresh ,  // 下拉刷新
    more,      // 上拉加载更多
} ZJRefreshOrMore;
@interface ZJRefreshComponent : UIView
{
    /** 父控件 */
    UIScrollView * zj_scroll;
    /** 记录 父控件 刚开始的inset */
    UIEdgeInsets zj_scrollOriginalInset;
}
// 状态
@property (nonatomic, assign) ZJRefreshState zj_state;
// 刷新 or 加载
@property (nonatomic, assign) ZJRefreshOrMore refreshOrMore;
// 刷新状态
@property (nonatomic, strong) UILabel * zj_stateLabel;
// 刷新时间
@property (nonatomic, strong) UILabel * zj_timeLabel;
// 刷新图片
@property (nonatomic, strong) UIImageView *zj_imgView;
// 回调
@property (nonatomic, copy) void (^refreshingCallback)(void);

- (void)beginZJRefreshing;

- (void)endZJRefreshing;
@end
