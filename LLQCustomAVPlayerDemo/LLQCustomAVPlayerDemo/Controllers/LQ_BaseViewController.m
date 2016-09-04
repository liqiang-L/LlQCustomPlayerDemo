//
//  LQ_BaseViewController.m
//  LLQTestFunctionProduct
//
//  Created by Liliqiang on 16/4/16.
//  Copyright © 2016年 liliqiang. All rights reserved.
//

#import "LQ_BaseViewController.h"
#import "playerTpyeDeifne.h"

@interface LQ_BaseViewController ()


@end

@implementation LQ_BaseViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
