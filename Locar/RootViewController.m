//
//  RootViewController.m
//  dyhAutoApp
//
//  Created by apple on 15/5/25.
//  Copyright (c) 2015年 dayihua. All rights reserved.
//

#import "RootViewController.h"

//#define TIP_IMAGE

#ifdef TIP_IMAGE
#import "EGOImageView.h"
#endif


#define DEBUG_GAP       0.0
#define BOTTOM_PICKER_VIEW_HEIGHT       ([[UIScreen mainScreen] bounds].size.width - 60.0)
#define TITLE_FONTSIZE  17.0
#define ARROWICONSIZE   16.0

typedef int(^MessageBlock)();

static NSString *viewFlag__ = @"";

@interface RootViewController() <UIPickerViewDelegate>
{
    UILabel *labelTitle;
    UIImageView *arrowLeft, *arrowRight;
    BOOL isPicking;
    BOOL isShowValueTitle;
    int pickerType; // 0x01 : middle, 0x02 : bottom
    NSString *pickerTitle, *pickerFinishTitle;
    UIPickerView *rootDataPicker;
    UIDatePicker *rootDatePicker;
    UIView *rootPickerView;
}
@end

@implementation RootViewController

- (NSString *)viewFlag
{
    return viewFlag__;
}

- (void)setViewFlag:(NSString *)flag
{
    viewFlag__ = flag;
}

- (id)init
{
    NSLog(@"ViewController: %@ - init", self);
    
    if ((self = [super init]))
    {
        pickerType = 0;
        self.syncFlag = NO;
    }
    return self;
}

#ifdef USEFONT
/**
 * 返回传入veiw的所有层级结构
 *
 * @param view 需要获取层级结构的view
 */
- (void)changeViewFont:(UIView *)view
{
    if([view isKindOfClass:[UITextView class]])
    {
        UITextView *v = (UITextView *)view;
        [v setFont:[UIFont fontWithName:USEFONT size:v.font.pointSize]];
    }
    else if([view isKindOfClass:[UILabel class]])
    {
        UILabel *v = (UILabel *)view;
        [v setFont:[UIFont fontWithName:USEFONT size:v.font.pointSize]];
    }
    else if([view isKindOfClass:[UITextField class]])
    {
        UITextField *v = (UITextField *)view;
        [v setFont:[UIFont fontWithName:USEFONT size:v.font.pointSize]];
        [v setBackground:[UIImage imageNamed:@"textbg"]];
    }
    else if([view isKindOfClass:[UIButton class]])
    {
        UIButton *v = (UIButton *)view;
        [v setFont:[UIFont fontWithName:USEFONT size:v.font.pointSize]];
    }
    // 4.遍历所有的子控件
    for (UIView *child in view.subviews)
    {
        [self changeViewFont:child];
    }
}
#endif

- (void)viewDidLoad
{
#ifdef USEFONT
    [self changeViewFont:self.view];
#endif
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSLog(@"ViewController: %@ - viewDidLoad", self);
    CGRect frame = [[UIScreen mainScreen] bounds];// self.view.frame;
    {
        waitingCover = [[UIView alloc] init];
        [waitingCover setFrame:self.view.frame];
        [waitingCover setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        waitingCover.layer.zPosition = 900;
        [waitingCover setHidden:YES];
        [self.view addSubview:waitingCover];
        
        waitingCover.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancelPickItem:)];
        [waitingCover addGestureRecognizer:singleTap];
    }
    {
        // bottom picker view1
        /*
         |-----------------------------------------|
         |                                         |
         |                                         |
         |                                         |
         |                                         |
         |-----------------------------------------|
         |             ⇈ 二年级二班 ⇈                |
         |-----------------------------------------|
         |                                         |
         |                                         |
         |                                         |
         |                                         |
         |               pickerView                |
         |                                         |
         |                                         |
         |                                         |
         |                                         |
         |                                         |
         |-----------------------------------------|
         */
        isPicking = NO;
        
        rootPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, BOTTOM_PICKER_VIEW_HEIGHT)];
