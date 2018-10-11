//
//  UIScrollView+ZJRefresh.m
//  HWRefresh
//
//  Created by LD on 2018/6/4.
//  Copyright © 2018年 hero_wqb. All rights reserved.
//

#import "UIScrollView+ZJRefresh.h"
#import "ZJRefreshHeader.h"
#import "ZJRefreshFooter.h"
#import <objc/runtime.h>
@interface UIScrollView()
@property (nonatomic, weak) ZJRefreshHeader * header;
@property (nonatomic, weak) ZJRefreshFooter * footer;
@end
static char ZJRefreshHeaderKey;
static char ZJRefreshFooterKey;
@implementation UIScrollView (ZJRefresh)
-(void)setHeader:(ZJRefreshHeader *)header{
    [self willChangeValueForKey:@"ZJRefreshHeaderKey"];
    objc_setAssociatedObject(self, &ZJRefreshHeaderKey, header, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"ZJRefreshHeaderKey"];
}
- (ZJRefreshHeader *)header{
    return  objc_getAssociatedObject(self, &ZJRefreshHeaderKey);
}
-(void)setFooter:(ZJRefreshFooter *)footer{
    [self willChangeValueForKey:@"ZJRefreshFooterKey"];
    objc_setAssociatedObject(self, &ZJRefreshFooterKey, footer, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"ZJRefreshFooterKey"];
}
- (ZJRefreshFooter *)footer{
    return objc_getAssociatedObject(self, &ZJRefreshFooterKey);
}

-(void)addZJHeaderRefreshWithCallBackBlock:(void(^)(void))block{
    if (!self.header) {
        ZJRefreshHeader *header = [ZJRefreshHeader zj_header];
        [self addSubview:header];
        [header.zj_stateLabel setText:@"下拉可刷新"];
        self.header = header;
    }
    self.header.refreshingCallback = block;
}
- (void)endHeaderZJRefreshing{
    [self.header endZJRefreshing];
}

//添加上拉刷新回调
- (void)addFooterZJRefreshWithCallbackBlock:(void(^)(void))block{
    if(!self.footer){
        ZJRefreshFooter * footer = [ZJRefreshFooter zj_footer];
        [self addSubview:footer];
        [footer.zj_stateLabel setText:@"上拉可加载更多"];
        self.footer = footer;
    }
    self.footer.refreshingCallback = block;
}
//让上拉刷新控件停止刷新
- (void)endFoorerZJRefreshing{
    [self.footer endZJRefreshing];
}
@end
