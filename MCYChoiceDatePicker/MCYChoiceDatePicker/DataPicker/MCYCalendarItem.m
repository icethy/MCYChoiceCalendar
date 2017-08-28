//
//  MCYCalendarItem.m
//
//  Created by machunyan on 2017/6/30.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import "MCYCalendarItem.h"
#import "UIColor+Util.h"

#define CollectionViewHorizonMargin 10
#define CollectionViewVerticalMargin 10

@interface MCYCalendarCell : UICollectionViewCell

- (UILabel*)dayLabel;

@end

@implementation MCYCalendarCell
{
    UILabel *_dayLabel;
}

- (UILabel*)dayLabel
{
    if (!_dayLabel) {
        _dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 20, 20)];
        _dayLabel.font = [UIFont systemFontOfSize:15.];
        [self addSubview:_dayLabel];
    }
    
    return _dayLabel;
}

@end

@interface MCYCalendarItem ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) CalendarItemChoiceDateType datetype; // 选择类型 单次选择 多次连续选择
@property (nonatomic, assign) NSInteger choiceCount;     // 选择次数
@property (nonatomic, assign) BOOL hasChoiceDate; // 是否已经选择了日期

@end

@implementation MCYCalendarItem

static NSInteger startSelectDateDay;
static NSInteger endSelectDateDay;

static NSDate *startSelectDate; // 开始选择的日期 连续多选
static NSDate *endSelectDate;   // 结束选择的日期 连续多选

static NSMutableDictionary *markSelectMultipleDic; // 保存多选的开始和结束日期 保存的NSMutableArray。 arry中保存的NSDate
static NSMutableDictionary *markSelectSingleDic;   // 保存单选的日期 NSdate

- (instancetype)initWithChoiceType:(CalendarItemChoiceDateType)choiceType
{
    if (self == [super init]) {
        
        self.hasChoiceDate = NO;
        self.datetype = choiceType;
        markSelectSingleDic = nil;
        
        if (self.datetype == CalendarItemChoiceDateMultiple) {
            self.choiceCount = 0;
            startSelectDateDay = 0;
            endSelectDateDay = 0;
            markSelectMultipleDic = nil;
        }
        
        self.backgroundColor = [UIColor clearColor];
        [self setupCollectionView];
        [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.collectionView.frame.size.height + CollectionViewVerticalMargin * 2)];
    }
    
    return self;
}

#pragma mark - Custom Accessors

- (void)setDate:(NSDate *)date
{
    _date = date;
    [self.collectionView reloadData];
}

#pragma mark - Public

// 获取date的下个月日期
- (NSDate*)nextMonthDate
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 1;
    NSDate *nextMonthDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
    
    return nextMonthDate;
}

// 获取date的上个月日期
- (NSDate*)previousMonthDate
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = -1;
    NSDate *previousMonthDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
    
    return previousMonthDate;
}

#pragma mark - Private

// collectionView显示日期单元，设置其属性
- (void)setupCollectionView
{
    CGFloat itemWidth = (SCREEN_WIDTH - CollectionViewHorizonMargin * 2) / 7;
    CGFloat itemHeight = itemWidth;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    
    CGRect collectionViewFrame = CGRectMake(CollectionViewHorizonMargin, CollectionViewVerticalMargin, SCREEN_WIDTH - CollectionViewVerticalMargin * 2, (itemHeight) * 6 + 3.5);
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:flowLayout];
    [self addSubview:self.collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[MCYCalendarCell class] forCellWithReuseIdentifier:@"CalendarCell"];
}

// 获取date当前月的第一天是星期几
- (NSInteger)weekdayOfFirstDayInDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.date];
    [components setDay:1];
    NSDate *firstDate = [calendar dateFromComponents:components];
    NSDateComponents *firstComponents = [calendar components:NSCalendarUnitWeekday fromDate:firstDate];
    return firstComponents.weekday - 1;
}

// 获取date当前月的总天数
- (NSInteger)totalDaysInMonthOfDate:(NSDate*)date
{
    NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return range.length;
}

