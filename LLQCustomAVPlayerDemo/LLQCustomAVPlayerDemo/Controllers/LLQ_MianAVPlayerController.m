//
//  LLQ_MianAVPlayerController.m
//  LLQCustomAVPlayerDemo
//
//  Created by Apple on 16/9/3.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "LLQ_MianAVPlayerController.h"
#import "LLQ_AVPlayerView.h"

@interface LLQ_MianAVPlayerController (){

    UIButton * _playBtn;
}

@property (nonatomic, strong) LLQ_AVPlayerView * playerView ;

@end

@implementation LLQ_MianAVPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self congfigUI];
}

-(void)creatPlayerView{
    
    //http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8
    _playerView = [LLQ_AVPlayerView avPlayerViewWithUrl:[NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"]  height:250 playerSuperView:self.view];
    _playerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_playerView];
    __weak LLQ_MianAVPlayerController* weakSelf = self;
    
    [_playerView avPlaymakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(64);
        make.left.right.equalTo(weakSelf.view);
        make.height.equalTo(@(*(weakSelf.playerView->_playerHeight)));
    } interstitialBlock:^(MASConstraintMaker *make) {
        make.center.equalTo(Window);
        //由于是自己控制旋转  所以该出宽高赋值不同
        make.height.equalTo(@(SCREEN_WIDTH));
        make.width.equalTo(@(SCREEN_HEIGHT));
    }];
    
    [_playBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_playerView.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.view.mas_left).offset(20);
        make.width.equalTo(@(70));
        make.height.equalTo(@(30));
    }];
    
}


//创建播放器
-(void)playBtnAction{
    [self creatPlayerView];
}
//完全销毁播放器
-(void)entireDestoryBtnAction{
    [self.playerView destoryCustomPlayer];
    [self.playerView removeFromSuperview];
    self.playerView= nil;
    
    //配置原视图位置
    __weak LLQ_MianAVPlayerController* weakSelf = self;
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_top).offset(330);
        make.left.equalTo(weakSelf.view.mas_left).offset(20);
        make.width.equalTo(@(70));
        make.height.equalTo(@(30));
    }];
    
}

//暂时性销毁播放器 释放缓存 可以记录当前视频播放时间
-(void)tmpDestoryBtnAction{
    [self.playerView destoryCustomPlayer];
}
//重新播放
-(void)rePlayBtnAction{
    [self.playerView replay];
}

//销毁所有已穿件播放器
-(void)entireDestoryAllBtnAction{
    NSArray * arr = [self.view subviews];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LLQ_AVPlayerView class]]) {
            LLQ_AVPlayerView * tmpView = obj;
            [tmpView destoryCustomPlayer];
            [tmpView removeFromSuperview];
            tmpView = nil;
        }
        
    }];
    
}


//初见界面UI
-(void)congfigUI{
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    __weak LLQ_MianAVPlayerController* weakSelf = self;
    
    _playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_playBtn setTitle:@"创建播放器" forState:UIControlStateNormal];
    _playBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:_playBtn];
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_top).offset(330);
        make.left.equalTo(weakSelf.view.mas_left).offset(20);
        make.width.equalTo(@(70));
        make.height.equalTo(@(30));
    }];
    [_playBtn addTarget:self action:@selector(playBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * entireDestoryBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [entireDestoryBtn setTitle:@"完全销毁按钮" forState:UIControlStateNormal];
    [self.view addSubview:entireDestoryBtn];
    entireDestoryBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [entireDestoryBtn addTarget:self action:@selector(entireDestoryBtnAction) forControlEvents:UIControlEventTouchUpInside];

    [entireDestoryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_playBtn.mas_top);
        make.left.equalTo(_playBtn.mas_right).offset(10);
        make.width.equalTo(@(80));
        make.height.equalTo(@(30));
    }];
    
    UIButton * entireDestoryAllBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [entireDestoryAllBtn setTitle:@"销毁all播放器" forState:UIControlStateNormal];
    [self.view addSubview:entireDestoryAllBtn];
    entireDestoryAllBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [entireDestoryAllBtn addTarget:self action:@selector(entireDestoryAllBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [entireDestoryAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_playBtn.mas_top);
        make.left.equalTo(entireDestoryBtn.mas_right).offset(10);
        make.width.equalTo(@(85));
        make.height.equalTo(@(30));
    }];
    
    UIButton * tmpDestoryBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [tmpDestoryBtn setTitle:@"暂时性销毁" forState:UIControlStateNormal];
    tmpDestoryBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [tmpDestoryBtn addTarget:self action:@selector(tmpDestoryBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tmpDestoryBtn];
    [tmpDestoryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_playBtn.mas_bottom).offset(0);
        make.left.equalTo(weakSelf.view.mas_left).offset(20);
        make.width.equalTo(@(70));
        make.height.equalTo(@(30));
    }];
    
    UIButton * rePlayBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [rePlayBtn setTitle:@"重新播放" forState:UIControlStateNormal];
    rePlayBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [rePlayBtn addTarget:self action:@selector(rePlayBtnAction) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:rePlayBtn];
    [rePlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_playBtn.mas_bottom).offset(0);
        make.left.equalTo(tmpDestoryBtn.mas_right).offset(10);
        make.width.equalTo(@(70));
        make.height.equalTo(@(30));
    }];
    UITextView * textView = [UITextView new];
    textView.editable = NO;
    [self.view addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.top.equalTo(rePlayBtn.mas_bottom).offset(10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
    }];
    textView.text = @"实现了播放器的常规操作如，点击显示/隐藏控制栏,双击播放/暂停，水平滑动屏幕控制播放时间，滑动左侧屏幕控制亮度，全屏操作，屏幕旋转适配等功能。使用autolayout进行布局。\n另注：创建播放器按钮与完全销毁按钮，执行播放销毁操作。  暂时先销毁按钮会记录当前视频播放时间清除内存，节省空间，可以重新从上次销毁出继续播放视频。 另关于iPad中小窗口播放，可以进行小窗口播放 但是还存在一些问题如，开始画中画后需移除掉原来的视图层，会在后续时间内修复";
}


-(BOOL)shouldAutorotate{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
