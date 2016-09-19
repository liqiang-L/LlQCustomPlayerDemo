//
//  LLQ_AVPlayerView.m
//  LLQCustomAVPlayerDemo
//
//  Created by Apple on 16/9/3.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "LLQ_AVPlayerView.h"
#import "LLQ_AdjustBrightnessView.h"
#import "LLQ_TimeSheetView.h"


typedef NS_ENUM(NSInteger, LQLControlType){
    progressControl,            //进度条
    voiceControl,               //声音
    lightControl,               //音量
    noneControl = 999,          //无声息
    
};

@interface LLQ_AVPlayerView()<AVPictureInPictureControllerDelegate>{
    CGFloat _totalTime,_currentTime; //总时间和当前时间
    BOOL _isFirstPlay;               //是否是第一次播放
    BOOL _isFullScreen;              //是否是全屏状态
    BOOL _canFullScreen;             //是否可以全屏
    
    BOOL _controlJude;               //是否判断了touch的移动方向
    BOOL _hasMoved;
    CGPoint _touchBeginPoint;        //触摸起始点
    LQLControlType _controlType;     //touch控制类型
    
    float _touchBeginTime;          //记录触摸开始时的视频播放的时间
    
    NSTimer *_contrlStateViewTimer; //控制状态栏展示隐藏计时器
    
    float _destoryTime;              //记录播放器销毁时间
    BOOL  _isDestory;                //销毁记录
}
//xib中控件
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *palyButton;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *loadProgressView;
@property (weak, nonatomic) IBOutlet UISlider *controllSider;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;
@property (weak, nonatomic) IBOutlet UIView *touchView;

@property (assign, nonatomic) BOOL isSliderChanged;
/**
 *  播放项目资源 用于对视频的播放状态的控制
 */
@property (nonatomic, strong) AVPlayerItem * playerItem;

/**
 *  播放器内核
 */
@property (nonatomic, strong) AVPlayer * player;

/**
 *  用来监控播放时间的observer
 */
@property (nonatomic, strong) id timeObserver;

/**
 *  位置block
 */
@property (nonatomic, copy) LayoutBlock portraitBlock;

/**
 *  位置block
 */
@property (nonatomic, copy) LayoutBlock interstitialBlock;

/**
 *  画中画控制器
 */
@property (nonatomic, strong) AVPictureInPictureController * pipController;

/**
 *  亮度调节控制
 */
@property (nonatomic, strong) LLQ_AdjustBrightnessView* lightView;

/**
 *  当前亮度
 */
@property (nonatomic, assign) CGFloat currentBrightness;


@property (nonatomic, assign) LLQ_TimeSheetView * timeSheetView;

@end

@implementation LLQ_AVPlayerView


+(instancetype)avPlayerViewWithUrl:(NSURL*)playerUrl height:(CGFloat)height playerSuperView:(UIView*)playerSuperView{
    static float videoHeight = 0.0;
    videoHeight = height;
    NSArray * arr = [[NSBundle mainBundle] loadNibNamed:@"LLQ_AVPlayerView" owner:self options:nil];
    LLQ_AVPlayerView * playerView = arr.lastObject;
    playerView.playerUrl = playerUrl;
    playerView->_playerHeight = &videoHeight;
    playerView.playerSuperView = playerSuperView;
    
    return playerView;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

#pragma mark - 从xib唤醒视图 初始化 视图控制
-(void)awakeFromNib{
    
    _isDestory = NO;
    [self initAVPlayerData];
    [self initBrightnessView];
    [self initSliderController];
    [self addTapForPlayer];
}
//初始化播放器
-(void)initAVPlayerData{
    _isFirstPlay = YES;
    _isFullScreen = NO;
    _canFullScreen = NO;
    self.isPlaying = NO;
    self.isSliderChanged = NO;
    self.loadIndicator.hidden = YES;
    [self setViewUserInteractionEnabled:NO];
}
//初始化调节亮度视图 进度视图
-(void)initBrightnessView{
    _lightView = [[LLQ_AdjustBrightnessView alloc] init];
    [self addSubview:_lightView];
    _lightView.alpha = 0.0;
    __weak LLQ_AVPlayerView* weakSlef = self;
    
    [_lightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(130));
        make.center.equalTo(weakSlef);
    }];
    
    _timeSheetView = [[NSBundle mainBundle] loadNibNamed:@"LLQ_TimeSheetView" owner:self options:nil].lastObject;
    [self addSubview:_timeSheetView];
    _timeSheetView.hidden = YES;
    [_timeSheetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(120));
        make.height.equalTo(@(60));
        make.center.equalTo(weakSlef);
    }];
}
//添加点击双击手势
-(void)addTapForPlayer{
    UITapGestureRecognizer * tapDouble = [[UITapGestureRecognizer alloc] init];
    [tapDouble addTarget:self action:@selector(tapDoubleAction:)];
    tapDouble.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tapDouble];
}