// 判断date1和date2是否同月
- (BOOL)isSameMonth:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 month] == [comp2 month] &&
            [comp1 year]  == [comp2 year];
}

// 获取date的当天
- (NSInteger)currentDayInMonthOfDate:(NSDate*)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | kCFCalendarUnitDay;
    NSDateComponents* comp = [calendar components:unitFlags fromDate:date];
    
    return [comp day];
}

// 判断date1和date2是否连续
- (BOOL)isContinuousDate:(NSDate*)date1 ToDate2:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    BOOL isContinuous = NO;
    (([comp1 month] + 1 == [comp2 month]) || ([comp2 month] + 1 == [comp1 month])) ? (isContinuous = YES) : (isContinuous == NO);
    return isContinuous &&
    [comp1 year]  == [comp2 year];
}

#pragma mark - UICollectionDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 42;
}


- (UICollectionViewCell*)singleCollectionView:(UICollectionViewCell*)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *identifier = @"CalendarCell";
    MCYCalendarCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.dayLabel.textColor = [UIColor colorWithHexString:@"333333"];
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = [UIColor colorWithHexString:@"d9d9d9"].CGColor;
    NSInteger firstWeekday = [self weekdayOfFirstDayInDate];
    NSInteger totalDaysOfMonth = [self totalDaysInMonthOfDate:self.date];
    NSInteger totalDaysOfLastMonth = [self totalDaysInMonthOfDate:[self previousMonthDate]];
    
    if (indexPath.row < firstWeekday) {  // 小于这个月的第一天
        
        NSInteger day = totalDaysOfLastMonth - firstWeekday + indexPath.row + 1;
        cell.dayLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        cell.dayLabel.textColor = [UIColor colorWithHexString:@"898989"];
    } else if (indexPath.row >= totalDaysOfMonth + firstWeekday) {  // 大于这个月的最后一天
        
        NSInteger day = indexPath.row - totalDaysOfMonth - firstWeekday + 1;
        cell.dayLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        cell.dayLabel.textColor = [UIColor colorWithHexString:@"898989"];
    } else {  // 属于这个月
        
        NSInteger day = indexPath.row - firstWeekday + 1;
        cell.dayLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        
        if (day == [[NSCalendar currentCalendar] component:NSCalendarUnitDay fromDate:self.date]) { // 当天日期
            
            if (self.hasChoiceDate) { // 已经选过日期， 背景标亮
                cell.backgroundColor =  [UIColor colorWithHexString:@"22b2e7"];
                cell.dayLabel.textColor = [UIColor whiteColor];
            } else { // 背景置灰
                cell.backgroundColor =  [UIColor colorWithHexString:@"cccccc"];
                cell.dayLabel.textColor = [UIColor colorWithHexString:@"333333"];
            }
        }
        
        // 如果日期和选中日期同年不同月或不同年 则不标记date
        if (markSelectSingleDic && [markSelectSingleDic objectForKey:@"CalendarItemChoiceDateSingle"]) {
            NSDate *selectedDate = [markSelectSingleDic objectForKey:@"CalendarItemChoiceDateSingle"];
            if (![[NSCalendar currentCalendar] isDate:selectedDate equalToDate:self.date toUnitGranularity:NSCalendarUnitMonth]) {
    
                cell.backgroundColor = [UIColor clearColor];
                cell.dayLabel.textColor = [UIColor colorWithHexString:@"333333"];
            }
        }
        
        // 如果日期和选中日期同年同月不同天，注：第一个判断中的方法是iOS8的新API，会比较传入单元以及比传入单元大得单元上数据是否相等，亲测同时传入Year和Month结果错误
        /*if ([[NSCalendar currentCalendar] isDate:selectedDate equalToDate:self.date toUnitGranularity:NSCalendarUnitMonth] && ![[NSCalendar currentCalendar] isDateInToday:self.date]) {
         
         //将当前日期的那天高亮显示
         if (day == [[NSCalendar currentCalendar] component:NSCalendarUnitDay fromDate:selectedDate]) {
         
            }
         }*/
        
    }
    
    return cell;
}

