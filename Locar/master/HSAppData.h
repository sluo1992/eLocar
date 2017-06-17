//
//  HSAppData.h
//  HSIMApp
//
//  Created by han on 14/1/15.
//  Copyright (c) 2014年 han. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSAppData : NSObject

+ (void)setFirstStartup:(BOOL)b;
+ (BOOL)isFirstStartup;

+ (void)setBindBleName:(NSString *)s;
+ (NSString *)getBindBleName;
+ (void)setBindBleAddr:(NSString *)s andName:(NSString *)name;
+ (NSString *)getBindBleAddr;

+ (void)setFMChannel:(int)s;
+ (int)getFMChannel;

+ (BOOL)isUsingMetric;
+ (void)useMetric:(BOOL)b;

+ (BOOL)getTrackOn;
+ (void)setTrackOn:(BOOL)b;


+ (BOOL)getGpsAlert;
+ (void)setGpsAlert:(BOOL)b;
+ (BOOL)getTimerAlert;
+ (void)setTimerAlert:(BOOL)b;

+ (BOOL)getAudioAlert;
+ (void)setAudioAlert:(BOOL)b;

+ (void)saveBleList:(NSArray *)s;
+ (NSArray *)loadBleList;

@end
