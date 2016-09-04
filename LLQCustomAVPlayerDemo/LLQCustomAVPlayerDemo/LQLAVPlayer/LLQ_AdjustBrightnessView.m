//
//  LLQ_AdjustBrightnessView.m
//  LLQCustomAVPlayerDemo
//
//  Created by Apple on 16/9/4.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "LLQ_AdjustBrightnessView.h"
#import "UIView+Extent.h"

#define LIGHT_VIEW_COUNT 16
@interface LLQ_AdjustBrightnessView (){
    UIView * _balckView;
}
@property (nonatomic,strong) NSMutableArray * lightViewArr;

@end

@implementation LLQ_AdjustBrightnessView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configUI];
    }
    return self;
}

-(void)configUI{
    _lightViewArr = [[NSMutableArray alloc] init];
    self.layer.cornerRadius = 10.0;
    self.backgroundColor = [UIColor colorWithRed:167/255.0 green:167/255.0 blue:167/255.0 alpha:1];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playbrightnessday"]];
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(imageView.mas_width).multipliedBy(1);
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(20, 20, 20, 20));
    }];
    _balckView = [[UIView alloc] init];
    [self addSubview:_balckView];
    _balckView.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:67.0/255.0 blue:70.0/255.0 alpha:1.0];
    [_balckView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(-10);
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.height.equalTo(@(10));
    }];
    
    
    
}
-(void)changeLightViewWithValue:(float)lightValue{
    
    if(self.lightViewArr.count <= 0){
        for (int i = 0; i < LIGHT_VIEW_COUNT; ++i) {
            UIView * view = [[UIView alloc] init];
            view.backgroundColor = [UIColor yellowColor];
            [self.lightViewArr addObject:view];
            [_balckView addSubview:view];
            
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_balckView).offset(1);
                make.bottom.equalTo(_balckView).offset(-1);
            }];
        }
        [_balckView distributeSpacingHorizontally1With:self.lightViewArr];
    }
    
    
    NSInteger allCount = self.lightViewArr.count;
    NSInteger lightCount = lightValue * allCount;
    for (int i = 0; i < allCount; ++i) {
        UIView * view = self.lightViewArr[i];
        if (i < lightCount) {
            view.backgroundColor = [UIColor whiteColor];
            view.alpha = 0.5;
        }else{
            view.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:67.0/255.0 blue:70.0/255.0 alpha:1.0];
        }
    }
    
}


@end