//        [rootPickerView setHidden:YES];
        [rootPickerView setBackgroundColor:MAINCOLOR];
        rootPickerView.layer.zPosition = 901;
        
        UIView *viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40.0)];
        [viewTitle setBackgroundColor:MAINDEEPCOLOR];
        [rootPickerView addSubview:viewTitle];
        
        labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 100.0, 20.0)];
        [labelTitle setTextColor:[UIColor whiteColor]];
//        [labelTitle setBackgroundColor:[UIColor redColor]];
        [labelTitle setFont:[UIFont systemFontOfSize:TITLE_FONTSIZE]];
        [labelTitle setTextAlignment:NSTextAlignmentCenter];
        [viewTitle addSubview:labelTitle];
        
        arrowLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, (40 - ARROWICONSIZE) / 2.0, ARROWICONSIZE, ARROWICONSIZE)];
        [arrowLeft setImage:[UIImage imageNamed:@"arrowup"]];
        [viewTitle addSubview:arrowLeft];
        arrowRight = [[UIImageView alloc] initWithFrame:CGRectMake(0, (40 - ARROWICONSIZE) / 2.0, ARROWICONSIZE, ARROWICONSIZE)];
        [arrowRight setImage:[UIImage imageNamed:@"arrowup"]];
        [viewTitle addSubview:arrowRight];
        
        UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, 40, frame.size.width, 1.0)];
        [viewLine setBackgroundColor:[UIColor lightGrayColor]];
        [rootPickerView addSubview:viewLine];
        
        rootDataPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 41, frame.size.width, BOTTOM_PICKER_VIEW_HEIGHT - 41)];
        rootDataPicker.delegate = self;
        [rootDataPicker setHidden:YES];
        [rootPickerView addSubview:rootDataPicker];
        
        rootDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 41, frame.size.width, BOTTOM_PICKER_VIEW_HEIGHT - 41)];
        [rootPickerView addSubview:rootDatePicker];
        [rootDatePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:rootPickerView];
        
        viewTitle.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPickItem:)];
        [viewTitle addGestureRecognizer:singleTap];
    }
}

- (IBAction)onBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)datePickerChanged:(id)sender
{
    UIDatePicker * control = (UIDatePicker*)sender;
    NSDate* _date = control.date;
    if(_date < [NSDate date])
    {
        //[_absentDate setDate:[NSDate date]];
    }
    NSLog(@"date selected: %@", _date);
}

-(void)onCancelPickItem:(UIGestureRecognizer *)gestureRecognizer
{
    if(isPicking)
    {
        isPicking = !isPicking;
        [self drawBottomPicker];
        [self onHidePicker];
    }
}

- (void)onHidePicker
{
    
}

-(void)onPickItem:(UIGestureRecognizer *)gestureRecognizer
{
    isPicking = !isPicking;
    [self drawBottomPicker];
}

