//
//  HSAppData.m
//  HSIMApp
//
//  Created by han on 14/1/15.
//  Copyright (c) 2014年 han. All rights reserved.
//

#import "HSAppData.h"

@implementation HSAppData


//Change from
//[[NSUserDefaults alloc] initWithSuiteName:@"group.com.xxx.xxx"];
//to
//[[NSUserDefaults alloc] initWithSuiteName:@"nnnnnnnnnn.group.com.xxx.xxx"];

//#define def [[NSUserDefaults alloc] initWithSuiteName:@"com.chenhao.FreeWavzApp"]

+ (void)setFirstStartup:(BOOL)b
{
    [[NSUserDefaults standardUserDefaults] setBool:!b forKey:@"firstStartup"];
    //立刻保存信息
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isFirstStartup
{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:@"firstStartup"];
}

+ (void)setBindBleName:(NSString *)s
{
    [[NSUserDefaults standardUserDefaults] setObject:s forKey:@"getBindBleName"];
    //立刻保存信息
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getBindBleName
{
    //    return @"13000000004";
    NSString *result = [[NSUserDefaults standardUserDefaults] objectForKey:@"getBindBleName"];
    return result;
}

+ (void)setBindBleAddr:(NSString *)s andName:(NSString *)name
{
//    return;
    [[NSUserDefaults standardUserDefaults] setObject:s forKey:@"bleaddr"];
    //立刻保存信息
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [HSAppData setBindBleName:name];
}

+ (NSString *)getBindBleAddr
{
    //    return @"13000000004";
    NSString *result = [[NSUserDefaults standardUserDefaults] objectForKey:@"bleaddr"];
    return result;
}

+ (int)getFMChannel
{
    NSInteger s = [[NSUserDefaults standardUserDefaults] integerForKey:@"getFMChannel"];
    return (int)s;
}

+ (void)setFMChannel:(int)s
{
    [[NSUserDefaults standardUserDefaults] setInteger:s forKey:@"getFMChannel"];
    //立刻保存信息
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isUsingMetric
{
    BOOL b = [[NSUserDefaults standardUserDefaults] boolForKey:@"isUsingBritish"];
    return !b;
}

+ (void)useMetric:(BOOL)b
{
    [[NSUserDefaults standardUserDefaults] setBool:!b forKey:@"isUsingBritish"];
    //立刻保存信息
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getTrackOn
{
    BOOL b = [[NSUserDefaults standardUserDefaults] boolForKey:@"getTrackOn"];
    return !b;
}

+ (void)setTrackOn:(BOOL)b
{
    [[NSUserDefaults standardUserDefaults] setBool:!b forKey:@"getTrackOn"];
    //立刻保存信息
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getGpsAlert
{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:@"getGpsAlert"];
}

+ (void)setGpsAlert:(BOOL)b
{
    [[NSUserDefaults standardUserDefaults] setBool:!b forKey:@"getGpsAlert"];
    //立刻保存信息
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getTimerAlert
{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:@"getTimerAlert"];
}

+ (void)setTimerAlert:(BOOL)b
{
    [[NSUserDefaults standardUserDefaults] setBool:!b forKey:@"getTimerAlert"];
    //立刻保存信息
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getAudioAlert
{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:@"getAudioAlert"];
}

+ (void)setAudioAlert:(BOOL)b
{
    [[NSUserDefaults standardUserDefaults] setBool:!b forKey:@"getAudioAlert"];
    //立刻保存信息
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveBleList:(NSArray *)s
{
    [[NSUserDefaults standardUserDefaults] setObject:s forKey:@"loadBleList"];
    //立刻保存信息
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)loadBleList
{
    //    return @"13000000004";
    NSArray *result = [[NSUserDefaults standardUserDefaults] objectForKey:@"loadBleList"];
    return result;
}

@end

