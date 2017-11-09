//
//  YYCalendarView.m
//  YYProject
//
//  Created by HZYL_FM3 on 17/5/2.
//  Copyright © 2017年 HZYL_FM3. All rights reserved.
//

#import "YYCalendarView.h"
#import "YYDayView.h"

#define WEEKDAY @{@"Sun": @"日",@"Mon": @"一",@"Tue": @"二",@"Wed": @"三",@"Thu": @"四",@"Fri": @"五",@"Sat": @"六"}

#define RGB(r,g,b,A) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:A]

#define COLOR_TITLE RGB(153,153,153,1.0) //标题颜色
#define COLOR_WEEK  RGB(204,204,204,1.0) //周几颜色

@interface YYCalendarView ()

@property (nonatomic, strong) UIButton *preMonBtn; //上一月
@property (nonatomic, strong) UIButton *nextMonBtn;//下一月
@property (nonatomic, strong) UILabel *titleLabel; //当前时间

@property (nonatomic, strong) UIView *currDayView;
@property (nonatomic, strong) UIView *nextDayView;
@property (nonatomic, strong) UIView *preDayView;

@property (nonatomic, assign) int showYear;
@property (nonatomic, assign) int showMon;

@end

@implementation YYCalendarView

#pragma mark - private

- (UIView *)preDayView
{
    if (_preDayView == nil) {
        _preDayView = [[UIView alloc] initWithFrame:CGRectMake(-CGRectGetWidth(self.frame),
                                                               CGRectGetMaxY(self.preMonBtn.frame)+20.0,
                                                               CGRectGetWidth(self.frame),
                                                               CGRectGetHeight(self.frame)-CGRectGetMaxY(self.preMonBtn.frame)-20.0)];
        [self addSubview:_preDayView];
    }
    return _preDayView;
}

- (UIView *)currDayView
{
    if (_currDayView == nil) {
        _currDayView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                CGRectGetMaxY(self.preMonBtn.frame)+20.0,
                                                                CGRectGetWidth(self.frame),
                                                                CGRectGetHeight(self.frame)-CGRectGetMaxY(self.preMonBtn.frame)-20.0)];
        [self addSubview:_currDayView];
    }
    return _currDayView;
}

- (UIView *)nextDayView
{
    if (_nextDayView == nil) {
        _nextDayView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame),
                                                                CGRectGetMaxY(self.preMonBtn.frame)+20.0,
                                                                CGRectGetWidth(self.frame),
                                                                CGRectGetHeight(self.frame)-CGRectGetMaxY(self.preMonBtn.frame)-20.0)];
        [self addSubview:_nextDayView];
    }
    return _nextDayView;
}

//设置已签到数组（重新加载dayView）
- (void)setSignDays:(NSMutableArray *)signDays
{
    _signDays = signDays;
    [self loadDayView];
}

#pragma mark - setup

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.0;
        self.clipsToBounds = YES;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width-150)/2+CGRectGetMaxX(self.preMonBtn.frame), 20.0, 150.0, 20.0)];
        titleLabel.textColor = COLOR_TITLE;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM"];
        self.titleLabel.text = [dateFormatter stringFromDate:[NSDate date]];
        
        UIButton *preMonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        preMonBtn.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame)-20.0, 20.0, 20.0, 20.0);
        [preMonBtn setImage:[UIImage imageNamed:@"icon_qian"] forState:UIControlStateNormal];
        [preMonBtn addTarget:self action:@selector(preMonthAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:preMonBtn];
        self.preMonBtn = preMonBtn;
        
        UIButton *nextMonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        nextMonBtn.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame), 20.0, 20.0, 20.0);
        [nextMonBtn setImage:[UIImage imageNamed:@"icon_hou"] forState:UIControlStateNormal];
        [nextMonBtn addTarget:self action:@selector(nextMonthAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:nextMonBtn];
        self.nextMonBtn = nextMonBtn;
        
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextMonthAction:)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeLeft];

        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(preMonthAction:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeRight];
        
        [self loadDayView];
    
    }
    return self;
}

- (void)loadDayView
{
    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
    [yearFormatter setDateFormat:@"yyyy"];
    
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    [monthFormatter setDateFormat:@"MM"];
    
    self.showYear = [[yearFormatter stringFromDate:[NSDate date]] intValue];
    self.showMon = [[monthFormatter stringFromDate:[NSDate date]] intValue];
    
    int nextMon = (self.showMon+1) > 12 ? 1 : (self.showMon+1);
    int nextYear = (self.showMon+1) > 12 ? (self.showYear+1) : self.showYear;
    
    int preMon = (self.showMon-1) > 0 ? (self.showMon-1) : 12;
    int preYear = (self.showMon-1) > 0 ? self.showYear : (self.showYear-1);
    
    
    /*
     *
     *默认加载上一个月、当前月、下一个月3个月的日期（预加载）
     *
     */
    [self buildDayViewForDayView:self.preDayView
                            Year:preYear
                           month:preMon];
    
    [self buildDayViewForDayView:self.currDayView
                            Year:self.showYear
                           month:self.showMon];
    
    [self buildDayViewForDayView:self.nextDayView
                            Year:nextYear
                           month:nextMon];
}


