//
//  CarLoc.m
//  Locar
//
//  Created by apple on 2017/5/21.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
//

#import "CarLoc.h"

@implementation CarLoc

//location VARCHAR, remark VARCHAR, blemac VARCHAR, dataguid INTEGER, lat REAL, long REAL, locimage BLOB)";

+ (CarLoc *)locFromDataSet:(FMResultSet *)rs
{
    CarLoc *aLoc = [[CarLoc alloc] init];
    
    [aLoc setStoreID:[rs objectForColumnName:@"_id"]];
    [aLoc setGuid:[rs objectForColumnName:@"dataguid"]];
    [aLoc setGenTime:[rs objectForColumnName:@"gentime"]];
    [aLoc setWhere:[rs stringForColumn:@"location"]];
    [aLoc setRemark:[rs stringForColumn:@"remark"]];
    [aLoc setBleMac:[rs stringForColumn:@"blemac"]];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:[[rs objectForColumnName:@"lat"] doubleValue] longitude:[[rs objectForColumnName:@"lon"] doubleValue]];
    
    [aLoc setLocation:loc];
    [aLoc setDataimage:[rs objectForColumnName:@"locimage"]];
    if([aLoc.dataimage isKindOfClass:[NSNull class]])
    {
        [aLoc setDataimage:nil];
    }
    return aLoc;
}

- (void)setGenTime:(NSNumber *)genTime
{
    _genTime = genTime;
//    self.genTime = genTime;
    
    if(genTime != nil)
    {
        NSDateFormatter* formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.oftime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:genTime.longValue]];
    }
}


- (void)dump
{
    NSLog(@"%@ %@ %@ %@ %@ %@ %@ %f-%f %ld bytes",
          self.storeID, self.guid, self.genTime, self.oftime, self.where, self.remark, self.bleMac, self.location.coordinate.latitude, self.location.coordinate.longitude, self.dataimage.length);
}

@end
