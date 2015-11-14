之前项目中需要用日历选择工作的日期是哪几天,网上搜了下多是单选日历，且UI不能满足要求, 于是写了个简单的日历选择器:

1.今天用红框标注，只能选择今天以后的工作日期，支持跨月份多选

2.因为每个月的第一天在第一行，所以有时候需要6行才能显示，仿照铁路12306的日历，显示了6行，  选择点击下一个月的日期时会自动切到下一个月，但是可以直接在当前月取消。

3.本日历是基于手势点击切换按钮状态的，用UIButton 的Normal Disable Selected 三种状态代码还可以更简单一点，当初用手势主要是为了以后可以处理3种以上的状态。

## 日历效果演示

![](https://github.com/sntd/LDCalendarView/raw/master/Picture/LDCalendarView.gif)



## 功能说明：

详情可查看Demo中代码

``` 
if (!_calendarView) {
    _calendarView = [[LDCalendarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT)];
    [self.view addSubview:_calendarView];

    __weak typeof(self) weakSelf = self;
    _calendarView.complete = ^(NSArray *result) {
        if (result) {
            weakSelf.seletedDays = result.mutableCopy;
            [tableView reloadData];
        }
    };
}
self.calendarView.defaultDays = _seletedDays;
[self.calendarView show];
```