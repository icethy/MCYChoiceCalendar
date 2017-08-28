//
//  ViewController.m
//  MCYChoiceDatePicker
//
//  Created by machunyan on 2017/8/28.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import "ViewController.h"
#import "MCYChoiceDateViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *dateLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(100, 100, 200, 50);
    [btn setTitle:@"日期选择(多选)" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(testMuChoiceDatePicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn2.frame = CGRectMake(100, 230, 200, 50);
    [btn2 setTitle:@"日期选择(单选)" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn2.backgroundColor = [UIColor redColor];
    [btn2 addTarget:self action:@selector(testChoiceDatePicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    [self.view addSubview:self.dateLabel];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)testMuChoiceDatePicker
{
    MCYChoiceDateViewController *dateChoiceVC = [[MCYChoiceDateViewController alloc] initWithDatetype:ChoiceDateMultiple];
    
    [self presentViewController:dateChoiceVC animated:YES completion:nil];
    
    dateChoiceVC.muChoiceDateBlock = ^(NSDate *startDate, NSDate *endDate) {
        NSLog(@"开始选择日期：%@  结束选择日期:%@", startDate, endDate);
        NSDateFormatter *fott = [[NSDateFormatter alloc] init];
        [fott setDateFormat:@"yyyy-MM-dd"];
        NSString *startDateStr = [fott stringFromDate:startDate];
        NSString *endDateStr = [fott stringFromDate:endDate];
        
        self.dateLabel.text = [NSString stringWithFormat:@"开始选择日期：%@ 结束选择日期:%@", startDateStr, endDateStr];
    };
    
}

- (void)testChoiceDatePicker
{
    MCYChoiceDateViewController *dateChoiceVC = [[MCYChoiceDateViewController alloc] initWithDatetype:ChoiceDateSingle];
    
    [self presentViewController:dateChoiceVC animated:YES completion:nil];
    
    dateChoiceVC.choiceDateBlock = ^(NSDate *date) {
        NSLog(@"选中的日期:%@", date);
        NSDateFormatter *fott = [[NSDateFormatter alloc] init];
        [fott setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr = [fott stringFromDate:date];
        
        self.dateLabel.text = [NSString stringWithFormat:@"选中日期是:%@", dateStr];
    };
    
}


#pragma mark - 

- (UILabel*)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        _dateLabel.center = self.view.center;
        _dateLabel.font = [UIFont systemFontOfSize:16];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _dateLabel;
}

@end
