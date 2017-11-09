//
//  YYCalendarView.h
//  YYProject
//
//  Created by HZYL_FM3 on 17/5/2.
//  Copyright © 2017年 HZYL_FM3. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface YYCalendarView : UIView

//data:
@property (nonatomic, assign) BOOL showStatus;          //是否显示day上面的状态按钮
@property (nonatomic, assign) NSInteger everydayM;      //每天签到的赏金数
@property (nonatomic, assign) NSInteger successionM;    //连续签到的赏金数
@property (nonatomic, assign) NSInteger successionDays; //连续签到天数
@property (nonatomic, strong) NSMutableArray *signDays; //已签到的日期列表（@[@"yyyy-MM-dd"]）

//block:
@property (nonatomic, copy) void(^yyClickDayViewWithDay)(NSString *day);//某一天的点击事件
@property (nonatomic, copy) void(^yyDateViewYearChanged)(NSString *year);//年份发生变化
@property (nonatomic, copy) void(^yyDateViewMonthChanged)(NSString *month);//月份发生变化

@end
