//
//  MCYCalendarItem.h
//
//  Created by machunyan on 2017/6/30.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

typedef enum : NSUInteger {
    CalendarItemChoiceDateSingle = 1,  // 日期选择 单个
    CalendarItemChoiceDateMultiple,// 日期选择 多个
} CalendarItemChoiceDateType;

@protocol MCYCalendarItemDelegate;

@interface MCYCalendarItem : UIView

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, weak) id<MCYCalendarItemDelegate> delegate;

- (instancetype)initWithChoiceType:(CalendarItemChoiceDateType)choiceType;

- (NSDate*)nextMonthDate;
- (NSDate*)previousMonthDate;

@end

@protocol MCYCalendarItemDelegate <NSObject>

- (void)calendarItem:(MCYCalendarItem*)item didSelectedDate:(NSDate*)date;

@end
