//
//  RootViewController.h
//  dyhAutoApp
//
//  Created by apple on 15/5/25.
//  Copyright (c) 2015年 dayihua. All rights reserved.
//

#import <UIKit/UIKit.h>


//#define isIOS8              ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)
//#define isIOS7              ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)
#define fitIOS7             if(isIOS7)\
{\
self.navigationController.navigationBar.translucent = NO;\
}

#define roundIt(x)              [[x layer] setMasksToBounds:YES]; [[x layer] setCornerRadius:5.0]
#define roundcycle(x)           [[x layer] setMasksToBounds:YES]; [[x layer] setCornerRadius:x.frame.size.height / 2.0]
#define rounds(x)               [[x layer] setMasksToBounds:YES]; [[x layer] setCornerRadius:x.frame.size.height / 2.0 - 2]
#define roundMe(x,y)            [[x layer] setMasksToBounds:YES]; [[x layer] setCornerRadius:y]

@interface RootViewController : UIViewController
{
    NSMutableArray *regMsgList;
    
    UIView *waitingCover;
}

@property(nonatomic, retain) id transObj;
@property(nonatomic, retain) id datePickerObj;

@property(nonatomic, assign) BOOL syncFlag;

- (void)setPickerDate:(NSDate *)date;

@property(nonatomic, retain) NSString *pickerFlag;

- (NSString *)viewFlag;
- (void)setViewFlag:(NSString *)flag;

- (void)changeViewFont:(UIView *)view;
- (IBAction)onBack:(id)sender;

- (void)showSegueWithObject:(id)transObj Identifier:(NSString *)identifier;

- (void)ignoreMsg:(NSString *)msg;
- (BOOL)bindMsg:(NSString *)msg by:(id)observer;
- (void)onNotifyMsg:(NSNotification *)notification;


- (void)startMiddleDatePickerWithFlag:(NSString *)flag ofTitle:(NSString *)title andFinish:(NSString *)finishTitle andMode:(UIDatePickerMode)mode object:(id)object;
- (void)startBottomDatePickerWithFlag:(NSString *)flag ofTitle:(NSString *)title andFinish:(NSString *)finishTitle andMode:(UIDatePickerMode)mode object:(id)object;
- (void)startMiddleDataPickerWithFlag:(NSString *)flag ofTitle:(NSString *)title andFinish:(NSString *)finishTitle andDefault:(int)def showValueTitle:(BOOL)isShow;
- (void)startBottomDataPickerWithFlag:(NSString *)flag ofTitle:(NSString *)title andFinish:(NSString *)finishTitle andDefault:(int)def showValueTitle:(BOOL)isShow;


- (void)startPickItem;
- (void)endPickItem;
- (void)onPickItem;
- (void)onHidePicker;
- (void)reloadPicker;
- (NSInteger)selectedRowInComponent:(NSInteger)component;
- (void)setSelectRow:(NSInteger)index InComponent:(NSInteger)component;

@end
