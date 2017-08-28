//
//  MCYCalendar.m
//
//  Created by machunyan on 2017/6/30.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import "MCYCalendar.h"
#import "MCYCalendarItem.h"
#import "UIColor+Util.h"

#define Weekdays @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"]

static NSDateFormatter *dateFormattor;

@interface MCYCalendar () <UIScrollViewDelegate, MCYCalendarItemDelegate>

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) CalendarChoiceDateType datetype;

@property (nonatomic, strong) UIView *titleView; // 标题栏
@property (nonatomic, strong) UIView *weekView;  // 周 栏
@property (nonatomic, strong) UIScrollView *scrollView; // 日历显示栏

@property (nonatomic, strong) UIButton *titleButton; //显示日期的标题栏 可点击(暂未实现)
@property (nonatomic, strong) MCYCalendarItem *leftCalendarItem;
@property (nonatomic, strong) MCYCalendarItem *centerCalendarItem;
@property (nonatomic, strong) MCYCalendarItem *rightCalendarItem;
@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation MCYCalendar

- (instancetype)initWithCurrentDate:(NSDate*)date choiceDateType:(CalendarChoiceDateType)datetype
{
    if (self == [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.date = date;
        self.datetype = datetype;
        
        [self setupTitleView];
        [self setupWeekHeader];
        [self setupCalendarItems];
        [self setupScrollView];
        [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetMaxY(self.scrollView.frame))];
        
        [self setCurrentDate:self.date];
    }
    
    return self;
}

- (void)setSelectDate:(NSDate*)date
{
    self.date = date;
    [self setCurrentDate:self.date];
}

#pragma mark - Private

- (NSString*)stringFromDate:(NSDate*)date
{
    if (!dateFormattor) {
        dateFormattor = [[NSDateFormatter alloc] init];
        [dateFormattor setDateFormat:@"yyyy年MM月"];
    }
    
    return [dateFormattor stringFromDate:date];
}

// 设置最上层title
- (void)setupTitleView
{
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    self.titleView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.titleView];
    
    CGFloat orgX = 25;
    CGFloat buttonWidth = (self.titleView.frame.size.width - orgX * 2) / 3;
    
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton.frame = CGRectMake(orgX, 0, buttonWidth, self.titleView.frame.size.height);
    [previousButton setImage:[UIImage imageNamed:@"dateChoice_previous"] forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(setPreviousMonthDate) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:previousButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(SCREEN_WIDTH - orgX - buttonWidth, 0, buttonWidth, self.titleView.frame.size.height);
    [nextButton setImage:[UIImage imageNamed:@"dateChoice_enter"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(setNextMonthDate) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:nextButton];
    
    UIButton *tempTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempTitleButton.frame = CGRectMake(previousButton.frame.size.width + previousButton.frame.origin.x, 0, buttonWidth, self.titleView.frame.size.height);
    [tempTitleButton setTitle:@"2017年6月" forState:UIControlStateNormal];
    tempTitleButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [tempTitleButton setTitleColor:[UIColor colorWithHexString:@"22b2e7"] forState:UIControlStateNormal];
    [tempTitleButton addTarget:self action:@selector(showDatePicker) forControlEvents:UIControlEventTouchUpInside];
    self.titleButton = tempTitleButton;
    [self.titleView addSubview:self.titleButton];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.titleView.frame.size.height, SCREEN_WIDTH, 1)
                        ];
    lineView.backgroundColor = [UIColor colorWithHexString:@"d9d9d9"];
    [self.titleView addSubview:lineView];
    
}

// 设置星期文字的显示
- (void)setupWeekHeader
{
    self.weekView = [[UIView alloc] initWithFrame:CGRectMake(0, self.titleView.frame.size.height, SCREEN_WIDTH, 50)];
    [self addSubview:self.weekView];
    
    NSInteger count = [Weekdays count];
    CGFloat space = 10;
    CGFloat width = (SCREEN_WIDTH - space * 2) / count;
    for (int i = 0; i < count; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(space + width * i, 0, width, self.weekView.frame.size.height)];;
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.text = Weekdays[i];
        weekdayLabel.font = [UIFont systemFontOfSize:13];
        
        if (i == 0 || i == count - 1) {
            weekdayLabel.textColor = [UIColor colorWithHexString:@"898989"];
        } else {
            weekdayLabel.textColor = [UIColor colorWithHexString:@"333333"];
        }
        
        [self.weekView addSubview:weekdayLabel];
    }
}

// 设置包含日历的item的scrollView
- (void)setupScrollView
{
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.scrollView setFrame:CGRectMake(0, self.weekView.frame.size.height + self.titleView.frame.size.height - 10, SCREEN_WIDTH, self.centerCalendarItem.frame.size.height + 10)];
    self.scrollView.contentSize = CGSizeMake(3 * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    [self addSubview:self.scrollView];
}

// 设置三个日历的item
- (void)setupCalendarItems
{
    self.scrollView = [[UIScrollView alloc] init];
    
    self.leftCalendarItem = [[MCYCalendarItem alloc] initWithChoiceType:(CalendarItemChoiceDateType)self.datetype];
    [self.scrollView addSubview:self.leftCalendarItem];
    
    CGRect itemFrame = self.leftCalendarItem.frame;
    itemFrame.origin.x = SCREEN_WIDTH;
    self.centerCalendarItem = [[MCYCalendarItem alloc] initWithChoiceType:(CalendarItemChoiceDateType)self.datetype];
    self.centerCalendarItem.frame = itemFrame;
    self.centerCalendarItem.delegate = self;
    [self.scrollView addSubview:self.centerCalendarItem];
    
    itemFrame.origin.x = SCREEN_WIDTH * 2;
    self.rightCalendarItem = [[MCYCalendarItem alloc] initWithChoiceType:(CalendarItemChoiceDateType)self.datetype];
    self.rightCalendarItem.frame = itemFrame;
    [self.scrollView addSubview:self.rightCalendarItem];
}

// 设置当前日期， 初始化
- (void)setCurrentDate:(NSDate*)date
{
    self.centerCalendarItem.date = date;
    self.leftCalendarItem.date = [self.centerCalendarItem previousMonthDate];
    self.rightCalendarItem.date = [self.centerCalendarItem nextMonthDate];
    
    [self.titleButton setTitle:[self stringFromDate:self.centerCalendarItem.date] forState:UIControlStateNormal];
}

// 重新加载日历items的数据
- (void)reloadCalendarItems
{
    CGPoint offset = self.scrollView.contentOffset;
    
    if (offset.x == self.scrollView.frame.size.width) { // 防止滑动一点点并不切换scrollview的视图
        return;
    }
    
    if (offset.x > self.scrollView.frame.size.width) {
        [self setNextMonthDate];
    } else {
        [self setPreviousMonthDate];
    }
    
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
}

#pragma mark - SEL

// 跳到上一个月
- (void)setPreviousMonthDate
{
    [self setCurrentDate:[self.centerCalendarItem previousMonthDate]];
}

// 跳到下一个月
- (void)setNextMonthDate
{
    [self setCurrentDate:[self.centerCalendarItem nextMonthDate]];
}

// 暂未实现
- (void)showDatePicker{}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self reloadCalendarItems];
}

#pragma mark - MCYCalendarItemDelegate

- (void)calendarItem:(MCYCalendarItem *)item didSelectedDate:(NSDate *)date
{
    self.date = date;
    [self setCurrentDate:self.date];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendar:didSelectedDate:)]) {
        [self.delegate calendar:self didSelectedDate:self.date];
    }
}

@end