//初始化slider
-(void)initSliderController{
    [self.controllSider setThumbImage:[UIImage imageNamed:@"iconfont-yuan1"] forState:UIControlStateNormal];
    [self.controllSider setThumbImage:[UIImage imageNamed:@"iconfont-yuan1"] forState:UIControlStateHighlighted];
    self.controllSider.maximumTrackTintColor = [UIColor clearColor];

}
//设置用户交互
-(void)setViewUserInteractionEnabled:(BOOL)enabled{
    self.userInteractionEnabled = YES;
    self.topView.userInteractionEnabled = enabled;
    self.controllSider.userInteractionEnabled = enabled;
    self.fullScreenButton.userInteractionEnabled = enabled;
    self.touchView.userInteractionEnabled = enabled;
}

#pragma mark   -------progressView进度
- (void) setloadProgressViewValue{
    //获取缓冲的时间
    NSArray * loadTimeRanges =  self.playerItem.loadedTimeRanges;
    CMTimeRange timeRange = [loadTimeRanges.firstObject CMTimeRangeValue];
    CGFloat startSeconds = CMTimeGetSeconds(timeRange.start);
    CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);
    CGFloat result = startSeconds + durationSeconds;
    self.loadProgressView.progress = result/_totalTime;
    
}
#pragma mark   -------点击隐藏状态栏 双击暂停或开始播放-------
-(void)tapDoubleAction:(UITapGestureRecognizer*)tapDouble{
    [self playerIsPlayOrPause];
}

//状态条展示并隐藏
-(void)controlTimeStateViewHidden{
    self.topView.hidden = NO;
    self.bottomView.hidden = NO;
    [self bringSubviewToFront:self.topView];
    [self bringSubviewToFront:self.bottomView];
    if ([UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    if (!_contrlStateViewTimer.valid) {
        _contrlStateViewTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(contrlStateViewHidden) userInfo:nil repeats:NO];
    }else{
        [_contrlStateViewTimer invalidate];
        _contrlStateViewTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(contrlStateViewHidden) userInfo:nil repeats:NO];
    }
    
}

//状态条隐藏
-(void)contrlStateViewHidden{
    self.topView.hidden = YES;
    self.bottomView.hidden = YES;
    if (_isFullScreen) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    [_contrlStateViewTimer invalidate];
}

#pragma mark -----并初始化播放器开始后部分功能操作-----
-(void)readyToPlay{
    //修改变量控制
    _isFirstPlay = NO;
    self.isPlaying = YES;
    _canFullScreen = YES;
    //初始化 画中画控制器
    [self initPicInPicViewController];
    //打开用户交互
    [self setViewUserInteractionEnabled:YES];
    //开启隐藏状态条
    [self controlTimeStateViewHidden];
    //准备播放获取时间并初始化部分视图 时间显示
    _totalTime = self.playerItem.duration.value/self.playerItem.duration.timescale;
    long long tmp = (long long)_totalTime;
    self.totalTimeLabel.text = calculateTimeWithTimeFormatter(tmp);
    NSInteger timeLength = self.totalTimeLabel.text.length;
    if (timeLength>5) {
        self.currentTimeLabel.text = @"00:00:00";
    }else{
        self.currentTimeLabel.text = @"00:00";
        
    }
    //设置滑块最大值
    self.controllSider.maximumValue = _totalTime;
    [self showLoadIndicator:NO];

    //添加时间监听
    __weak LLQ_AVPlayerView *weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:nil usingBlock:^(CMTime time) {
        long long tmpTime = time.value/time.timescale;
        NSString * tmpTimeStr = calculateTimeWithTimeFormatter(tmpTime);
        if (timeLength>5&&tmpTimeStr.length<=5) {
            weakSelf.currentTimeLabel.text = [NSString stringWithFormat:@"00:%@",tmpTimeStr];
        }else{
            weakSelf.currentTimeLabel.text = tmpTimeStr;
        }
        //设置时间 设置滑块
        if (!weakSelf.isSliderChanged) {
            [weakSelf.controllSider setValue:tmpTime animated:YES];
        }
    }];
    
}

