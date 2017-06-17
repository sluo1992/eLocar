//
//  HSCoreData.h
//  Locar
//
//  Created by apple on 2017/5/21.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSCoreData : NSObject

+ (HSCoreData *)sharedInstance;

- (void)dumpLocationTable;
- (BOOL)dbRemoveProfile:(NSNumber *)storeID;

- (BOOL)dbAddCarLocation:(CarLoc *)aLoc;

- (CarLoc *)lastLocation;
- (CarLoc *)prevLocation:(NSNumber *)index;
- (CarLoc *)nextLocation:(NSNumber *)index;

- (NSArray *)parkList;

@end
