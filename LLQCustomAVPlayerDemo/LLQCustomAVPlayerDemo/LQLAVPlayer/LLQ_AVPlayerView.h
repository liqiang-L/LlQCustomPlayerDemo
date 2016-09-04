//
//  LLQ_AVPlayerView.h
//  LLQCustomAVPlayerDemo
//
//  Created by Apple on 16/9/3.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "playerTpyeDeifne.h"
#import "UIView+Extent.h"
typedef void(^LayoutBlock)(MASConstraintMaker *make) ;

@interface LLQ_AVPlayerView : UIView{
    @public
    float * _playerHeight;
}

/**
 *  播放地址
 */
@property (nonatomic, strong) NSURL * playerUrl;

/**
 *  所在视图
 */
@property (nonatomic, weak) UIView * playerSuperView;


/**
 *  播放状态
 */
@property (nonatomic, assign) BOOL isPlaying;

/**
 *  唯一实例化方法
 *
 *  @param playerUrl 播放地址
 *  @param height    期望高度
 *  @param playerSuperView 父级View
 *
 *  @return 实例化对象
 */
+(instancetype)avPlayerViewWithUrl:(NSURL*)playerUrl height:(CGFloat)height playerSuperView:(UIView*)playerSuperView;

/**
 *  初始化 播放器位置
 *
 *  @param portraitBlock     正常状态下屏幕位置block'
 *  @param interstitialBlock 全屏下播放器位置block
 *
 *  @return return value description
 */
- (NSArray *)avPlaymakeConstraints:(LayoutBlock)portraitBlock interstitialBlock:(LayoutBlock)interstitialBlock;


/**
 * @b 暂时性的销毁播放器, 用于节省内存, 再用时可以回到销毁点继续播放
 */
-(void)destoryCustomPlayer;

/**
 * @b destory 后再次播放, 会记住之前的播放状态, 时间和是否暂停
 */
-(void)replay;

@end
