//
//  ZJRefreshComponent.m
//  HWRefresh
//
//  Created by LD on 2018/6/5.
//  Copyright © 2018年 hero_wqb. All rights reserved.
//

#import "ZJRefreshComponent.h"
#define ZJWRefreshViewHeight 64.0f // >50.f
#define KImageW 30.0f
#define KLabelW 120.0f
@implementation ZJRefreshComponent
- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size.height = ZJWRefreshViewHeight;
    frame.size.width = [UIScreen mainScreen].bounds.size.width;
    if ([super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        CGFloat imageX = ([UIScreen mainScreen].bounds.size.width - KImageW - KLabelW) * 0.5;
        CGFloat imageY = (ZJWRefreshViewHeight - KImageW) * 0.5;
        CGFloat labelH = 20.f;
        CGFloat imageCenterY = imageY+KImageW*0.5;
        
        //
        CGRect subFrame = CGRectMake(imageX, imageY, KImageW, KImageW);
        self.zj_imgView = [UIImageView new];
        [self.zj_imgView setFrame:subFrame];
        [self addSubview:self.zj_imgView];
        [self.zj_imgView setImage:[UIImage imageNamed:@"图层1"]];
        //
        subFrame = CGRectMake(CGRectGetMaxX(self.zj_stateLabel.frame), imageCenterY-labelH, KLabelW, labelH);
        self.zj_stateLabel = [UILabel new];
        [self.zj_stateLabel setFrame:subFrame];
        [self.zj_stateLabel setTextColor:[UIColor grayColor]];
        [self.zj_stateLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.zj_stateLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.zj_stateLabel];
        
        //
        subFrame = CGRectMake(CGRectGetMaxX(self.zj_stateLabel.frame), imageCenterY, KLabelW, labelH);
        self.zj_timeLabel = [UILabel new];
        [self.zj_timeLabel setFrame:subFrame];
        [self.zj_timeLabel setTextColor:[UIColor grayColor]];
        [self.zj_timeLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.zj_timeLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.zj_timeLabel];
        [self.zj_timeLabel setText:@"最后更新时间"];
        //
        //[self setSubFrameWithFrame];
        
        //[self setSubFrameWithFrame02];
        
        [self setSubFrmeOnlyImage];
        
        [self setZj_state:ZJRefreshStateNormal];
    }
    return self;
}
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 如果不是UIScrollView，不做任何事情
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) return;
    
    //旧的父控件
    [self.superview removeObserver:self forKeyPath:ZJRefreshContentOffset];
    [self.superview removeObserver:self forKeyPath:ZJRefreshContentSize];
    //新的父控件
    if (newSuperview) {
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        [newSuperview addObserver:self forKeyPath:ZJRefreshContentOffset options:options context:nil];
        [newSuperview addObserver:self forKeyPath:ZJRefreshContentSize options:options context:nil];
        
        //记录UIScrollView
        zj_scroll = (UIScrollView *)newSuperview;
        // 设置永远支持垂直弹簧效果
        zj_scroll.alwaysBounceVertical = YES;
        
        //记录UIScrollView最开始的contentInset
        zj_scrollOriginalInset = zj_scroll.contentInset;
    }
}

-(void)setZj_state:(ZJRefreshState)zj_state{
    
    if (_zj_state == zj_state) return;
    
    switch (zj_state) {
        case ZJRefreshStateNormal: {
            [self stopAnimating];
            if(self.refreshOrMore == refresh){
                [self.zj_stateLabel setText:@"下拉可刷新"];
            }else{
                [self.zj_stateLabel setText:@"上拉可加载更多"];
            }
            break;
        }
        case ZJRefreshStatePulling: {
            if(self.refreshOrMore == refresh){
                [self.zj_stateLabel setText:@"释放可刷新"];
            }else{
                [self.zj_stateLabel setText:@"释放可加载更多"];
            }
            break;
        }
            
        case ZJRefreshStateRefreshing: {
            [self startAnimating];
            if(self.refreshOrMore == refresh){
                [self.zj_stateLabel setText:@"正在刷新数据..."];
            }else{
                [self.zj_stateLabel setText:@"正在加载数据..."];
            }
            if (self.refreshingCallback) self.refreshingCallback();
            break;
        }
            
        default:
            break;
    }
    _zj_state = zj_state;
}
#pragma mark -
-(void)setSubFrmeOnlyImage{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGRect subFrame = self.zj_imgView.frame;
    subFrame.origin.x = (width - KImageW) * 0.5;
    [self.zj_imgView setFrame:subFrame];
    [self.zj_timeLabel setHidden:YES];
    [self.zj_stateLabel setHidden:YES];
}
-(void)setSubFrameWithFrame{
    //居中显示图片、提示信息
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat imageX = (width - KImageW - KLabelW)*0.5;
    CGFloat imageY = (ZJWRefreshViewHeight - KImageW)*0.5;
    CGRect subFrame = CGRectMake(imageX, imageY, KImageW, KImageW);
    [self.zj_imgView setFrame:subFrame];
    //
    CGFloat imageCenterY = imageY+KImageW*0.5;
    CGFloat labelH = 20.f;
    subFrame = CGRectMake(CGRectGetMaxX(subFrame), imageCenterY-labelH, KLabelW, labelH);
    [self.zj_stateLabel setFrame:subFrame];
    //
    subFrame = CGRectMake(CGRectGetMinX(subFrame), imageCenterY, KLabelW, labelH);
    [self.zj_timeLabel setFrame:subFrame];
    //    [self.zj_stateLabel setBackgroundColor:[UIColor greenColor]];
    //    [self.zj_timeLabel setBackgroundColor:[UIColor purpleColor]];
}
-(void)setSubFrameWithFrame02{
    //居中显示图片、提示信息
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat imageX = (width - KImageW - KLabelW)*0.5;
    CGFloat imageY = (ZJWRefreshViewHeight - KImageW)*0.5;
    CGRect subFrame = CGRectMake(imageX, imageY, KImageW, KImageW);
    [self.zj_imgView setFrame:subFrame];
    //
    CGFloat imageCenterY = imageY+KImageW*0.5;
    CGFloat labelH = 20.f;
    subFrame = CGRectMake(CGRectGetMaxX(subFrame), imageCenterY-labelH*0.5, KLabelW, labelH);
    [self.zj_stateLabel setFrame:subFrame];
    //
    [self.zj_timeLabel setHidden:YES];
}

#pragma mark -
- (void)beginZJRefreshing{
    self.zj_state = ZJRefreshStateRefreshing;
}
- (void)endZJRefreshing{
    self.zj_state = ZJRefreshStateNormal;
}
//开始动画
- (void)startAnimating
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 36; i++) {
        NSString *imageName = [NSString stringWithFormat:@"图层%d", i + 1];
        UIImage *image = [UIImage imageNamed:imageName];
        if(image)[array addObject:image];
    }
    
    [self.zj_imgView setAnimationImages:array];
    [self.zj_imgView setAnimationDuration:1.2f];
    [self.zj_imgView startAnimating];
}

//结束动画
- (void)stopAnimating
{
    if (self.zj_imgView.isAnimating) {
        [self.zj_imgView stopAnimating];
        [self.zj_imgView performSelector:@selector(setAnimationImages:) withObject:nil afterDelay:0];
    }
}
@end
