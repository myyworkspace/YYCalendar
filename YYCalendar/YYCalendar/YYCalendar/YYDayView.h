//
//  YYDayView.h
//  PMLonelyBook
//
//  Created by HZYL_FM3 on 2017/11/8.
//  Copyright © 2017年 HZYL_FM3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYDayView : UIView

@property (nonatomic, copy) void(^yyClickDayView)(NSString *dayStr);

- (id)initWithFrame:(CGRect)frame
                Day:(NSString *)day;

- (id)initWithFrame:(CGRect)frame
               Year:(NSString *)year
              Month:(NSString *)mon
                Day:(NSString *)day
             SingIn:(BOOL)isSignIn
          StatusStr:(NSString *)str;

@end