#pragma mark - 用来显示时间的view在时间发生变化时所作的操作
-(void)timeValueChangingWithValue:(float)value{
    if (value > _touchBeginTime) {
        self.timeSheetView.stateImageView.image = [UIImage imageNamed:@"progress_icon_r"];
    }else if(value < _touchBeginTime){
        self.timeSheetView.stateImageView.image = [UIImage imageNamed:@"progress_icon_l"];
    }
    self.timeSheetView.hidden = NO;
    if(value<=0){
        value = 0;
    }else if(value>=_totalTime){
        value = _totalTime;
    }
    
    NSString * tempTime = calculateTimeWithTimeFormatter(value);
    if (tempTime.length > 5) {
        self.timeSheetView.timeLabel.text = [NSString stringWithFormat:@"00:%@/%@", tempTime, self.totalTimeLabel.text];
    }else{
        self.timeSheetView.timeLabel.text = [NSString stringWithFormat:@"%@/%@", tempTime, self.totalTimeLabel.text];
    }
}


#pragma mark - 用来控制显示亮度的view
-(void)hideTheLightViewWithHidden:(BOOL)hidden{
    if (hidden) {
        [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.lightView.alpha = 0.0;
        } completion:nil];
        
    }else{
        self.lightView.alpha = 1.0;
    }
}

//初始化 画中画控制器
- (void)initPicInPicViewController{
    _pipController = [[AVPictureInPictureController alloc] initWithPlayerLayer:(AVPlayerLayer*)self.layer];
    _pipController.delegate = self;
}
#pragma makrk ---------------xib视图点击事件----------
- (IBAction)touchSliderAction:(id)sender {
    self.isSliderChanged = YES;
}

- (IBAction)sliderValueChanged:(id)sender {
    [self seekToTimeValue:self.controllSider.value];
    self.isSliderChanged = NO;
    [self controlTimeStateViewHidden];
}

//小窗口播放 画中画模式
- (IBAction)multiTaskingAction:(id)sender {
    [self.pipController startPictureInPicture];
    if ([AVPictureInPictureController isPictureInPictureSupported]) {
        if (self.pipController.pictureInPicturePossible) {
        }else{
            NSLog(@"画中画不可用");
        }
    }else{
        NSLog(@"画中画不支持");
    }
    
}

- (IBAction)playOrPauseBtnAction:(id)sender {
    [self playerIsPlayOrPause];
}

