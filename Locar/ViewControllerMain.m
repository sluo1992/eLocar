//
//  ViewControllerMain.m
//  Locar
//
//  Created by apple on 2017/5/16.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
//5ab16229f3443932d5d501347fb878970204d7b3
//0c19d8ed3072047caf9638c9a47f55c4c42d18ba

#import "ViewControllerMain.h"
#import "XHRadarView.h"
#import "AIMBalloon.h"
#import <ifaddrs.h>
#import <net/if.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#define pi 3.14159265358979323846
#define degreesToRadian(x) (pi * x / 180.0)
#define radiansToDegrees(x) (180.0 * x / pi)
@interface ViewControllerMain () <UIAlertViewDelegate>
{
    CGFloat panAngle;
    CGFloat hasRotate;
    CGPoint ptTouch;
    int nCount;
    
    int fmChannel;
    NSArray *listFM;
    NSTimer *workerTimer;
    BOOL guide; //!< 是否开启指引
}

@property (weak, nonatomic) IBOutlet UIView *viewRadio;
@property (weak, nonatomic) IBOutlet UIView *viewRadar;
@property (weak, nonatomic) IBOutlet UIImageView *insideImageView;
@property (weak, nonatomic) IBOutlet UIImageView *outsideImageView;

@property (weak, nonatomic) IBOutlet UIImageView *roundPicker;
@property (weak, nonatomic) IBOutlet UILabel *labelFM;
@property (weak, nonatomic) IBOutlet UILabel *labelChargeA;
@property (weak, nonatomic) IBOutlet UILabel *labelChargeV;
@property (weak, nonatomic) IBOutlet UILabel *labelOutputV;
@property (weak, nonatomic) IBOutlet UIButton *btFindCar;
@property (weak, nonatomic) IBOutlet UIButton *btBleState;
@property (weak, nonatomic) IBOutlet UIImageView *imageRadio;
@property (weak, nonatomic) IBOutlet UILabel *labelTip;

@end

@implementation ViewControllerMain

- (IBAction)onConfig:(id)sender
{
    [_Master bleAPI_getInfo];
}

#define USEFONT                 @"Neogrey" // Aero  DigifaceWide  Neogrey
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MasterBle;
    
    self.btFindCar.layer.masksToBounds = YES;
    self.btFindCar.layer.cornerRadius = self.btFindCar.frame.size.height / 2.0;
    self.btBleState.layer.masksToBounds = YES;
    self.btBleState.layer.cornerRadius = self.btBleState.frame.size.height / 2.0;
    [self.btBleState.layer setBorderWidth:1.0];
    [self.btBleState.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    [self.imageRadio setAnimationImages:@[[UIImage imageNamed:@"radio_0"], [UIImage imageNamed:@"radio_1"], [UIImage imageNamed:@"radio_2"], [UIImage imageNamed:@"radio_3"]]];
    [self.imageRadio setAnimationDuration:2.4f];
    [self.imageRadio startAnimating];
    
    [self.btFindCar addTarget:self action:@selector(button1BackGroundNormal:) forControlEvents:UIControlEventTouchUpInside];
    [self.btFindCar addTarget:self action:@selector(button1BackGroundNormal:) forControlEvents:UIControlEventTouchUpOutside];

    self.viewRadar.backgroundColor = [UIColor clearColor];
    
    // 扫描启动
//    [self.viewRadar setup];
    
    [self.labelTip setHidden:YES];
    if(_Master.forbidden)
    {
        [self.btBleState setHidden:YES];
    }
    
    [self.labelFM setFont:[UIFont fontWithName:@"DigifaceWide" size:16.0]];
    [self.labelChargeA setFont:[UIFont fontWithName:@"DigifaceWide" size:14.0]];
    [self.labelChargeV setFont:[UIFont fontWithName:@"DigifaceWide" size:14.0]];
    [self.labelOutputV setFont:[UIFont fontWithName:@"DigifaceWide" size:14.0]];
    [self.viewRadar setHidden:NO];
    [self.viewRadio setHidden:YES];
    
    [self.roundPicker setUserInteractionEnabled:YES];
    [self.roundPicker setMultipleTouchEnabled:YES];
    
    listFM = @[@87.5, @90.0, @100.0, @102.0, @104.0, @105.7, @107.1, @108.0];
    nCount = 8;
    hasRotate = 0.0;
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.roundPicker addGestureRecognizer:panGestureRecognizer];
    
    fmChannel = [HSAppData getFMChannel];
    hasRotate = -fmChannel * (360.0 / nCount);
    [self.labelFM setText:[NSString stringWithFormat:@"%.1f", [[listFM objectAtIndex:fmChannel] floatValue]]];
    [self.roundPicker setImage:[UIImage imageNamed:[NSString stringWithFormat:@"FM_%d", fmChannel]]];
    self.roundPicker.transform = CGAffineTransformRotate(self.roundPicker.transform, hasRotate * pi / 180);
    
    [self.labelChargeA setText:@""];
    [self.labelChargeV setText:@""];
    [self.labelOutputV setText:@""];
    
    CareMsg(msgBleDeviceFound);
    CareMsg(msgBleDeviceGone);
    CareMsg(msgBleGotInfo);
    CareMsg(msgBleOfflineLocation);
    CareMsg(@"msgAppVersion");
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    BOOL gui = [user boolForKey:kAppGuide];
    if (gui == YES) {
        guide = YES;
        [self createGuideImageView:guide];
        [user setBool:NO forKey:kAppGuide];
        [user synchronize];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self startRadarAnimation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self testCarLoc];

}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopRadarAnimation];
}

