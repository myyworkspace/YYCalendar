//
//  ViewController.m
//  YYCalendar
//
//  Created by HZYL_FM3 on 2017/11/9.
//  Copyright © 2017年 HZYL_FM3. All rights reserved.
//

#import "ViewController.h"
#import "YYCalendarView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.\]
    
    YYCalendarView *calendarView = [[YYCalendarView alloc] initWithFrame:CGRectMake(15.0, 15.0, self.view.frame.size.width-15.0*2, 500.0)];
    calendarView.showStatus = YES;
    calendarView.everydayM = 1;
    calendarView.successionM = 5;
    calendarView.successionDays = 5;
    calendarView.signDays = [NSMutableArray arrayWithObjects:@"2017-11-01",@"2017-11-02",@"2017-11-03",@"2017-11-04",@"2017-11-05", nil];
    [self.view addSubview:calendarView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