- (void)buildDayViewForDayView:(UIView *)dayView
                          Year:(int)year
                      month:(int)month
{
    for (UIView *subView in dayView.subviews) {
        [subView removeFromSuperview];
    }
    
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
    [yearFormatter setDateFormat:@"yyyy"];
    
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    [monthFormatter setDateFormat:@"MM"];
    
    NSDateFormatter *weekFormatter = [[NSDateFormatter alloc] init];
    [weekFormatter setDateFormat:@"EEE"];
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"dd"];
    
    NSString *currentYear = [yearFormatter stringFromDate:date];
    if (year > 0) {
        currentYear = [NSString stringWithFormat:@"%d",year];
    }
    
    NSString *currentMon = [monthFormatter stringFromDate:date];
    if (month > 0) {
        currentMon = [NSString stringWithFormat:@"%d",month];
    }

    
    //周几:
    NSArray *weekList = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    CGFloat edge = 10.0;
    CGFloat weekX = edge;
    CGFloat weekY = 0.0;
    CGFloat weekW = (dayView.frame.size.width - (weekList.count+1)*edge) / weekList.count;
    CGFloat weekH = 20.0;
    
    CGFloat dayX = edge;
    CGFloat dayY = weekY + weekH + 20.0;
    CGFloat dayW = weekW;
    CGFloat dayH = weekH;
    
    //取得当月的第一天，并且取得第一天是星期几
    NSString *beginDayStr = [self beginDayFordate:[NSString stringWithFormat:@"%@-%@",currentYear,currentMon]];
    NSDate *beginDay = [dateFormatter dateFromString:beginDayStr];
    NSString *beginWeekDay = [weekFormatter stringFromDate:beginDay];

    int beginDay_index = 0;
    for (int i = 0; i < weekList.count; i++) {
        UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(weekX, weekY, weekW, weekH)];
        weekLabel.text = [weekList objectAtIndex:i];
        weekLabel.backgroundColor = [UIColor clearColor];
        weekLabel.textColor = COLOR_WEEK;
        weekLabel.textAlignment = NSTextAlignmentCenter;
        weekLabel.font = [UIFont systemFontOfSize:11.0];
        [dayView addSubview:weekLabel];
        
        if ([[WEEKDAY objectForKey:beginWeekDay] isEqualToString:[weekList objectAtIndex:i]]) {
            dayX = weekLabel.frame.origin.x;
            beginDay_index = i;
        }
        
        weekX = CGRectGetMaxX(weekLabel.frame);
        weekX += edge;
    }
    
    //根据当月的最后一天取得当月总共天数，然后计算出每行的高度
    NSString *endDayStr = [self endDayFordate:[NSString stringWithFormat:@"%@-%@",currentYear,currentMon]];
    NSDate *endDate = [dateFormatter dateFromString:endDayStr];
    NSString *endDay = [dayFormatter stringFromDate:endDate];
    int allDaysForMonth = [endDay intValue];
    int remainDays = allDaysForMonth - (7 - beginDay_index);//除了第一行显示的天数
    int rows = (remainDays%7 == 0 ? remainDays/7 : remainDays/7+1)+1;//总共的行数
    dayH = (dayView.frame.size.height - weekY - weekH - (rows+1)*edge) / (rows);
    
    //day:
    NSDate *inputDate = beginDay;
    while ([[monthFormatter stringFromDate:inputDate] intValue] == [currentMon intValue]) {
        
        //是否已签到:
        BOOL isSignIn = NO;
        NSString *statusStr = @"未签";
        if ([_signDays containsObject:[dateFormatter stringFromDate:inputDate]]) {
            isSignIn = YES;
            if ([self isSuccessionSignIn:[dateFormatter stringFromDate:inputDate]]) {
                //满足连续签到天数
                statusStr = [NSString stringWithFormat:@"+%ld",(long)self.successionM];
            }
            else
            {
                statusStr = [NSString stringWithFormat:@"+%ld",(long)self.everydayM];
            }
        }
        YYDayView *day;
        if (self.showStatus) {
            day = [[YYDayView alloc] initWithFrame:CGRectMake(dayX, dayY, dayW, dayH)
                                                         Year:[NSString stringWithFormat:@"%d",year]
                                                        Month:[NSString stringWithFormat:@"%d",month]
                                                          Day:[dayFormatter stringFromDate:inputDate]
                                                       SingIn:isSignIn
                                                    StatusStr:statusStr];
        }
        else
        {
            day = [[YYDayView alloc] initWithFrame:CGRectMake(dayX, dayY, dayW, dayH) Day:[dayFormatter stringFromDate:inputDate]];
        }
        day.yyClickDayView = ^(NSString *dayStr) {
            if (self.yyClickDayViewWithDay) {
                self.yyClickDayViewWithDay(dayStr);
            }
        };
        [dayView addSubview:day];
        
        
        NSString *week = [WEEKDAY objectForKey:[weekFormatter stringFromDate:inputDate]];
        if ([week isEqualToString:[weekList lastObject]]) {
            dayX = edge;
            dayY = CGRectGetMaxY(day.frame);
            dayY += edge;
        }
        else
        {
            dayX = CGRectGetMaxX(day.frame);
            dayX += edge;
        }
        
        //计算下一天:
        inputDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:inputDate];
    }
}