- (void)playerIsPlayOrPause{
    if (self.isPlaying) {
        [self.player pause];
        self.isPlaying = NO;
        [self.palyButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }else{
        [self.player play];
        self.isPlaying = YES;
        _canFullScreen = _isPlaying;
        [self.palyButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        if (_isFirstPlay) {
            [self showLoadIndicator:YES];
        }
    }
}


#pragma mark -----------------touch事件------------
#pragma mark - 用touch这几个方法来判断, 是进度控制 . 音量控制. 还是亮度控制, 并作出相应的计算
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{   //触摸开始
    //这个是用来判断, 如果有多个手指点击则不做出响应
    UITouch * touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1 || event.allTouches.count > 1) {
        return;
    }
    //这个是用来判断, 手指点击的是不是本视图, 如果不是则不做出响应
    if (![[(UITouch *)touches.anyObject view] isEqual:self.touchView] &&  ![[(UITouch *)touches.anyObject view] isEqual:self.touchView]) {
        return;
    }
    [super touchesBegan:touches withEvent:event];
    _controlJude = NO;
    self.currentBrightness = [UIScreen mainScreen].brightness;
    _touchBeginTime = self.controllSider.value;
    _touchBeginPoint = [touches.anyObject locationInView:self.touchView];
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    UITouch * touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1  || event.allTouches.count > 1) {
        return;
    }
    if (![[(UITouch *)touches.anyObject view] isEqual:self.touchView] && ![[(UITouch *)touches.anyObject view] isEqual:self.touchView]) {
        return;
    }
    [super touchesMoved:touches withEvent:event];
    
    //如果移动的距离过于小, 就判断为没有移动
    CGPoint tempPoint = [touches.anyObject locationInView:self.touchView];
    if (fabs(tempPoint.x - _touchBeginPoint.x) < LeastMoveDistance && fabs(tempPoint.y - _touchBeginPoint.y) < LeastMoveDistance) {
        return;
    }
    
    _hasMoved = YES;
    if (!_controlJude) {
        float tan = fabs(tempPoint.y - _touchBeginPoint.y)/fabs(tempPoint.x - _touchBeginPoint.x);
        if(tan<fabs(tanf(30))){//当滑动角度小于30度的时候, 进度手势
            _controlType = progressControl;
        }else if (tan > tanf(60)){//当滑动角度大于60度的时候, 声音和亮度
            //判断是在屏幕的左半边还是右半边滑动, 左侧控制为亮度, 右侧控制音量
            if (_touchBeginPoint.x < self.touchView.bounds.size.width/2) {
                _controlType = lightControl;
            }else{
                _controlType = voiceControl;
            }
        }else{
            _controlType = noneControl;
            return;
        }
        
    }
    
    switch (_controlType) {
        case progressControl:{
            float tmpValue = self.controllSider.value + (tempPoint.x - _touchBeginPoint.x)/self.touchView.bounds.size.width*TotalScreenTime;
            [self timeValueChangingWithValue:tmpValue];
            break;
        }
        case lightControl:{
            float tmpValue = self.currentBrightness - (tempPoint.y-_touchBeginPoint.y)/self.touchView.bounds.size.height;
            if (tmpValue<0) {
                tmpValue = 0;
            }else if(tmpValue>1){
                tmpValue = 1;
            }
            [self hideTheLightViewWithHidden:NO];
            [self bringSubviewToFront:self.lightView];
            [self.lightView changeLightViewWithValue:tmpValue];
            [[UIScreen mainScreen] setBrightness:tmpValue];
            break;
        }
        case voiceControl:{
            CGFloat _touchBeginVoiceValue;
            float voiceValue = _touchBeginVoiceValue - ((tempPoint.y - _touchBeginPoint.y)/self.touchView.bounds.size.height);
            break;
        }
        default:
            break;
    }
    
    
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    CGPoint tempPoint = [[touches anyObject] locationInView:self.touchView];
    if (_hasMoved) {
        switch (_controlType) {
            case progressControl:{
                float tmpValue = self.controllSider.value + (tempPoint.x - _touchBeginPoint.x)/self.touchView.bounds.size.width*TotalScreenTime;
                self.controllSider.value = tmpValue;
                CMTime cTime = CMTimeMake(tmpValue, 1);
                [self.player pause];
                __weak LLQ_AVPlayerView * weakSelf = self;
                [self.player seekToTime:cTime completionHandler:^(BOOL finished) {
                    if (weakSelf.isPlaying) {
                        [weakSelf.player play];
                    }
                }];
                break;
            }
            case lightControl:{
                [self hideTheLightViewWithHidden:YES];
                break;
            }
            default:
                break;
        }
        [self hideTheLightViewWithHidden:YES];
        self.timeSheetView.hidden = YES;

    }else{
        if (self.topView.hidden) {
            [self controlTimeStateViewHidden];
        }else{
            [self contrlStateViewHidden];
        }
    }

}


#pragma mark -------位置操作---------------------------
#pragma mark -------屏幕旋转及全屏处理-------------------

- (NSArray *)avPlaymakeConstraints:(LayoutBlock)portraitBlock interstitialBlock:(LayoutBlock)interstitialBlock{
    
    self.portraitBlock = portraitBlock;
    self.interstitialBlock = interstitialBlock;
    
    //开始播放
    [self.player play];
    
    return  [self mas_makeConstraints:portraitBlock];
    
}

//退出全屏
- (IBAction)exitFullScreenAction:(id)sender {
    if (_isFullScreen) {
        _isFullScreen = NO;
        [self playerViewOrientation:UIInterfaceOrientationPortrait];
    }else{
        [self playerViewOrientation:UIInterfaceOrientationLandscapeRight];
        _isFullScreen = YES;
    }
    [self controlTimeStateViewHidden];
}