- (void)startRadarAnimation {
    CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"transform"];
    anima.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2, 0, 0, 1.0)];
    anima.cumulative = YES;
    anima.duration = 1;
    anima.repeatCount = MAXFLOAT;
    anima.removedOnCompletion = NO;

    [self.insideImageView.layer addAnimation:anima forKey:@"RadarRotation"];
    
    CABasicAnimation *anima1 = [CABasicAnimation animationWithKeyPath:@"transform"];
    anima1.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation( M_PI_2 * -1, 0, 0, 1.0)];
    anima1.cumulative = YES;
    anima1.duration = 1;
    anima1.repeatCount = MAXFLOAT;
    anima1.removedOnCompletion = NO;
    [self.outsideImageView.layer addAnimation:anima1 forKey:@"RadarRotation"];
}

- (void)stopRadarAnimation {
    [self.insideImageView.layer removeAnimationForKey:@"RadarRotation"];
    [self.outsideImageView.layer removeAnimationForKey:@"RadarRotation"];

}

- (void)tap:(UITapGestureRecognizer *)tap{
    [UIView animateWithDuration:0.5 animations:^{
        [tap.view removeFromSuperview];
    }];
}

// 创建指引
- (void)createGuideImageView:(BOOL)para{
    if (para == YES) {
        for (int i = 0; i <2; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"guide%d",i+1]];
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            [imageView addGestureRecognizer:tap];
            [self.view addSubview:imageView];
        }
    }
    guide = NO;

}
- (BOOL) isWiFiEnabled
{
    NSCountedSet * cset = [NSCountedSet new];
    
    struct ifaddrs *interfaces;
    
    if(!getifaddrs(&interfaces) )
    {
        for(struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next)
        {
            if((interface->ifa_flags & IFF_UP) == IFF_UP )
            {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}

//  button1普通状态下的背景色
- (void)button1BackGroundNormal:(UIButton *)sender
{
    if(_Master.forbidden)
    {
        [_Master speak:@"permission denied." flag:@"sys"];
        return;
    }
    
    [[HSCoreData sharedInstance] dumpLocationTable];
    
    CarLoc *aLoc = [[HSCoreData sharedInstance] lastLocation];
    [self showSegueWithObject:aLoc Identifier:@"showMapView"];
    
}

- (void)onNotifyMsg:(NSNotification *)notification
{
    [super onNotifyMsg:notification];
    
    NSString *msg = [NSString stringWithString:notification.name];
    
    NSLog(@"on notify : %@", msg);
    if([msg isEqualToString:msgBleDeviceFound])
    {
        [self.btBleState.layer setBorderWidth:0];
        [self.btBleState.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.btBleState setBackgroundColor:[UIColor colorWithRed:39/255.0 green:171/255.0 blue:169/255.0 alpha:1.0]];
        
        [self.btBleState setTitle:@" 设备已连接" forState:UIControlStateNormal];
        [self.btBleState setImage:[UIImage imageNamed:@"bleon"] forState:UIControlStateNormal];
        
        [self stopRadarAnimation];
        [self.viewRadar setHidden:YES];
        
        [self.viewRadio setHidden:NO];
        
        NSDictionary *dict = notification.object;
        if([[dict objectForKey:@"hasFM"] isEqualToString:@"YES"])
        {
            if(workerTimer != nil)
            {
                [workerTimer invalidate];
                workerTimer = nil;
            }
            if(workerTimer == nil)
            {
                NSLog(@"start red ble info");
                [self onTimer:nil];
                workerTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
            }
            [self.viewRadio setHidden:NO];
            [self.labelTip setHidden:YES];
        }
        else
        {
            [self.viewRadio setHidden:YES];
            [self.labelTip setHidden:NO];
        }
        [_Master speak:@"蓝牙已连接" flag:@"ble"];
    }
    else if([msg isEqualToString:msgBleDeviceGone])
    {
        [self.btBleState.layer setBorderWidth:1.0];
        [self.btBleState.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        [self.btBleState setBackgroundColor:[UIColor clearColor]];
        
        [self.btBleState setTitle:@" 设备未连接" forState:UIControlStateNormal];
        [self.btBleState setImage:[UIImage imageNamed:@"bleoff"] forState:UIControlStateNormal];
        
        [self startRadarAnimation];
        [self.viewRadar setHidden:NO];
        [self.viewRadio setHidden:YES];
        [self.labelTip setHidden:YES];
        
        if(workerTimer != nil)
        {
            [workerTimer invalidate];
            workerTimer = nil;
        }
        [_Master speak:@"蓝牙已断开" flag:@"ble"];
    }
    else if([msg isEqualToString:msgBleGotInfo])
    {
        BLEData *bleData = notification.object;
        if(bleData != nil)
        {
            if(bleData.chargeA == 0.0f)
            {
                [self.labelChargeA setHidden:YES];
                [self.labelChargeV setHidden:YES];
            }
            else
            {
                [self.labelChargeA setHidden:NO];
                [self.labelChargeV setHidden:NO];
                [self.labelChargeA setText:[NSString stringWithFormat:@"充电电流：%.2f A", bleData.chargeA]];
                [self.labelChargeV setText:[NSString stringWithFormat:@"充电电压：%.1f V", bleData.chargeV]];
            }
            [self.labelOutputV setText:[NSString stringWithFormat:@"输出电压：%.1f V", bleData.outputV]];
            
            
            int fIndex = 0;
            for(NSNumber *n in listFM)
            {
                if(n.floatValue == bleData.FMChannel)
                {
                    if(fIndex != fmChannel)
                    {
                        fmChannel = fIndex;
                        hasRotate = -fmChannel * (360.0 / nCount);
                        [self.labelFM setText:[NSString stringWithFormat:@"%.1f", [[listFM objectAtIndex:fmChannel] floatValue]]];
                        [self.roundPicker setImage:[UIImage imageNamed:[NSString stringWithFormat:@"FM_%d", fmChannel]]];
                        self.roundPicker.transform = CGAffineTransformMakeRotation(hasRotate * pi / 180);
                        panAngle = hasRotate;
                        
                        NSLog(@"fm index:%d - %.1f button %.2f", fIndex, bleData.FMChannel, hasRotate);
                        
                        [_Master speak:[NSString stringWithFormat:@"FM已设置为: %.1f兆赫", bleData.FMChannel] flag:@"fm"];
                        break;
                    }
                }
                fIndex++;
            }
        }
    }
    // 蓝牙断开连接
    else if([msg isEqualToString:msgBleOfflineLocation])
    {
        if(notification.object != nil)
        {
            CarLoc *aLoc = notification.object;
            [self showSegueWithObject:aLoc Identifier:@"showMapView"];
            
            
            [_Master speak:[NSString stringWithFormat:@"停车位置已记录: %@", aLoc.where] flag:@"location"];
        }
    }
    else if([msg isEqualToString:@"msgAppVersion"])
    {
        [self processVersion];
    }
}

- (void)processVersion
{
    if(_Master.verState != 0)
    {
        if(_Master.verState == 1)
        {
            UIAlertView * messageBox = [[UIAlertView alloc] initWithTitle: @"发现新版本."
                                                                  message: @"当前版本还可以继续使用.\n但建议您更新至最新版本以获得更好的使用体验."
                                                                 delegate: self
                                                        cancelButtonTitle: @"更新"
                                                        otherButtonTitles: @"取消", nil];
            [messageBox show];
        }
        else if(_Master.verState == 2)
        {
            UIAlertView * messageBox = [[UIAlertView alloc] initWithTitle: @"发现新版本."
                                                                  message: @"已发布新版本，当前版本已无法继续使用，点击更新。"
                                                                 delegate: self
                                                        cancelButtonTitle: @"确定"
                                                        otherButtonTitles: nil];
            [messageBox show];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == nil) return;
    {
        switch (buttonIndex)
        {
            case 0:
                if(1)
                {
                    // 设置个变量，在login里面显示这个窗口，而且打开app store
                    
//                    NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/hu-dong-xiao-yuan/id847422747?mt=8"];
                    NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/ilocar/id1240821834?l=zh&ls=1&mt=8"];
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                }
                break;
            case 1:
                break;
            default:
                break;
        }
    }
}

- (void)testCarLoc
{
    CarLoc *aLoc = [[HSCoreData sharedInstance] lastLocation];
    
    [self.btFindCar setHidden:(aLoc == nil)];
    
}

-(void)onTimer:(id)sender
{
    if([MasterBle isBleConnect])
    {
        [_Master bleAPI_getInfo];
    }
}

CGFloat distanceBetweenPoints (CGPoint first, CGPoint second)
{
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY );
}

CGFloat angleBetweenPoints(CGPoint first, CGPoint second)
{
    CGFloat height = second.y - first.y;
    CGFloat width = first.x - second.x;
    CGFloat rads = atan(height/width);
    rads = rads * 180 / pi;
    if(second.x > first.x && second.y <= first.y)
    {
        rads = 90 - rads;
    }
    else if(second.x > first.x && second.y > first.y)
    {
        rads = 90 + (rads * -1);
    }
    else if(second.x <= first.x && second.y >= first.y)
    {
        rads = 180 + (90 - rads);
    }
    else if(second.x <= first.x && second.y < first.y)
    {
        rads = 270 + (rads * -1);
    }
    return rads;
}


CGFloat angleBetweenLines(CGPoint line1Start, CGPoint line1End, CGPoint line2Start, CGPoint line2End)
{
    
    CGFloat a = line1End.x - line1Start.x;
    CGFloat b = line1End.y - line1Start.y;
    CGFloat c = line2End.x - line2Start.x;
    CGFloat d = line2End.y - line2Start.y;
    
    CGFloat rads = acos(((a*c) + (b*d)) / ((sqrt(a*a + b*b)) * (sqrt(c*c + d*d))));
    
    return radiansToDegrees(rads);
    
}

// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint center = view.center;
        CGPoint location = [panGestureRecognizer locationInView:view.superview];
        panAngle = angleBetweenPoints(center, location);
        NSLog(@"start     (%.1f:%.1f %.1f:%.1f)    %.2f", center.x, center.y, location.x, location.y, panAngle);
    }
    else if(panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint center = view.center;
        CGPoint location = [panGestureRecognizer locationInView:view.superview];
        CGFloat angle = angleBetweenPoints(center, location);
        CGFloat changed = angle - panAngle;
        view.transform = CGAffineTransformRotate(view.transform, changed * pi / 180);
        hasRotate += changed;
        panAngle = angle;
        
        
        CGFloat tick = 360 / (float)nCount;
        changed = 0.0;
        int nStep = 0;
        if(hasRotate >= 0)
        {
            nStep = (int)(hasRotate / tick + 0.5);
            CGFloat angle = nStep * tick;
            changed = angle - hasRotate;
            nStep = nStep % nCount;
        }
        else
        {
            CGFloat hasR = hasRotate * -1;
            nStep = (int)(hasR / tick + 0.5);
            CGFloat angle = - nStep * tick;
            changed = angle - hasRotate;
            nStep *= -1;
            while(1)
            {
                nStep += nCount;
                if(nStep >= 0) break;
            }
        }
        nStep = nCount - nStep;
        if(nStep == nCount) nStep = 0;
        
        NSLog(@"button value: %d, %.2f", nStep, hasRotate);
        [self.roundPicker setImage:[UIImage imageNamed:[NSString stringWithFormat:@"FM_%d", nStep]]];
    }
    else if(panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        CGFloat tick = 360 / (float)nCount;
        CGFloat changed = 0.0;
        int nStep = 0;
        if(hasRotate >= 0)
        {
            nStep = (int)(hasRotate / tick + 0.5);
            CGFloat angle = nStep * tick;
            changed = angle - hasRotate;
            nStep = nStep % nCount;
        }
        else
        {
            CGFloat hasR = hasRotate * -1;
            nStep = (int)(hasR / tick + 0.5);
            CGFloat angle = - nStep * tick;
            changed = angle - hasRotate;
            nStep *= -1;
            while(1)
            {
                nStep += nCount;
                if(nStep >= 0) break;
            }
        }
        nStep = nCount - nStep;
        if(nStep == nCount) nStep = 0;
        
        view.transform = CGAffineTransformRotate(view.transform, changed * pi / 180);
        hasRotate += changed;
        
        NSLog(@"button value: %d, %.2f", nStep, hasRotate);
        [self.roundPicker setImage:[UIImage imageNamed:[NSString stringWithFormat:@"FM_%d", nStep]]];
        fmChannel = nStep;
        [HSAppData setFMChannel:nStep];
        
        float fm = [[listFM objectAtIndex:fmChannel] floatValue];
        [self.labelFM setText:[NSString stringWithFormat:@"%.1f", fm]];
        
        [_Master bleAPI_setFM:(int)(fm * 10)];
        [_Master speak:[NSString stringWithFormat:@"FM已设置为: %.1f兆赫", fm] flag:@"fm"];
    }
    [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
}

@end
