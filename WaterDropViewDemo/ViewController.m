//
//  ViewController.m
//  WaterDropViewDemo
//
//  Created by Pandara on 15/11/23.
//  Copyright © 2015年 Pandara. All rights reserved.
//

#import "ViewController.h"
#import "Define.h"
#import "WaterDropView.h"

@interface ViewController () {
    BOOL _hasPlay;
}

@property (strong, nonatomic) NSMutableArray *viewArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = color(28, 163, 252, 1);
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60.0f, self.view.frame.size.width, 60.0f)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    self.viewArray = [[NSMutableArray alloc] init];
    
    int count = 5;
    CGFloat margin = 120.0f;
    
    for (int i = 0; i < count; i++) {
        WaterDropView *waterDropView = [[WaterDropView alloc] initWithFrame:CGRectMake(margin + i * ((self.view.frame.size.width - margin * 2) / count), 0, 50, self.view.frame.size.height)];
        [self.view addSubview:waterDropView];
        [self.viewArray addObject:waterDropView];
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_hasPlay) {
        return;
    }
    
    _hasPlay = YES;
    
    for (int i = 0; i < [self.viewArray count]; i++) {
        WaterDropView *view = [self.viewArray objectAtIndex:i];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [view play];
        });
    }
    
}

@end
