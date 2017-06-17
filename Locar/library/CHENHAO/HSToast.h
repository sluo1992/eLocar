//
//  HSToast.h
//  FreeWavzApp
//
//  Created by apple on 17/1/25.
//  Copyright © 2017年 ChenHao Intelligent. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_DISPLAY_DURATION 2.0f

@interface HSToast : NSObject
{
    NSString *text;
    UIButton *contentView;
    CGFloat  duration;
}

+ (void)showToastWithText:(NSString *) text_;
+ (void)showToastWithText:(NSString *) text_ duration:(CGFloat)duration_;

+ (void)showToastWithText:(NSString *) text_ topOffset:(CGFloat) topOffset_;
+ (void)showToastWithText:(NSString *) text_ topOffset:(CGFloat) topOffset duration:(CGFloat) duration_;

+ (void)showToastWithText:(NSString *) text_ bottomOffset:(CGFloat) bottomOffset_;
+ (void)showToastWithText:(NSString *) text_ bottomOffset:(CGFloat) bottomOffset_ duration:(CGFloat) duration_;

@end