- (void)drawBottomPicker
{
    [self.view endEditing:YES];
    
    [self updatePickerTitle];
    if(pickerType & 0x01)
    {
        CGRect frame = [[UIScreen mainScreen] bounds];//self.view.frame;
        CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
        CGFloat hStatus = rectStatus.size.height;
        CGRect rectNav = self.navigationController.navigationBar.frame;
        CGFloat hNav = rectNav.size.height;
        CGRect rectTab = self.tabBarController.tabBar.frame;
        CGFloat hTab = rectTab.size.height;
        
        CGFloat h = BOTTOM_PICKER_VIEW_HEIGHT;
        CGFloat y = frame.size.height - h;
        
        if(self.navigationController != nil)
        {
            NSLog(@"with nav bar");
            y -= hNav;
            y -= hStatus;
        }
        if(self.tabBarController != nil && !self.tabBarController.tabBar.isHidden)
        {
            NSLog(@"with tab bar");
            y -= hTab;
        }
        if(isPicking)
        {
            NSLog(@"Start Pick");
            [arrowLeft setImage:[UIImage imageNamed:@"arrowdown"]];
            [arrowRight setImage:[UIImage imageNamed:@"arrowdown"]];
            
            [UIView setAnimationDelegate:self];
            [UIView beginAnimations:@"move" context:nil];
            //设定动画持续时间
            [UIView setAnimationDuration:0.15];
            //动画的内容
            CGRect vf = rootPickerView.frame;
            vf.origin.y = y / 2.0 - DEBUG_GAP;
            [rootPickerView setFrame:vf];
            //动画结束
            [UIView commitAnimations];
            [waitingCover setHidden:NO];
        }
        else
        {
            NSLog(@"End Pick");
            [arrowLeft setImage:[UIImage imageNamed:@"arrowup"]];
            [arrowRight setImage:[UIImage imageNamed:@"arrowup"]];
            
            [UIView setAnimationDelegate:self];
            [UIView beginAnimations:@"move" context:nil];
            //设定动画持续时间
            [UIView setAnimationDuration:0.15];
            //动画的内容
            CGRect vf = rootPickerView.frame;
            vf.origin.y = y + h - DEBUG_GAP;
            [rootPickerView setFrame:vf];
            //动画结束
            [UIView commitAnimations];
            [waitingCover setHidden:YES];
        }
    }
    if(pickerType & 0x02)
    {
        CGRect frame = [[UIScreen mainScreen] bounds];//self.view.frame;
        CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
        CGFloat hStatus = rectStatus.size.height;
        CGRect rectNav = self.navigationController.navigationBar.frame;
        CGFloat hNav = rectNav.size.height;
        CGRect rectTab = self.tabBarController.tabBar.frame;
        CGFloat hTab = rectTab.size.height;
        
        CGFloat h = BOTTOM_PICKER_VIEW_HEIGHT;
        CGFloat y = frame.size.height - h;
        
        if(self.navigationController != nil)
        {
            NSLog(@"with nav bar");
            y -= hNav;
            y -= hStatus;
        }
        if(self.tabBarController != nil && !self.tabBarController.tabBar.isHidden)
        {
            NSLog(@"with tab bar");
            y -= hTab;
        }
        if(isPicking)
        {
            NSLog(@"Start Pick");
            [arrowLeft setImage:[UIImage imageNamed:@"arrowdown"]];
            [arrowRight setImage:[UIImage imageNamed:@"arrowdown"]];
            
            [UIView setAnimationDelegate:self];
            [UIView beginAnimations:@"move" context:nil];
            //设定动画持续时间
            [UIView setAnimationDuration:0.15];
            //动画的内容
            CGRect vf = rootPickerView.frame;
            vf.origin.y = y - DEBUG_GAP;
            [rootPickerView setFrame:vf];
            //动画结束
            [UIView commitAnimations];
            [waitingCover setHidden:NO];
        }
        else
        {
            NSLog(@"End Pick");
            [arrowLeft setImage:[UIImage imageNamed:@"arrowup"]];
            [arrowRight setImage:[UIImage imageNamed:@"arrowup"]];
            
            [UIView setAnimationDelegate:self];
            [UIView beginAnimations:@"move" context:nil];
            //设定动画持续时间
            [UIView setAnimationDuration:0.15];
            //动画的内容
            CGRect vf = rootPickerView.frame;
            vf.origin.y = y + h - 40.0 - DEBUG_GAP;
            [rootPickerView setFrame:vf];
            //动画结束
            [UIView commitAnimations];
            [waitingCover setHidden:YES];
        }
    }
    
    if(isPicking)
    {
        [self startPickItem];
    }
    else
    {
        if([self pickerView:rootDataPicker numberOfRowsInComponent:0] > 0)
        {
            [self endPickItem];
        }
    }
}

- (void)startPickItem
{
    
}

- (void)endPickItem
{
    
}

- (void)onPickItem
{
    
}

- (void)setSelectRow:(NSInteger)index InComponent:(NSInteger)component
{
    [rootDataPicker selectRow:index inComponent:0 animated:NO];
}

