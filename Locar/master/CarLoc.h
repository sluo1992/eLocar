//
//  CarLoc.h
//  Locar
//
//  Created by apple on 2017/5/21.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "FMResultSet.h"

@interface CarLoc : NSObject
//location VARCHAR, remark VARCHAR, blemac VARCHAR, dataguid INTEGER, lat REAL, long REAL, locimage BLOB)";
@property (nonatomic, retain) NSNumber *storeID;
@property (nonatomic, retain) NSNumber *guid;
@property (nonatomic, retain) NSNumber *genTime; /// [[NSDate date] timeIntervalSince1970];
@property (nonatomic, retain) NSString *oftime;
@property (nonatomic, retain) NSString *bleMac;
@property (nonatomic, retain) NSString *remark;
@property (nonatomic, retain) NSString *where;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSData *dataimage;

+ (CarLoc *)locFromDataSet:(FMResultSet *)rs;

- (void)dump;

@end
