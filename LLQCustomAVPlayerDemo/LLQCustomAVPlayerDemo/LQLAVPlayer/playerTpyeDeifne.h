//
//  playerTpyeDeifne.h
//  LLQCustomAVPlayerDemo
//
//  Created by Apple on 16/9/4.
//  Copyright © 2016年 Apple. All rights reserved.
//

#ifndef playerTpyeDeifne_h
#define playerTpyeDeifne_h

//整个屏幕代表的时间
#define TotalScreenTime 90
//最小移动距离
#define LeastMoveDistance 15


#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT    [UIScreen mainScreen].bounds.size.height
//判断是否为ipad设备
#define IsIpad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

//获取到window
#define Window [[UIApplication sharedApplication].delegate window]

#endif /* playerTpyeDeifne_h */
