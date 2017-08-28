//
//  MCYChoiceDateViewController.h
//
//  Created by machunyan on 2017/6/30.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ChoiceDateSingle = 1,  // 日期选择 单个
    ChoiceDateMultiple,// 日期选择 多个
} ChoiceDateType;

typedef void(^singleChoiceDateBlock)(NSDate *date);
typedef void(^multipleChoiceDateBlock)(NSDate *startDate, NSDate *endDate);

@interface MCYChoiceDateViewController : UIViewController

@property (nonatomic, strong) singleChoiceDateBlock choiceDateBlock;    // 单个日期选择 回调 初始化的dateType必须为ZhongBaoChoiceDateSingle
@property (nonatomic, strong) multipleChoiceDateBlock muChoiceDateBlock;// 多个日期选择 回调 初始化的dateType必须为ZhongBaoChoiceDateMultiple

- (instancetype)initWithDatetype:(ChoiceDateType)datetype;

@end
