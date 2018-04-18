//
//  ViewController.m
//  事件传递和响应机制
//
//  Created by LGQ on 2018/4/17.
//  Copyright © 2018年 LGQ. All rights reserved.
//

#import "ViewController.h"
#import "GGTouchView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    GGTouchView *touchView1 = [[GGTouchView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    touchView1.backgroundColor = [UIColor greenColor];
    [self.view addSubview:touchView1];
    
    GGTouchView *touchView2 = [[GGTouchView alloc] initWithFrame:CGRectMake(100, 400, 200, 200)];
    [touchView2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchView2Click)]];
    touchView2.backgroundColor = [UIColor redColor];
    [self.view addSubview:touchView2];
    
    GGTouchView *subView = [[GGTouchView alloc] initWithFrame:CGRectMake(10, 0, 100, 100)];
    [subView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(subViewClick)]];
    subView.backgroundColor = [UIColor blueColor];
    [touchView2 addSubview:subView];
    
}

- (void)subViewClick {
    NSLog(@"%s", __func__);
}

- (void)touchView2Click {
    NSLog(@"%s", __func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