- (NSInteger)selectedRowInComponent:(NSInteger)component
{
    return [rootDataPicker selectedRowInComponent:component];
}

- (void)setPickerDate:(NSDate *)date
{
    [rootDatePicker setDate:date];
//    [rootDatePicker reloadre]
}

- (void)startMiddleDatePickerWithFlag:(NSString *)flag ofTitle:(NSString *)title andFinish:(NSString *)finishTitle andMode:(UIDatePickerMode)mode object:(id)object
{
    [self setDatePickerObj:object];
    
    [rootDataPicker setHidden:YES];
    [rootDatePicker setHidden:NO];
    [rootDatePicker setDatePickerMode:mode];
    
    self.pickerFlag = flag;
    pickerTitle = title;
    pickerFinishTitle = finishTitle;
    
    pickerType |= 0x01;
    isPicking = YES;
    [rootPickerView setHidden:NO];
    [rootDataPicker selectRow:0 inComponent:0 animated:NO];
    [self drawBottomPicker];
    
    [rootDataPicker reloadAllComponents];
}

- (void)startBottomDatePickerWithFlag:(NSString *)flag ofTitle:(NSString *)title andFinish:(NSString *)finishTitle andMode:(UIDatePickerMode)mode object:(id)object
{
    [self setDatePickerObj:object];
    
    [rootDataPicker setHidden:YES];
    [rootDatePicker setHidden:NO];
    [rootDatePicker setDatePickerMode:mode];
    
    self.pickerFlag = flag;
    pickerTitle = title;
    pickerFinishTitle = finishTitle;
    
    pickerType |= 0x02;
    [rootPickerView setHidden:NO];
    [rootDataPicker selectRow:0 inComponent:0 animated:NO];
    [self drawBottomPicker];
    
    [rootDataPicker reloadAllComponents];
}

- (void)startMiddleDataPickerWithFlag:(NSString *)flag ofTitle:(NSString *)title andFinish:(NSString *)finishTitle andDefault:(int)def showValueTitle:(BOOL)isShow
{
    [rootDataPicker setHidden:NO];
    [rootDatePicker setHidden:YES];
    
    self.pickerFlag = flag;
    pickerTitle = title;
    pickerFinishTitle = finishTitle;
    
    pickerType |= 0x01;
    isPicking = YES;
    isShowValueTitle = isShow;
    [rootPickerView setHidden:NO];
    [self drawBottomPicker];
    
    [rootDataPicker reloadAllComponents];
    [rootDataPicker selectRow:def inComponent:0 animated:NO];
}

- (void)startBottomDataPickerWithFlag:(NSString *)flag ofTitle:(NSString *)title andFinish:(NSString *)finishTitle andDefault:(int)def showValueTitle:(BOOL)isShow
{
    [rootDataPicker setHidden:NO];
    [rootDatePicker setHidden:YES];
    
    self.pickerFlag = flag;
    pickerTitle = title;
    pickerFinishTitle = finishTitle;
    
    pickerType |= 0x02;
    [rootPickerView setHidden:NO];
    isShowValueTitle = isShow;
    [self drawBottomPicker];
    
    [rootDataPicker reloadAllComponents];
    [rootDataPicker selectRow:def inComponent:0 animated:NO];
}

- (void)reloadPicker
{
    [self updatePickerTitle];
    [rootDataPicker reloadAllComponents];
}

