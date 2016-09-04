//
//  UIView+Extent.h
//  LLQCustomAVPlayerDemo
//
//  Created by Apple on 16/9/4.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extent)

/**
 *  获取当前UIView的控制器
 *
 *  @return <#return value description#>
 */
- (UIViewController*)viewController;

/**
 *  使用Masonry水平平均布局视图
 *
 *  @param views <#views description#>
 */
- (void) distributeSpacingHorizontallyWith:(NSArray*)views;

//均衡布局
- (void) distributeSpacingHorizontally1With:(NSArray*)views;



/**
 *  垂直布局
 *
 *  @param views <#views description#>
 */
- (void) distributeSpacingVerticallyWith:(NSArray*)views;

@end
