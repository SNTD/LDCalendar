//
//  ViewController.m
//  LDCalendarView
//
//  Created by lidi on 15/9/1.
//  Copyright (c) 2015年 lidi. All rights reserved.
//

#import "LDCalenderViewController.h"
#import "LDCalendarView.h"
#import "NSDate+extend.h"

@interface LDCalenderViewController ()
@property (nonatomic, strong)LDCalendarView    *calendarView;//日历控件
@property (nonatomic, strong)NSMutableArray *seletedDays;//选择的日期

@property (nonatomic, copy)NSString *showStr;
@end

@implementation LDCalenderViewController

- (NSString *)showStr {
    NSMutableString *str = [NSMutableString string];
    
    [str appendString:@"已选择日期:\r\n"];
    //从小到大排序
    [self.seletedDays sortUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return [obj1 compare:obj2];
    }];
    for (NSNumber *interval in self.seletedDays) {
        NSString *partStr = [NSDate stringWithTimestamp:interval.doubleValue/1000.0 format:@"MM.dd"];
        [str appendFormat:@"%@ ",partStr];
    }
    return [str copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CalendarCell"];
    UILabel *showLab= (UILabel *)[cell.contentView viewWithTag:100.0];
    if (self.seletedDays.count) {
        showLab.text = self.showStr;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200.f;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //日期选择
    if (!_calendarView) {
        _calendarView = [[LDCalendarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT)];
        [self.view addSubview:_calendarView];
        
        __weak typeof(self) weakSelf = self;
        _calendarView.complete = ^(NSArray *result) {
            if (result) {
                weakSelf.seletedDays = [result mutableCopy];
                [tableView reloadData];
            }
        };
    }
    [self.calendarView show];
    self.calendarView.defaultDates = _seletedDays;
}
@end
