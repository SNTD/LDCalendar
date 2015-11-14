//
//  LDCalendarView.m
//
//  Created by lidi on 15/9/1.
//  Copyright (c) 2015年 lidi. All rights reserved.
//

#import "LDCalendarView.h"
#import "NSDate+Extend.h"
#import "UIColor+Extend.h"

#define UNIT_WIDTH  35 * SCREEN_RAT

//行 列 每小格宽度 格子总数
static const NSInteger kRow      = 1 + 6;//一,二,三... 1行 日期6行
static const NSInteger kCol      = 7;
static const NSInteger kTotalNum = (kRow - 1) * kCol;

@interface LDCalendarView()
//UI
@property (nonatomic, strong) UIView         *dateBgView;//日期的背景
@property (nonatomic, strong) UILabel        *titleLab;//标题
@property (nonatomic, strong) UIView         *contentBgView;
@property (nonatomic, strong) UIButton       *doneBtn;//确定按钮

//Data
@property (nonatomic, assign) int32_t        month;
@property (nonatomic, assign) int32_t        year;
@property (nonatomic, strong) NSDate         *today;

@property (nonatomic, strong) NSMutableArray *currentMonthDaysArray;
@property (nonatomic, strong) NSMutableArray *selectArray;

@property (nonatomic, assign) CGRect         touchRect;//可操作区域
@end

@implementation LDCalendarView
- (NSDate *)today {
    if (!_today) {
        NSDate *currentDate = [NSDate date];
        NSInteger tYear     = currentDate.year;
        NSInteger tMonth    = currentDate.month;
        NSInteger tDay      = currentDate.day;
        
        //字符串转换为日期,今天0点的时间
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        _today = [dateFormat dateFromString:[NSString stringWithFormat:@"%@-%@-%@",@(tYear),@(tMonth),@(tDay)]];
    }
    return _today;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.dateBgView = ({
            UIView *view         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            view.alpha           = 0.3;
            view.backgroundColor = [UIColor blackColor];
            [self addSubview:view];
            
            view;
        });

        self.contentBgView = ({
            //内容区的背景
            UIView        *view         = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-UNIT_WIDTH*kCol)/2.0, 100, UNIT_WIDTH*kCol, 42+UNIT_WIDTH*kRow+50)];
            view.layer.cornerRadius     = 2.0;
            view.layer.masksToBounds    = YES;
            view.userInteractionEnabled = YES;
            view.backgroundColor        = [UIColor whiteColor];
            [self addSubview:view];
            
            view;
        });
        
        UIImageView *leftImage = [UIImageView new];
        leftImage.image        = [UIImage imageNamed:@"com_arrows_right"];
        leftImage.transform    = CGAffineTransformMakeRotation(M_PI);
        [_contentBgView addSubview:leftImage];
        leftImage.frame        = CGRectMake(CGRectGetWidth(_contentBgView.frame)/3.0 - 8 - 10, (42-13)/2.0, 8, 13);
        
        UIImageView *rightImage = [UIImageView new];
        rightImage.image        = [UIImage imageNamed:@"com_arrows_right"];
        [_contentBgView addSubview:rightImage];
        rightImage.frame        = CGRectMake(CGRectGetWidth(_contentBgView.frame)*2/3.0 + 8, (42-13)/2.0, 8, 13);
    
        self.titleLab = ({
            UILabel *lab               = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentBgView.frame), 42)];
            lab.backgroundColor        = [UIColor clearColor];
            lab.textColor              = [UIColor blackColor];
            lab.font                   = [UIFont systemFontOfSize:14];
            lab.textAlignment          = NSTextAlignmentCenter;
            lab.userInteractionEnabled = YES;
            [_contentBgView addSubview:lab];
            
            lab;
        });
        
        UITapGestureRecognizer *titleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchMonthTap:)];
        [_titleLab addGestureRecognizer:titleTap];
        
        UIView *line         = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleLab.frame) - 0.5, CGRectGetWidth(_contentBgView.frame), 0.5)];
        line.backgroundColor = [UIColor hexColorWithString:@"dddddd"];
        [_contentBgView addSubview:line];
        
        self.dateBgView = ({
            UIView *view                = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleLab.frame), CGRectGetWidth(_contentBgView.frame), UNIT_WIDTH*kRow)];
            view.userInteractionEnabled = YES;
            view.backgroundColor        = [UIColor hexColorWithString:@"ededed"];
            [_contentBgView addSubview:view];
            
            view;
        });

        UIView *_bottomLine         = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_dateBgView.frame), CGRectGetWidth(_contentBgView.frame), 0.5)];
        _bottomLine.backgroundColor = [UIColor hexColorWithString:@"dddddd"];
        [_contentBgView addSubview:_bottomLine];
        
        self.doneBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake((CGRectGetWidth(_contentBgView.frame) - 150) / 2.0, CGRectGetHeight(_contentBgView.frame) - 40, 150, 30)];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [btn setBackgroundImage:[[UIImage imageNamed:@"b_com_bt_blue_normal"] stretchableImageWithLeftCapWidth:15 topCapHeight:10] forState:UIControlStateNormal];
            [btn setBackgroundImage:[[UIImage imageNamed:@"b_com_bt_blue_normal"] stretchableImageWithLeftCapWidth:15 topCapHeight:10] forState:UIControlStateSelected];
            [btn setBackgroundImage:[[UIImage imageNamed:@"com_bt_gray_normal"] stretchableImageWithLeftCapWidth:15 topCapHeight:10] forState:UIControlStateDisabled];
            [btn addTarget:self action:@selector(doneBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:@"确定" forState:UIControlStateNormal];
            [_contentBgView addSubview:btn];
            
            btn;
        });

        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [_dateBgView addGestureRecognizer:tap];
        
        //初始化数据
        [self initData];
    }
    return self;
}