//是否满足连续签到天数
- (BOOL)isSuccessionSignIn:(NSString *)dateStr
{
    if (_signDays == nil || _signDays.count == 0 || _signDays.count < self.successionDays) {
        return NO;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:dateStr];
    
    int index = 0;
    for (int i=0; i < self.successionDays-1; i++) {
        NSDate *preDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];//计算上一天
        NSString *preDateStr = [formatter stringFromDate:preDate];
        
        if ([_signDays containsObject:preDateStr]) {
            index++;
        }
        else
        {
            return NO;
        }
        date = [formatter dateFromString:preDateStr];
    }
    
    if (index >= self.successionDays-1) {
        return YES;
    }
    return NO;
}

#pragma mark - action
#pragma mark 查看上一月
- (void)preMonthAction:(id)sender
{
    self.preMonBtn.enabled = NO;
    self.showMon -= 1;
    if (self.showMon == 0) {
        self.showYear -= 1;
        self.showMon = 12;
        
        if (self.yyDateViewYearChanged) {
            self.yyDateViewYearChanged([NSString stringWithFormat:@"%d",self.showYear]);
        }
    }

    CGRect curFrame = self.currDayView.frame;
    CGRect nextFrmae = self.nextDayView.frame;
    self.nextDayView.frame = self.preDayView.frame;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.currDayView.frame = nextFrmae;
        self.preDayView.frame = curFrame;

        
    } completion:^(BOOL finished) {
        
        UIView *temView = self.currDayView;
        self.currDayView = self.preDayView;
        self.preDayView = self.nextDayView;
        self.nextDayView = temView;
        
        //预加载即将显示月份的上一个月
        int preMon = (self.showMon-1) > 0 ? (self.showMon-1) : 12;
        int preYear = (self.showMon-1) > 0 ? self.showYear : (self.showYear-1);
        [self buildDayViewForDayView:self.preDayView
                                Year:preYear
                               month:preMon];
   
        self.preMonBtn.enabled = YES;
    }];
    
    self.titleLabel.text = [NSString stringWithFormat:@"%d-%d",self.showYear,self.showMon];
    if (self.yyDateViewMonthChanged) {
        self.yyDateViewMonthChanged([NSString stringWithFormat:@"%d",self.showMon]);
    }
}

#pragma mark 查看下一月
- (void)nextMonthAction:(id)sender
{
    self.nextMonBtn.enabled = NO;
    self.showMon += 1;
    if (self.showMon == 13) {
        self.showYear += 1;
        self.showMon = 1;
        
        if (self.yyDateViewYearChanged) {
            self.yyDateViewYearChanged([NSString stringWithFormat:@"%d",self.showYear]);
        }
    }
    
    
    CGRect curFrame = self.currDayView.frame;
    CGRect preFrame = self.preDayView.frame;
    self.preDayView.frame = self.nextDayView.frame;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.currDayView.frame = preFrame;
        self.nextDayView.frame = curFrame;
        
    } completion:^(BOOL finished) {
        
        UIView *temView = self.currDayView;
        self.currDayView = self.nextDayView;
        self.nextDayView = self.preDayView;
        self.preDayView = temView;
        
        //预加载即将显示月份的下一个月
        int nextMon = (self.showMon+1) > 12 ? 1 : (self.showMon+1);
        int nextYear = (self.showMon+1) > 12 ? (self.showYear+1) : self.showYear;
        [self buildDayViewForDayView:self.nextDayView
                                Year:nextYear
                               month:nextMon];
        self.nextMonBtn.enabled = YES;
    }];
    
    self.titleLabel.text = [NSString stringWithFormat:@"%d-%d",self.showYear,self.showMon];
    if (self.yyDateViewMonthChanged) {
        self.yyDateViewMonthChanged([NSString stringWithFormat:@"%d",self.showMon]);
    }
}

#pragma mark 取得该月起始天
- (NSString *)beginDayFordate:(NSString *)date
{
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM"];
    NSDate *newDate=[format dateFromString:date];
    double interval = 0;
    NSDate *beginDate = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&beginDate interval:&interval forDate:newDate];
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *beginString = [myDateFormatter stringFromDate:beginDate];
    return beginString;
}

#pragma mark 取得该月结束天
- (NSString *)endDayFordate:(NSString *)date
{
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM"];
    NSDate *newDate=[format dateFromString:date];
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    BOOL ok = [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&beginDate interval:&interval forDate:newDate];
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return @"";
    }
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *endString = [myDateFormatter stringFromDate:endDate];;
    return endString;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
