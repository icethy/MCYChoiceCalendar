//
//  MCYCalendar.h
//
//  Created by machunyan on 2017/6/30.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CalendarChoiceDateSingle = 1,  // 日期选择 单个
    CalendarChoiceDateMultiple,// 日期选择 多个
} CalendarChoiceDateType;

@protocol MCYCalendarDelegate;

@interface MCYCalendar : UIView

@property (nonatomic, weak) id<MCYCalendarDelegate> delegate;

- (instancetype)initWithCurrentDate:(NSDate*)date choiceDateType:(CalendarChoiceDateType)datetype;

- (void)setSelectDate:(NSDate*)date;

@end

@protocol MCYCalendarDelegate <NSObject>

- (void)calendar:(MCYCalendar *)calendar didSelectedDate:(NSDate *)date;

@end