//退出全屏或全屏播放
- (IBAction)exitOrInFullScreenBtnAction:(id)sender {
    if (_isFullScreen) {
        _isFullScreen = NO;
        [self playerViewOrientation:UIInterfaceOrientationPortrait];
    }else{
        [self playerViewOrientation:UIInterfaceOrientationLandscapeRight];
        _isFullScreen = YES;
    }
    [self controlTimeStateViewHidden];

}
//监听屏幕旋转处理方法
-(void)orientationChange:(NSNotification*)notification{
    
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
    switch (orient) {
        case UIDeviceOrientationPortrait:{
            [self playerViewOrientation:UIInterfaceOrientationPortrait];
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown:{
            [self playerViewOrientation:UIInterfaceOrientationPortraitUpsideDown];
            break;
        }
        case UIDeviceOrientationLandscapeLeft:{
                [self playerViewOrientation:UIInterfaceOrientationLandscapeRight ];
        }
            break;
        case UIDeviceOrientationLandscapeRight:{
                [self playerViewOrientation:UIInterfaceOrientationLandscapeLeft];
            break;
        }
        default:
            break;
    }
    
}
//根据屏幕旋转设置播放器位置大小
-(void)playerViewOrientation:(UIInterfaceOrientation)orientation{
    if ((!_canFullScreen)||orientation == UIDeviceOrientationUnknown) {
        return;
    }
    UIInterfaceOrientation currentOrient = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait|| orientation==
        UIInterfaceOrientationPortraitUpsideDown) {
        _isFullScreen = NO;
        [self removeFromSuperview];
        [self.playerSuperView addSubview:self];
        [self mas_remakeConstraints:self.portraitBlock];
        _isFullScreen = NO;
    }else{
        
        if (IsIpad) {
            _isFullScreen = YES;
            [self removeFromSuperview];
            [Window addSubview:self];
            [self mas_remakeConstraints:self.interstitialBlock];

        }else{
            if(currentOrient == UIInterfaceOrientationPortrait || currentOrient == UIInterfaceOrientationPortraitUpsideDown){
                _isFullScreen = YES;
                [self removeFromSuperview];
                [Window addSubview:self];
                [self mas_remakeConstraints:self.interstitialBlock];
            }
        }
        
    }
    
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:YES];
    
    [UIView beginAnimations:nil context:nil];
    //旋转视频播放的view和显示亮度的view
    self.transform = [self getTransformOrientation:orientation];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
}

//根据状态条旋转的方向来旋转 avplayerView
-(CGAffineTransform)getTransformOrientation:(UIInterfaceOrientation)orientation{
    if (IsIpad) {
        return CGAffineTransformIdentity;
    }
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    }else if (orientation ==  UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    }else if(orientation == UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

#pragma mark -----------------------------------------
#pragma mark ----------视频的监听状态并处理--------------
#pragma mark -----------------------------------------

//视频的监听部v分
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {        //获取到视频信息的状态, 成功就可以进行播放, 失败代表加载失败
        //AVPlayerItemStatusUnknown, AVPlayerItemStatusReadyToPlay , AVPlayerItemStatusFailed
        if(self.playerItem.status == AVPlayerItemStatusReadyToPlay){
            //视频缓存好播放
            [self readyToPlay];
            if (_isDestory) {
                [self seekToTimeValue:_destoryTime];
                _isDestory = NO;
            }
            
        }else if(self.playerItem.status == AVPlayerItemStatusFailed){
            NSLog(@"AVPlayerItemStatusFailed： 视频加载失败 %@",self.playerItem.error);
        }else if(self.playerItem.status == AVPlayerItemStatusUnknown){   //未知错误
            NSLog(@"AVPlayerItemStatusUnknown：未知错误！");
        }
        
    } else if([keyPath isEqualToString:@"loadedTimeRanges"]){   //当缓冲进度有变化的时候
        [self setloadProgressViewValue];
        
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){ //当视频播放因为各种状态播放停止的时候, 这个属性会发生变化

    }else if([keyPath isEqualToString:@"playbackBufferEmpty"]){  //当没有任何缓冲部分可以播放的时候
        NSLog(@"playbackBufferEmpty");
        if (self.pipController && self.pipController.pictureInPictureActive) {
            _isPlaying = YES;
            [self playerIsPlayOrPause];
        }else{
            if (self.isPlaying) {
                [self.player play];
            }
        }
        
        [self showLoadIndicator:YES];
    }else if ([keyPath isEqualToString:@"playbackBufferFull"]){
        NSLog(@"playbackBufferFull: change : %@", change);
    }else if([keyPath isEqualToString:@"presentationSize"]){      //获取到视频可视部分大小
        if (!_isFullScreen) { //重新设置播放器大小
            CGSize size = self.playerItem.presentationSize;
            static float staticHeight = 0;
            staticHeight = size.height/size.width * SCREEN_WIDTH;
            self->_playerHeight  = &(staticHeight);
            [self mas_remakeConstraints:self.portraitBlock];
        }
        //用来监测屏幕旋转
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        _canFullScreen = YES;
        
    }
}
#pragma makr ------------播放器处理具体操作
//设置播放时间
- (void)seekToTimeValue:(CGFloat)timeValue;{
    
    [self showLoadIndicator:YES];
    if (timeValue<=0) {
        timeValue=1;
    }
    CMTime cTime = CMTimeMake(timeValue, 1);
    [self.player pause];
    __weak LLQ_AVPlayerView * weakSelf = self;
    [self.player seekToTime:cTime completionHandler:^(BOOL finished) {
        if (weakSelf.isPlaying) {
            [weakSelf.player play];
        }
        [weakSelf showLoadIndicator:NO];
    }];
}

