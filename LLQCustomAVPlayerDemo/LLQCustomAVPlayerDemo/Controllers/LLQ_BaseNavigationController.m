//
//  LLQ_BaseNavigationController.m
//  LLQCustomAVPlayerDemo
//
//  Created by Apple on 16/9/4.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "LLQ_BaseNavigationController.h"
#import "playerTpyeDeifne.h"

@interface LLQ_BaseNavigationController ()

@end

@implementation LLQ_BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(BOOL)shouldAutorotate{
    
    return [self.topViewController shouldAutorotate];
        
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
