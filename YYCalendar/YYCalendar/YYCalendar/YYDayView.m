//
//  YYDayView.m
//  PMLonelyBook
//
//  Created by HZYL_FM3 on 2017/11/8.
//  Copyright © 2017年 HZYL_FM3. All rights reserved.
//

#import "YYDayView.h"

#define RGB(r,g,b,A) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:A]

#define COLOR_STATUS_BACK_ISSIGNIN  RGB(102,204,255,1)//已签到状态背景色
#define COLOR_STATUS_BACK_PAST      RGB(230,230,230,0.5)//未签到已过期状态背景色
#define COLOR_STATUS_BACK_FUTURE    RGB(230,230,230,1.0)//未签到未过期状态背景色
#define COLOR_STATUS_TITLE_ISSIGNIN RGB(204,204,204,1.0)//已签到状态标题颜色
#define COLOR_STATUS_TITLE_NOSIGIN  [UIColor whiteColor]//未签到状态标题颜色
#define COLOR_DAY_TITLE             RGB(19,136,194,0.4)//天数颜色

@interface YYDayView ()

@property (nonatomic, strong) UIButton *statusBtn;
@property (nonatomic, strong) UIButton *dayBtn;
@property (nonatomic, strong) NSString *dayStr;

@end

@implementation YYDayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
                Day:(NSString *)day
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.dayStr = day;
        
        //日期按钮:
        self.dayBtn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self.dayBtn setTitle:day forState:UIControlStateNormal];
        [self addSubview:self.dayBtn];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
               Year:(NSString *)year
              Month:(NSString *)mon
                Day:(NSString *)day
             SingIn:(BOOL)isSignIn
          StatusStr:(NSString *)str
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.dayStr = day;
        
        //状态按钮:
        self.statusBtn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
        [self.statusBtn setTitle:str forState:UIControlStateNormal];
        self.statusBtn.selected = isSignIn;
        [self addSubview:self.statusBtn];
        
        if (isSignIn) {
            [self.statusBtn setBackgroundColor:COLOR_STATUS_BACK_ISSIGNIN];
        }
        else
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy"];
            NSString *toYearStr = [formatter stringFromDate:[NSDate date]];
            [formatter setDateFormat:@"MM"];
            NSString *toMonthStr = [formatter stringFromDate:[NSDate date]];
            [formatter setDateFormat:@"dd"];
            NSString *todayStr = [formatter stringFromDate:[NSDate date]];
            if ([year intValue] > [toYearStr intValue]) {
                [self.statusBtn setBackgroundColor:COLOR_STATUS_BACK_FUTURE];
            }
            else if ([year intValue] == [toYearStr intValue])
            {
                if ([mon intValue] > [toMonthStr intValue]) {
                    [self.statusBtn setBackgroundColor:COLOR_STATUS_BACK_FUTURE];
                }
                else if ([mon intValue] == [toMonthStr intValue])
                {
                    if ([day intValue] >= [todayStr intValue]) {
                        [self.statusBtn setBackgroundColor:COLOR_STATUS_BACK_FUTURE];
                    }
                    else
                    {
                        [self.statusBtn setBackgroundColor:COLOR_STATUS_BACK_PAST];
                    }
                }
                else
                {
                    [self.statusBtn setBackgroundColor:COLOR_STATUS_BACK_PAST];
                }
            }
            else
            {
                [self.statusBtn setBackgroundColor:COLOR_STATUS_BACK_PAST];
            }
        }
        
        //日期按钮:
        self.dayBtn.frame = CGRectMake(0, CGRectGetMaxY(self.statusBtn.frame), self.frame.size.width, self.frame.size.height-CGRectGetMaxY(self.statusBtn.frame));
        [self.dayBtn setTitle:day forState:UIControlStateNormal];
        [self addSubview:self.dayBtn];
    }
    return self;
}

- (UIButton *)statusBtn
{
    if (_statusBtn == nil) {
        _statusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_statusBtn setTitleColor:COLOR_STATUS_TITLE_ISSIGNIN forState:UIControlStateNormal];
        [_statusBtn setTitleColor:COLOR_STATUS_TITLE_NOSIGIN forState:UIControlStateSelected];
        _statusBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        _statusBtn.layer.cornerRadius = self.frame.size.width / 2;
        _statusBtn.userInteractionEnabled = NO;
    }
    return _statusBtn;
}

- (UIButton *)dayBtn
{
    if (_dayBtn == nil) {
        _dayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dayBtn setTitleColor:COLOR_DAY_TITLE forState:UIControlStateNormal];
        _dayBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _dayBtn.userInteractionEnabled = NO;
    }
    return _dayBtn;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (self.yyClickDayView) {
        self.yyClickDayView(_dayStr);
    }
}

@end