//视频播放结束
- (void)moviePlayEnd:(NSNotification*)notification{
    [self seekToTimeValue:0.0];
    [self.player pause];
    _isPlaying = NO;
    [self.palyButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}


#pragma mark ------------player项懒加载
- (AVPlayerItem*)playerItem{
    if (_playerItem==nil) {
        _playerItem = [AVPlayerItem playerItemWithURL:_playerUrl];
        [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_playerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_playerItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

    }
    return _playerItem;
}

-(AVPlayer*)player{
    if (_player == nil) {
        _player = [AVPlayer playerWithPlayerItem:self.playerItem];
        _player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
        [(AVPlayerLayer*)self.layer setPlayer:_player];
    }
    return _player;
}

-(UIActivityIndicatorView*)loadIndicator{
    
    if (_loadIndicator == nil) {
        }
    _loadIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
    return _loadIndicator;
}

#pragma mark - 用来将layer转为AVPlayerLayer, 必须实现的方法, 否则会崩
+(Class)layerClass{
    return [AVPlayerLayer class];
}


/**
 *  加载状态
 *
 *  @param animated
 */
-(void)showLoadIndicator:(BOOL)animated{
    if (animated) {
        [self bringSubviewToFront:self.loadIndicator];
        self.loadIndicator.hidden = NO;
        [self.loadIndicator startAnimating];
    }else{
        self.loadIndicator.hidden = YES;
        [self.loadIndicator stopAnimating];
    }
}

#pragma mark -----------AVPictureInPictureDelegate------------

- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    NSLog(@"WillStartPictureInPicture");
    
}
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    NSLog(@"DidStartPictureInPicture");
    //调用代理的diss方法 [self dismissViewControllerAnimated:YES completion:nil];
//    [self viewController].view.hidden = YES;
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error{
    NSLog(@"ailedToStartPictureInPicture");
    
}
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    NSLog(@"WillStopPictureInPicture");

}
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    NSLog(@"DidStopPictureInPicture");
    for (UIView *view in self.subviews) {
        [self bringSubviewToFront:view];
    }
}
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler{
    
}

#pragma mark -------------------销毁播放器------------------
#pragma mark  ------------------destory操作--------------------
//重新播放
-(void)replay{
    //初始化播放器
    [self initAVPlayerData];
    [self.player play];
}

-(void)destoryCustomPlayer{
    
    //记录播放器时间销毁时间
    _destoryTime = self.playerItem.currentTime.value/self.playerItem.currentTime.timescale;
    _isDestory = YES;
    self.loadProgressView.progress = 0;
    if (_contrlStateViewTimer && _contrlStateViewTimer.valid) {
        [_contrlStateViewTimer invalidate];
        _contrlStateViewTimer = nil;
    }
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
        [_playerItem removeObserver:self forKeyPath:@"presentationSize"];

    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self];

    if (_timeObserver) {
        [_player removeTimeObserver:self.timeObserver];
        _timeObserver = nil;
    }
    [(AVPlayerLayer*)self.layer setPlayer:nil];
    _player = nil;
    _playerItem = nil;
    
}

- (void)dealloc
{
    [self destoryCustomPlayer];
}

@end
