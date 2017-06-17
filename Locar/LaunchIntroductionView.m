//
//  LaunchIntroductionView.m
//  ZYGLaunchIntroductionDemo
//
//  Created by ZhangYunguang on 16/4/7.
//  Copyright © 2016年 ZhangYunguang. All rights reserved.
//

#import "LaunchIntroductionView.h"
#import "ViewControllerMain.h"

@interface LaunchIntroductionView ()<UIScrollViewDelegate>
{
    UIScrollView  *launchScrollView;
    UIPageControl *page;
}

@end

@implementation LaunchIntroductionView

NSArray *images;
CGRect enterBtnFrame;
NSString *enterBtnImage;
static LaunchIntroductionView *launch = nil;
NSString *storyboard;
BOOL isScrollOut;//在最后一页再次滑动是否隐藏引导页

#pragma mark - 用storyboard创建的项目时调用，不带button
+ (instancetype)sharedWithStoryboardName:(NSString *)storyboardName images:(NSArray *)imageNames {
    images = imageNames;
    storyboard = storyboardName;
    isScrollOut = YES;
    launch = [[LaunchIntroductionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_width, kScreen_height)];
    launch.backgroundColor = [UIColor whiteColor];
    return launch;
}
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
            [self addObserver:self forKeyPath:@"currentColor" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"nomalColor" options:NSKeyValueObservingOptionNew context:nil];
            UIStoryboard *story = [UIStoryboard storyboardWithName:storyboard bundle:nil];
            UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
            UIViewController *vc = story.instantiateInitialViewController;
            window.rootViewController = vc;
            [vc.view addSubview:self];
            [self addImages];
    }
    return self;
}

#pragma mark - 添加引导页图片
-(void)addImages{
    [self createScrollView];
}
#pragma mark - 创建滚动视图
-(void)createScrollView{
    launchScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_width, kScreen_height)];
    launchScrollView.showsHorizontalScrollIndicator = NO;
    launchScrollView.bounces = NO;
    launchScrollView.pagingEnabled = YES;
    launchScrollView.delegate = self;
    launchScrollView.contentSize = CGSizeMake(kScreen_width * images.count, kScreen_height);
    [self addSubview:launchScrollView];
    for (int i = 0; i < images.count; i ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * kScreen_width, 0, kScreen_width, kScreen_height)];
        imageView.image = [UIImage imageNamed:images[i]];
        [launchScrollView addSubview:imageView];
        if (i == images.count-1) {
            //判断要不要添加button
                CGSize size = [UIScreen mainScreen].bounds.size;
                UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
                enterButton.bounds = CGRectMake(0, 0, 150, 40);
                enterButton.center = CGPointMake(size.width/2, size.height - 100);
                enterButton.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0.8];
                enterButton.layer.cornerRadius = 5;
                enterButton.clipsToBounds = YES;
                [enterButton setTitle:@"立即体验" forState:UIControlStateNormal];
                [enterButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [enterButton addTarget:self action:@selector(enterBtnClick) forControlEvents:UIControlEventTouchUpInside];
                [imageView addSubview:enterButton];
                imageView.userInteractionEnabled = YES;
        }
    }
    page = [[UIPageControl alloc] initWithFrame:CGRectMake(0, kScreen_height - 50, kScreen_width, 30)];
    page.numberOfPages = images.count;
    page.backgroundColor = [UIColor clearColor];
    page.currentPage = 0;
    page.defersCurrentPageDisplay = YES;
    [self addSubview:page];
}
#pragma mark - 进入按钮
-(void)enterBtnClick{
    [self hideGuidView];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setBool:YES forKey:kAppVersion];
    NSLog(@"versiond %d",[user boolForKey:kAppVersion]);
    [user setBool:YES forKey:kAppGuide];
    [user synchronize];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewControllerMain *main = [story instantiateViewControllerWithIdentifier:@"ViewControllerMain"];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    window.rootViewController = main;

    
}
#pragma mark - 隐藏引导页
-(void)hideGuidView{
    
    [UIView animateWithDuration:0.5 animations:^{
//        self.alpha = 0;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
    
//        });
    }];
}
#pragma mark - scrollView Delegate
//-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    int cuttentIndex = (int)(scrollView.contentOffset.x + kScreen_width/2)/kScreen_width;
//    if (cuttentIndex == images.count - 1) {
//        if ([self isScrolltoLeft:scrollView]) {
//            if (!isScrollOut) {
//                return ;
//            }
//        }
//    }
//}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == launchScrollView) {
        int cuttentIndex = (int)(scrollView.contentOffset.x + kScreen_width/2)/kScreen_width;
        page.currentPage = cuttentIndex;
    }
}
#pragma mark - 判断滚动方向
-(BOOL )isScrolltoLeft:(UIScrollView *) scrollView{
    //返回YES为向左反动，NO为右滚动
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].x < 0) {
        return YES;
    }else{
        return NO;
    }
}
#pragma mark - KVO监测值的变化
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"currentColor"]) {
        page.currentPageIndicatorTintColor = self.currentColor;
    }
    if ([keyPath isEqualToString:@"nomalColor"]) {
        page.pageIndicatorTintColor = self.nomalColor;
    }
}

@end