- (void)initData {
    _selectArray        = @[].mutableCopy;

    //获取当前年月
    NSDate *currentDate = [NSDate date];
    self.month          = (int32_t)currentDate.month;
    self.year           = (int32_t)currentDate.year;
    [self refreshDateTitle];

    _currentMonthDaysArray = [NSMutableArray array];
    for (int i = 0; i < kTotalNum; i++) {
        [_currentMonthDaysArray addObject:@(0)];
    }

    [self showDateView];
}

- (void)switchMonthTap:(UITapGestureRecognizer *)tap {
   CGPoint loc =  [tap locationInView:_titleLab];
    CGFloat titleLabWidth = CGRectGetWidth(_titleLab.frame);
    if (loc.x <= titleLabWidth/3.0) {
        //左
        [self leftSwitch];
    }else if(loc.x >= titleLabWidth/3.0*2.0){
        //右
        [self rightSwitch];
    }
}

- (void)leftSwitch{
    //左
    if (self.month > 1) {
        self.month -= 1;
    }else {
        self.month = 12;
        self.year -= 1;
    }
    
    [self refreshDateTitle];
}

- (void)rightSwitch {
    if (self.month < 12) {
        self.month += 1;
    }else {
        self.month = 1;
        self.year += 1;
    }
    
    [self refreshDateTitle];
}

- (void)refreshDateTitle {
    _titleLab.text = [NSString stringWithFormat:@"%@月,%@年",@(self.month),@(self.year)];
    
    [self showDateView];
}

