//
//  ZJRefreshHeader.m
//  HWRefresh
//
//  Created by LD on 2018/6/4.
//  Copyright © 2018年 hero_wqb. All rights reserved.
//

#import "ZJRefreshHeader.h"
@interface ZJRefreshHeader()
@property(nonatomic,assign) CGFloat tempScrollOffsetY;
@end
@implementation ZJRefreshHeader
+(instancetype)zj_header{
    ZJRefreshHeader * header = [ZJRefreshHeader new];
    header.refreshOrMore = refresh;
    return header;
}
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if(![newSuperview isKindOfClass:[UIScrollView class]])return;
    //设置自己的位置和尺寸
    CGRect frame = self.frame;
    frame.origin.y = - self.frame.size.height;
    self.frame = frame;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:ZJRefreshContentOffset] && !zj_scroll.isDragging){
        self.tempScrollOffsetY = -zj_scroll.contentOffset.y;
    }
    
    //不能跟用户交互或正在刷新就直接返回
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden || self.zj_state == ZJRefreshStateRefreshing){
        return;
    }
    
    //根据偏移量设置相应状态
    if ([keyPath isEqualToString:ZJRefreshContentOffset]) {
//        [self setStateWithContentOffset];
        [self test];
    }
}
- (void)setStateWithContentOffset
{
    //当前的contentOffset
    CGFloat currentOffsetY = zj_scroll.contentOffset.y;
    
    //头部控件刚好出现的offsetY
    CGFloat happenOffsetY = - zj_scroll.contentInset.top;
    
    //如果是向上滚动到看不见头部控件，直接返回
    if (currentOffsetY >= happenOffsetY) return;
    
    //滑动时
    if (zj_scroll.isDragging) { // 148
        //普通状态和即将刷新状态的临界点
        CGFloat normalTopullingOffsetY = happenOffsetY - self.frame.size.height;
        //转为即将刷新状态
        if (self.zj_state == ZJRefreshStateNormal && currentOffsetY < normalTopullingOffsetY) {
            self.zj_state = ZJRefreshStatePulling;
            
        //转为普通状态
        }else if (self.zj_state == ZJRefreshStatePulling && currentOffsetY >= normalTopullingOffsetY) {
            self.zj_state = ZJRefreshStateNormal;
        }
     
        //松手时，如果是松开就可以进行刷新的状态，则进行刷新
    }else if (self.zj_state == ZJRefreshStatePulling) {
        self.zj_state = ZJRefreshStateRefreshing;
    }
}
-(void)setZj_state:(ZJRefreshState)zj_state{
    //若状态未改变，直接返回
    if(self.zj_state == zj_state) return;
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
                    inset.top -= self.frame.size.height;
                    zj_scroll.contentInset = inset;
                }];
            }
            break;
        }
            
        case ZJRefreshStatePulling: {
            break;
        }
            
        case ZJRefreshStateRefreshing: {
            //执行动画
            [UIView animateWithDuration:0.25f animations:^{
                CGFloat top = zj_scrollOriginalInset.top + self.frame.size.height;
                
                //增加滚动区域
                UIEdgeInsets inset = zj_scroll.contentInset;
                inset.top = top;
                zj_scroll.contentInset = inset;
                
                //设置滚动位置
                CGPoint offset = zj_scroll.contentOffset;
                offset.y = - top;
//                zj_scroll.contentOffset = offset;// 会跳动
            }];
            break;
        }
            
        default:
            break;
    }
    
    self.zj_state = zj_state;
}

-(void)test{
    //当前的contentOffset
    CGFloat currentOffsetY = zj_scroll.contentOffset.y;

    //头部控件刚好出现的offsetY
    CGFloat happenOffsetY = - zj_scroll.contentInset.top;
    
    //如果是向上滚动到看不见头部控件，直接返回
    if (currentOffsetY >= happenOffsetY) return;
    
    //滑动时
    if (zj_scroll.isDragging) { // 148
        
        //普通状态和即将刷新状态的临界点
        CGFloat offsetY = -(self.frame.size.height + self.tempScrollOffsetY);
        //转为即将刷新状态
        if (self.zj_state == ZJRefreshStateNormal && currentOffsetY < offsetY) {
            self.zj_state = ZJRefreshStatePulling;
            
            //转为普通状态
        }else if (self.zj_state == ZJRefreshStatePulling && currentOffsetY >= offsetY) {
            self.zj_state = ZJRefreshStateNormal;
        }
        
        //松手时，如果是松开就可以进行刷新的状态，则进行刷新
    }else if (self.zj_state == ZJRefreshStatePulling) {
        self.zj_state = ZJRefreshStateRefreshing;
    }
}

@end
