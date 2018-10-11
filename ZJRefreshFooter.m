//
//  ZJRefreshFooter.m
//  HWRefresh
//
//  Created by LD on 2018/6/5.
//  Copyright © 2018年 hero_wqb. All rights reserved.
//

#import "ZJRefreshFooter.h"
@interface ZJRefreshFooter ()

@property (assign, nonatomic) int lastRefreshCount;

@end
@implementation ZJRefreshFooter
+(instancetype)zj_footer{
    ZJRefreshFooter * footer = [ZJRefreshFooter new];
    footer.refreshOrMore = more;
    [footer setZj_state:ZJRefreshStateNormal];
    return footer;
}
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    //新的父控件
    if (newSuperview) {
        //重新调整frame
        [self setFrameWithContentSize];
    }
}

- (void)setFrameWithContentSize
{
    //内容的高度
    CGFloat contentHeight = zj_scroll.contentSize.height;
    
    //表格的高度
    CGFloat scrollHeight = zj_scroll.bounds.size.height - zj_scrollOriginalInset.top - zj_scrollOriginalInset.bottom;
    
    //设置自己的位置和尺寸
    CGRect frame = self.frame;
    frame.origin.y = MAX(contentHeight, scrollHeight);
    self.frame = frame;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //不能跟用户交互，直接返回
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden ||self.zj_state == ZJRefreshStateRefreshing) return;
    
    if ([keyPath isEqualToString:ZJRefreshContentSize]) {
        //调整frame
        [self setFrameWithContentSize];
        
    }else if ([keyPath isEqualToString:ZJRefreshContentOffset]) {
        //如果正在刷新，直接返回
        if (self.zj_state == ZJRefreshStateRefreshing) return;
        
        //根据偏移量设置相应状态
        [self setStateWithContentOffset];
    }
}

- (void)setStateWithContentOffset
{
    //当前的contentOffset
    CGFloat currentOffsetY = zj_scroll.contentOffset.y;
    
    //尾部控件刚好出现的offsetY
    CGFloat happenOffsetY = [self happenOffsetY];
    
    //如果是向下滚动到看不见尾部控件，直接返回
    if (currentOffsetY <= happenOffsetY) return;
    
    //滑动时
    if (zj_scroll.isDragging) {
        //普通状态和即将刷新状态的临界点
        CGFloat normalTopullingOffsetY = happenOffsetY + self.frame.size.height;
        
        //转为即将刷新状态
        if (self.zj_state == ZJRefreshStateNormal && currentOffsetY > normalTopullingOffsetY) {
            self.zj_state = ZJRefreshStatePulling;
            
            //转为普通状态
        }else if (self.zj_state == ZJRefreshStatePulling && currentOffsetY <= normalTopullingOffsetY) {
            self.zj_state = ZJRefreshStateNormal;
        }
        
        //松手时，如果是松开就可以进行刷新的状态，则进行刷新
    }else if (self.zj_state == ZJRefreshStatePulling) {
        self.zj_state = ZJRefreshStateRefreshing;
    }
}
- (void)setZj_state:(ZJRefreshState)zj_state
{
    //若状态未改变，直接返回
    if (self.zj_state == zj_state) return;
    
    //保存旧状态
    ZJRefreshState oldState = self.zj_state;
    
    //调用父类方法
    [super setZj_state:zj_state];
    
    switch (zj_state) {
        case ZJRefreshStateNormal: {
            //如果由刷新状态返回到普通状态
            if (oldState == ZJRefreshStateRefreshing) {
                [UIView animateWithDuration:0.25f animations:^{
                    UIEdgeInsets inset = zj_scroll.contentInset;
                    inset.bottom = zj_scrollOriginalInset.bottom;
                    zj_scroll.contentInset = inset;
                }];
            }
            CGFloat deltaH = [self heightForContentBreakView];
            int currentCount = [self totalDataCountInScrollView];
            //刚刷新完毕
            if (oldState == ZJRefreshStateRefreshing && deltaH > 0 && currentCount != self.lastRefreshCount) {
                CGPoint offset = zj_scroll.contentOffset;
                offset.y = zj_scroll.contentOffset.y;
                zj_scroll.contentOffset = offset;
            }
            
            break;
        }
            
        case ZJRefreshStatePulling: {
            break;
        }
            
        case ZJRefreshStateRefreshing: {
             UIEdgeInsets inset = zj_scroll.contentInset;
            if(zj_scroll.contentSize.height<zj_scroll.frame.size.height){
                inset.bottom = zj_scroll.frame.size.height - zj_scroll.contentSize.height+self.frame.size.height;
            }else{
                inset.bottom = self.frame.size.height;
            }
            [UIView animateWithDuration:0.25f animations:^{
                zj_scroll.contentInset = inset;
            }];
            break;
        }
        default:
            break;
    }
    
        self.zj_state = zj_state;
}

//刚好看到上拉刷新控件时的contentOffset.y
- (CGFloat)happenOffsetY
{
    CGFloat deltaH = [self heightForContentBreakView];
    if (deltaH > 0) {
        return deltaH - zj_scrollOriginalInset.top;
    } else {
        return - zj_scrollOriginalInset.top;
    }
}

//获得scrollView的内容超出view的高度
- (CGFloat)heightForContentBreakView
{
    CGFloat h = zj_scroll.frame.size.height - zj_scrollOriginalInset.bottom - zj_scrollOriginalInset.top;
    return zj_scroll.contentSize.height - h;
}

- (int)totalDataCountInScrollView
{
    int totalCount = 0;
    
    if ([zj_scroll isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)zj_scroll;
        
        for (int section = 0; section < tableView.numberOfSections; section++) {
            totalCount += [tableView numberOfRowsInSection:section];
        }
        
    }else if ([zj_scroll isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)zj_scroll;
        
        for (int section = 0; section < collectionView.numberOfSections; section++) {
            totalCount += [collectionView numberOfItemsInSection:section];
        }
    }
    
    return totalCount;
}

@end
