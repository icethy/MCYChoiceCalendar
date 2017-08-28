//
//  MCYChoiceDateViewController.m
//
//  Created by machunyan on 2017/6/30.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import "MCYChoiceDateViewController.h"
#import "MCYCalendar.h"
#import "UIColor+Util.h"

#define NavigationHeight 64

@interface MCYChoiceDateViewController () <MCYCalendarDelegate>
{
    NSDate *_choiceDate;
    
    NSDate *_startChoiceDate;
    NSDate *_endChoiceDate;
    NSInteger _choiceCount;
    
    NSDateFormatter *_dateFormatter;
    
    ChoiceDateType _datetype;
}

@property (nonatomic, strong) MCYCalendar *calendar;

@property (nonatomic, strong) UIButton *commintButton;

@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UILabel *startDateLabel;

@end

@implementation MCYChoiceDateViewController

- (instancetype)initWithDatetype:(ChoiceDateType)datetype
{
    if (self == [super init]) {
        _datetype = datetype;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self bulidUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftNavigaionButtonClicked
{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


#pragma mark - Private method

- (void)commitButtonClick
{
    if (self.choiceDateBlock && _datetype == ChoiceDateSingle) {
        self.choiceDateBlock(_choiceDate);
    }
    if (self.muChoiceDateBlock && _datetype == ChoiceDateMultiple) {
        self.muChoiceDateBlock(_startChoiceDate, _endChoiceDate);
    }
    [self leftNavigaionButtonClicked];
}

- (void)setCommintButtonStatus:(BOOL)hasChoice
{
    if (!hasChoice) {
        [self.commintButton setBackgroundColor:[UIColor colorWithHexString:@"ade7fb"]];
    } else {
        [self.commintButton setBackgroundColor:[UIColor colorWithHexString:@"22b2e7"]];
    }
}

- (void)bulidUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupCalendar];
    [self setupcommitButton];
    
    if (_datetype == ChoiceDateMultiple) {
        [self setupDateShowTips];
    }
    
    _choiceCount = 0;
}

- (void)setupCalendar
{
    self.calendar = [[MCYCalendar alloc] initWithCurrentDate:[NSDate date] choiceDateType:(CalendarChoiceDateType)_datetype];
    self.calendar.delegate = self;
    CGRect frame = self.calendar.frame;
    frame.origin.y = NavigationHeight;
    self.calendar.frame = frame;
    [self.view addSubview:self.calendar];
}

- (void)setupDateShowTips
{
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.calendar.frame) + 25.5, [UIScreen mainScreen].bounds.size.width, 18)];
    self.tipsLabel.text = @"请选择开始日期";
    self.tipsLabel.font = [UIFont systemFontOfSize:15.];
    self.tipsLabel.textColor = [UIColor colorWithHexString:@"898989"];
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.tipsLabel];
    
    self.startDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tipsLabel.frame) + 20, [UIScreen mainScreen].bounds.size.width, 18)];
    self.startDateLabel.text = [NSString stringWithFormat:@"起止日期 : %@", @"2017-07-03"];
    self.startDateLabel.font = [UIFont systemFontOfSize:15.];
    self.startDateLabel.textColor = [UIColor colorWithHexString:@"333333"];
    self.startDateLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.startDateLabel];
    self.startDateLabel.hidden = YES;
    
    //单独对iPhone5作处理
    if ([UIScreen mainScreen].bounds.size.width == 320) {
        
        CGRect tipsFrame = CGRectMake(self.tipsLabel.frame.origin.x, CGRectGetMaxY(self.calendar.frame)+10, self.tipsLabel.frame.size.width, self.tipsLabel.frame.size.height);
        self.tipsLabel.frame = tipsFrame;
        
        CGRect startDateFrame = CGRectMake(self.startDateLabel.frame.origin.x, CGRectGetMaxY(self.tipsLabel.frame)+3, self.startDateLabel.frame.size.width, self.startDateLabel.frame.size.height);
        self.startDateLabel.frame = startDateFrame;
    }
}

- (void)setupcommitButton
{
    self.commintButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.commintButton.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 50, [UIScreen mainScreen].bounds.size.width, 50);
    [self.commintButton setTitle:@"确认" forState:UIControlStateNormal];
    self.commintButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.commintButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.commintButton addTarget:self action:@selector(commitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.commintButton];
    [self setCommintButtonStatus:NO];
    
}

- (NSString*)getStringWithDate:(NSDate*)date
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    
    NSString *dateString = [_dateFormatter stringFromDate:date];
    
    return dateString;
}

- (void)setCurrentDate:(NSDate*)date
{
    [self.calendar setSelectDate:date];
    if (_choiceCount == 1) { // 请选择结束日期
        self.tipsLabel.text = @"请选择结束日期";
        self.tipsLabel.hidden = NO;
        
        NSString *startDateStr = [self getStringWithDate:_startChoiceDate];
        self.startDateLabel.text = [NSString stringWithFormat:@"起止日期 : %@", startDateStr];
        self.startDateLabel.hidden = NO;
    } else { // 已选择结束日期
        self.tipsLabel.hidden = YES;
        
        int compare = [self compareOneDay:_startChoiceDate withAnotherDay:_endChoiceDate];
        
        NSDate *startDate = _startChoiceDate;
        NSDate *endDate = _endChoiceDate;
        
        switch (compare) {
            case 1: // 开始日期大于结束日期
            {
                startDate = _endChoiceDate;
                endDate = _startChoiceDate;
            }
                break;
                
            default:
                break;
        }
        
        NSString *startDateStr = [self getStringWithDate:startDate];
        NSString *endDateStr = [self getStringWithDate:endDate];
        
        
        self.startDateLabel.text = [NSString stringWithFormat:@"起止日期: %@ 至 %@", startDateStr, endDateStr];
    }
}

// 比较两个NSDate的大小
- (int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    
    NSComparisonResult result = [dateA compare:dateB];
    
    if (result == NSOrderedDescending) {
        //NSLog(@"oneDay比 anotherDay时间晚");
        return 1;
    }
    else if (result == NSOrderedAscending){
        //NSLog(@"oneDay比 anotherDay时间早");
        return -1;
    }
    //NSLog(@"两者时间是同一个时间");
    return 0;
    
}

#pragma mark - MCYCalendarDelegate

- (void)calendar:(MCYCalendar *)calendar didSelectedDate:(NSDate *)date
{
    _choiceDate = date;
    [self setCommintButtonStatus:YES];
    
    if (_datetype == ChoiceDateMultiple) {
        
        _choiceCount++;
        
        if (_choiceCount == 1) {
            _startChoiceDate = _choiceDate;
            [self setCurrentDate:_startChoiceDate];
        } else {
            _endChoiceDate = _choiceDate;
            [self setCurrentDate:_endChoiceDate];
        }
    }
}

@end
