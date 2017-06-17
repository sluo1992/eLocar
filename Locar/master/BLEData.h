//
//  BLEData.h
//  Locar
//
//  Created by apple on 2017/5/20.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLEData : NSObject

@property (nonatomic, assign) int fmVersion;
@property (nonatomic, assign) int bleFlag;
@property (nonatomic, assign) float FMChannel;
@property (nonatomic, assign) float chargeA;
@property (nonatomic, assign) float chargeV;
@property (nonatomic, assign) float outputV;

@end