- (void)showDateView {
    //移除之前子视图
    [_dateBgView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    CGFloat offX    = 0.0;
    CGFloat offY    = 0.0;
    CGFloat w       = (CGRectGetWidth(_dateBgView.frame)) / kCol;
    CGFloat h       = (CGRectGetHeight(_dateBgView.frame)) / kRow;
    CGRect baseRect = CGRectMake(offX,offY, w, h);
    NSArray *tmparr = @[@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
    for(int i = 0 ;i < 7; i++)
    {
        UILabel *lab        = [[UILabel alloc] initWithFrame:baseRect];
        lab.textColor       = [UIColor hexColorWithString:@"848484"];
        lab.textAlignment   = NSTextAlignmentCenter;
        lab.font            = [UIFont systemFontOfSize:10];
        lab.backgroundColor = [UIColor clearColor];
        lab.text            = [tmparr objectAtIndex:i];
        [_dateBgView addSubview:lab];

        baseRect.origin.x   += baseRect.size.width;
    }

    //字符串转换为日期
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *firstDay =[dateFormat dateFromString:[NSString stringWithFormat:@"%@-%@-%@",@(self.year),@(self.month),@(1)]];
    
    CGFloat startDayIndex = [NSDate acquireWeekDayFromDate:firstDay];
    //第一天是今天，特殊处理
    if (startDayIndex == 1) {
        //星期天（对应一）
        startDayIndex = 6;
    }else {
        //周一到周六（对应2-7）
        startDayIndex -= 2;
    }
    
    baseRect.origin.x = w * startDayIndex;
    baseRect.origin.y += (baseRect.size.height);
    NSInteger baseTag = 100;
    for(int i = startDayIndex; i < kTotalNum;i++)
    {
        if (i % kCol == 0 && i!= 0)
        {
            baseRect.origin.y += (baseRect.size.height);
            baseRect.origin.x = offX;
        }
        
        //设置触摸区域
        if (i == startDayIndex)
        {
            _touchRect.origin      = baseRect.origin;
            _touchRect.origin.x    = 0;
            _touchRect.size.width  = kCol * w;
            _touchRect.size.height = kRow * h;
        }
        
        UIButton *btn              = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag                    = baseTag + i;
        [btn setFrame:baseRect];
        btn.userInteractionEnabled = NO;
        btn.backgroundColor        = [UIColor clearColor];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:10]];
        
        NSDate * date = [firstDay dateByAddingTimeInterval:(i - startDayIndex) *24*60*60];
        _currentMonthDaysArray[i] = @(([date timeIntervalSince1970]) * 1000);
        NSString *title = INTTOSTR(date.day);
        if ([date isToday])
        {
            title = @"今天";
            btn.layer.borderColor = [UIColor hexColorWithString:@"f49e79"].CGColor;
            btn.layer.borderWidth = 0.5;
        }
        else if(date.day == 1)
        {
            //1号在下面标一下月份
            UILabel *monthLab        = [[UILabel alloc] initWithFrame:CGRectMake(baseRect.origin.x, baseRect.origin.y + baseRect.size.height - 7, baseRect.size.width, 7)];
            monthLab.backgroundColor = [UIColor clearColor];
            monthLab.textAlignment   = NSTextAlignmentCenter;
            monthLab.font            = [UIFont systemFontOfSize:7];
            monthLab.textColor       = [UIColor hexColorWithString:@"c0c0c0"];
            monthLab.text            = [NSString stringWithFormat:@"%@月",@(date.month)];
            [_dateBgView addSubview:monthLab];
        }
        
        [btn setTitle:title forState:UIControlStateNormal];
        if ([self.today compare:date] < 0) {
            //时间比今天大,同时是当前月
            [btn setTitleColor:[UIColor hexColorWithString:@"2b2b2b"] forState:UIControlStateNormal];
        }else {
            [btn setTitleColor:[UIColor hexColorWithString:@"bfbfbf"] forState:UIControlStateNormal];
        }
        [btn setBackgroundColor:[UIColor clearColor]];
        [_dateBgView addSubview:btn];
        [_dateBgView sendSubviewToBack:btn];
        
        baseRect.origin.x += (baseRect.size.width);
    }
    
    //高亮选中的
    [self refreshDateView];
}

- (void)setDefaultDays:(NSArray *)defaultDays {
    _defaultDays = defaultDays;
    
    if (defaultDays) {
        _selectArray = [defaultDays mutableCopy];
    }else {
        _selectArray = @[].mutableCopy;
    }
}

- (void)refreshDateView {
    for(int i = 0; i < kTotalNum; i++)
    {
        UIButton *btn = (UIButton *)[_dateBgView viewWithTag:100 + i];
        NSNumber *interval = [_currentMonthDaysArray objectAtIndex:i];

        if (i < [_currentMonthDaysArray count] && btn)
        {
            if ([_selectArray containsObject:interval]) {
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setBackgroundColor:[UIColor hexColorWithString:@"77d2c5"]];
            }
        }
    }
}

- (void)show {
    self.hidden = NO;
}

- (void)hide {
    self.hidden = YES;
}

-(void)tap:(UITapGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:_dateBgView];
    if (CGRectContainsPoint(_touchRect, point)) {
        CGFloat w       = (CGRectGetWidth(_dateBgView.frame)) / kCol;
        CGFloat h       = (CGRectGetHeight(_dateBgView.frame)) / kRow;
        int row         = (int)((point.y - _touchRect.origin.y) / h);
        int col         = (int)((point.x) / w);

        NSInteger index = row * kCol + col;
        [self clickForIndex:index];
    }
}

- (void)clickForIndex:(NSInteger)index
{
    UIButton *btn = (UIButton *)[_dateBgView viewWithTag:100 + index];
    if (index < [_currentMonthDaysArray count]) {
        NSNumber *interval = [_currentMonthDaysArray objectAtIndex:index];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval.doubleValue/1000.0];
        if ([self.today  compare:date] < 0) {
            //时间比今天大,同时是当前月
        }else {
            return;
        }
        if ([_selectArray containsObject:interval]) {
            //已选中,取消
            [_selectArray removeObject:interval];
            [btn setTitleColor:[UIColor hexColorWithString:@"2b2b2b"] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor clearColor]];
        }
        else {
            //未选中,想选择
            [_selectArray addObject:interval];

            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor hexColorWithString:@"77d2c5"]];
            
            //如果选中的是下个月切换到下个月
            if (date.month > self.month) {
                [self rightSwitch];
            }
        }
    }
}

- (void)doneBtnClick:(id)sender
{
    if (_complete) {
        _complete([_selectArray mutableCopy]);
    }
    [self hide];
}
@end
