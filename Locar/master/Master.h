//
//  Master.h
//  Locar
//
//  Created by apple on 2017/5/16.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 数据包定义
 */
#define Constants_HEADER1           0
#define Constants_HEADER2           1
#define Constants_CMD               3
#define Constants_DATA              3


typedef unsigned char    byte;

@interface Master : NSObject

@property (nonatomic, retain) BLEMaster *bleMaster;
@property (nonatomic, assign) BOOL fmMode;
@property (nonatomic, assign) BOOL forbidden;
@property (nonatomic, assign) int verState;

+ (Master *)sharedInstance;

- (BOOL)bleAPI_getInfo;
- (BOOL)bleAPI_setFM:(int)fmChannel;
- (void)processCommand:(NSData *)nsdata;

- (void)speak:(NSString *)msg flag:(NSString *)flag;

@end