- (UICollectionViewCell*)multipleCollectionView:(UICollectionViewCell*)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    // note : 多选跨月会自动跳转到次月， 因此， 当月选中应该是 1-end 上月选中 start-月末最后一天 【当前显示月为结束月】
    // note : 多选跨月会自动跳转到次月， 但如果返回上一月查看选中记录， 此时当月选择应该是start-月末最后一天 【当前显示月为开始月】
    // note : 当选择了起始日期 起始日期之前的不能选择。  终止日期之后的不能选择。
    
    static NSString *identifier = @"CalendarCell";
    MCYCalendarCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.dayLabel.textColor = [UIColor colorWithHexString:@"333333"];
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = [UIColor colorWithHexString:@"d9d9d9"].CGColor;
    NSInteger firstWeekday = [self weekdayOfFirstDayInDate];
    NSInteger totalDaysOfMonth = [self totalDaysInMonthOfDate:self.date];
    NSInteger totalDaysOfLastMonth = [self totalDaysInMonthOfDate:[self previousMonthDate]];
    
    if (indexPath.row < firstWeekday) {  // 小于这个月的第一天
        
        NSInteger day = totalDaysOfLastMonth - firstWeekday + indexPath.row + 1;
        cell.dayLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        cell.dayLabel.textColor = [UIColor colorWithHexString:@"898989"];
        
        if (startSelectDateDay != 0 && endSelectDateDay != 0           // 起始date不为空
            && ![self isSameMonth:startSelectDate date2:endSelectDate] // 跨月 即起始位置不在同月
            && [self isSameMonth:endSelectDate date2:self.date]        // 当前显示日历为结束月
            && day >= startSelectDateDay && day <= totalDaysOfLastMonth) { // 则 当月选中应该是:1-end 上月选中:start-月末
            cell.backgroundColor =  [UIColor colorWithHexString:@"22b2e7"];
            cell.dayLabel.textColor = [UIColor whiteColor];
        }
        
    } else if (indexPath.row >= totalDaysOfMonth + firstWeekday) {  // 大于这个月的最后一天
        
        NSInteger day = indexPath.row - totalDaysOfMonth - firstWeekday + 1;
        cell.dayLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        cell.dayLabel.textColor = [UIColor colorWithHexString:@"898989"];
        
        if (startSelectDateDay != 0 && endSelectDateDay != 0              // 起始date不为空
            && ![self isSameMonth:startSelectDate date2:endSelectDate]    // 跨月
            && [self isSameMonth:startSelectDate date2:self.date]         // 当前显示日历为开始月
            && day >= 1 && day <= [self currentDayInMonthOfDate:endSelectDate]) { // 则 当月选择应该是start-月末最后一天 1-end
            cell.backgroundColor =  [UIColor colorWithHexString:@"22b2e7"];
            cell.dayLabel.textColor = [UIColor whiteColor];
        }
        
    } else {  // 属于这个月
        
        NSInteger day = indexPath.row - firstWeekday + 1;
        cell.dayLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        
        if (day == [[NSCalendar currentCalendar] component:NSCalendarUnitDay fromDate:self.date]) { // 当天日期
            
            if (self.hasChoiceDate) { // 已经选过日期， 背景标亮
                cell.backgroundColor =  [UIColor colorWithHexString:@"22b2e7"];
                cell.dayLabel.textColor = [UIColor whiteColor];
            } else { // 背景置灰
                cell.backgroundColor =  [UIColor colorWithHexString:@"cccccc"];
                cell.dayLabel.textColor = [UIColor colorWithHexString:@"333333"];
            }
        }
        
        if (startSelectDateDay != 0 && endSelectDateDay != 0) { // 已经选择了起始位置
            
            cell.dayLabel.textColor = [UIColor colorWithHexString:@"333333"];
            cell.backgroundColor = [UIColor clearColor];
            if (![self isSameMonth:startSelectDate date2:endSelectDate]) { // 当月 跨月
                
                if ([self isSameMonth:startSelectDate date2:self.date]) { // 当前选中为开始月 当月选择应该是start-月末 1-end
                    if (day >= startSelectDateDay && day <= totalDaysOfMonth) {
                        cell.backgroundColor =  [UIColor colorWithHexString:@"22b2e7"];
                        cell.dayLabel.textColor = [UIColor whiteColor];
                    }
                } else if ([self isSameMonth:endSelectDate date2:self.date]) { // 当前选中为结束月 当月选中：1-end 上月选中：start-月末
                    if (day >= 1 && day <= [self currentDayInMonthOfDate:endSelectDate]) {
                        cell.backgroundColor =  [UIColor colorWithHexString:@"22b2e7"];
                        cell.dayLabel.textColor = [UIColor whiteColor];
                    }
                }
                
            } else { // 当月 不跨月
        
                if ((day >= startSelectDateDay && day <= endSelectDateDay) || (day >= endSelectDateDay && day <= startSelectDateDay)) { // 连接起点终点日期
                    cell.backgroundColor =  [UIColor colorWithHexString:@"22b2e7"];
                    cell.dayLabel.textColor = [UIColor whiteColor];
                }
            }
        }
    }
    
    // 如果日期和选中日期同年不同月或不同年 则不标记date
    if (markSelectMultipleDic && [markSelectMultipleDic objectForKey:@"CalendarItemChoiceDateMultiple"]) {
        NSMutableArray *multioleDic = [markSelectMultipleDic objectForKey:@"CalendarItemChoiceDateMultiple"];
        NSDate *startDate = [multioleDic objectAtIndex:0];
        NSDate *endDate = [multioleDic objectAtIndex:1];
        if (![[NSCalendar currentCalendar] isDate:startDate equalToDate:self.date toUnitGranularity:NSCalendarUnitMonth] && ![[NSCalendar currentCalendar] isDate:endDate equalToDate:self.date toUnitGranularity:NSCalendarUnitMonth]) {
        
            cell.backgroundColor = [UIColor clearColor];
            cell.dayLabel.textColor = [UIColor colorWithHexString:@"898989"];
        }
    }
    
    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionViewCell*)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    // 多选
    if (self.datetype == CalendarItemChoiceDateMultiple) {
        
        return [self multipleCollectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
    // 单选
    else {
        
        return [self singleCollectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.hasChoiceDate = YES; // 已点击date

//    if (self.datetype == CalendarItemChoiceDateMultiple) {
//        if (self.choiceCount >= 2) { // 连续选择 选中起始位置后，将不能继续选择
//            [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//            return;
//        }
//    }
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.date];
    NSInteger firstWeekday = [self weekdayOfFirstDayInDate];
    NSInteger selectDay = indexPath.row - firstWeekday + 1;
    [components setDay:selectDay];
    NSDate *selectedDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    if (self.datetype == CalendarItemChoiceDateMultiple) {
        self.choiceCount++;
        if (self.choiceCount == 1) {
            
            startSelectDateDay = [self currentDayInMonthOfDate:selectedDate];
            startSelectDate = selectedDate;
            
        } else {
            
            endSelectDateDay = [self currentDayInMonthOfDate:selectedDate];
            endSelectDate = selectedDate;
            
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
            NSMutableArray *tempArr = [NSMutableArray arrayWithObjects:startSelectDate, endSelectDate, nil];
            [tempDic setObject:tempArr forKey:@"CalendarItemChoiceDateMultiple"];
            markSelectMultipleDic = tempDic;
        }
        
    } else {
        
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        [tempDic setObject:selectedDate forKey:@"CalendarItemChoiceDateSingle"];
        markSelectSingleDic = tempDic;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarItem:didSelectedDate:)]) {
        [self.delegate calendarItem:self didSelectedDate:selectedDate];
    }
}

@end