- (void)updatePickerTitle
{
    NSString *title = pickerTitle;
    if(isPicking)
    {
        title = pickerFinishTitle;
    }
    
    NSInteger count = [self pickerView:rootDataPicker numberOfRowsInComponent:0];
    if(count > 0 && isShowValueTitle)
    {
        NSInteger sel = [rootDataPicker selectedRowInComponent:0];
        title = [self pickerView:rootDataPicker titleForRow:sel forComponent:0];
    }
    
    [labelTitle setText:title];
    CGSize textSize = [title sizeWithFont:[UIFont systemFontOfSize:TITLE_FONTSIZE] constrainedToSize:CGSizeMake(320.0, 500.0) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect frame = labelTitle.frame;
    frame.origin.x = self.view.frame.size.width / 2.0 - textSize.width / 2.0;
    frame.size.width = textSize.width;
    [labelTitle setFrame:frame];
    
    CGRect lf = CGRectMake(frame.origin.x - ARROWICONSIZE - 6, arrowLeft.frame.origin.y, ARROWICONSIZE, ARROWICONSIZE);
    [arrowLeft setFrame:lf];
    CGRect lr = CGRectMake(frame.origin.x + frame.size.width + 6, arrowRight.frame.origin.y, ARROWICONSIZE, ARROWICONSIZE);
    [arrowRight setFrame:lr];
}

#pragma mark --- picker view delegate ---

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel)
    {
        pickerLabel = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        //adjustsFontSizeToFitWidth property to YES
        // pickerLabel.minimumFontSize = 8.;
        //        pickerLabel.minimumScaleFactor = 10.0;
        //        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:24]];
        
        [pickerLabel setTextColor:[UIColor whiteColor]];//[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:1.0]];
    }
    // Fill the label text here
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 0;
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return self.view.frame.size.width;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44.0;
}

// 选择事件
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"-- picker %@ select %ld", self.pickerFlag, [rootDataPicker selectedRowInComponent:component]);
    [self onPickItem];
}


//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return @"";
}

#pragma mark   ----触摸取消输入----
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"ViewController: %@ - viewWillAppear", self);
    
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"ViewController: %@ - viewDidAppear", self);
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"ViewController: %@ - viewWillDisappear", self);
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"ViewController: %@ - viewDidDisappear", self);
}

- (void)showSegueWithObject:(id)transObj Identifier:(NSString *)identifier
{
    if(transObj == nil)
    {
        [self performSegueWithIdentifier:identifier sender:nil];
    }
    else
    {
        if([self isEqual:transObj])
        {
            NSLog(@"************* retain self operation. trans **************");
        }
        
        // 不使用self.transObj和self.extraObj来传递参数trans, extra
        // 否则如果参数是self的话，会把self retain导致dealloc不调用
        //        [self setTransObj:trans];
        //        [self setExtraObj:extra];
        //        [self performSegueWithIdentifier:identifier sender:self];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:transObj, @"transObj", nil];
        [self performSegueWithIdentifier:identifier sender:dict];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController* vc = segue.destinationViewController;
    
    if([sender isKindOfClass:[NSDictionary class]] || [sender isKindOfClass:[NSMutableDictionary class]])
    {
        NSDictionary *dict = sender;
        [vc setValue:[dict objectForKey:@"transObj"] forKey:@"transObj"];
    }
    else
    {
        NSLog(@"===========root view controller sender isn't a dictionary.");
    }
}

- (BOOL)bindMsg:(NSString *)msg by:(id)observer
{
    if(regMsgList == nil)
    {
        regMsgList = [[NSMutableArray alloc] init];
    }
    if([regMsgList containsObject:msg] == YES) return NO;
    
    NSLog(@"Notify: %@ - Bind Msg:'%@'", self, msg);
    [regMsgList addObject:msg];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(onNotifyMsg:) name:msg object:nil];
    return YES;
}

- (void)ignoreMsg:(NSString *)msg
{
    RemoveMsg(msg);
    [regMsgList removeObject:msg];
}

- (void)dealloc
{
    NSLog(@"ViewController: %@ - dealloc", self);
//    [glState pop1ViewController:[NSString stringWithFormat:@"%@", self]];
    
    for(NSString *msg in regMsgList)
    {
        RemoveMsg(msg);
        NSLog(@"Notify: %@ - Remove Msg:'%@'", self, msg);
    }
    [regMsgList removeAllObjects];
}

- (void)onNotifyMsg:(NSNotification *)notification
{
    NSLog(@"Notify: %@ - deal Msg:'%@'", self, notification.name);
}

@end
