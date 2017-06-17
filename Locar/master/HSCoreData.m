//
//  HSCoreData.m
//  Locar
//
//  Created by apple on 2017/5/21.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
//

#import "HSCoreData.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

#define FMDBQuickCheck(SomeBool) { if (!(SomeBool)) { NSLog(@"Failure on line %d", __LINE__); abort(); } }
#define DB_PATH     [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingString:@"/chenhao_locar.db"]

@implementation HSCoreData

static HSCoreData *sharedInstance;

/**
 * The runtime sends initialize to each class in a program exactly one time just before the class,
 * or any class that inherits from it, is sent its first message from within the program. (Thus the
 * method may never be invoked if the class is not used.) The runtime sends the initialize message to
 * classes in a thread-safe manner. Superclasses receive this message before their subclasses.
 *
 * This method may also be called directly (assumably by accident), hence the safety mechanism.
 **/
+ (void)initialize
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        initialized = YES;
        
        sharedInstance = [[HSCoreData alloc] init];
    }
}

+ (HSCoreData *)sharedInstance
{
    return sharedInstance;
}

#pragma  mark profile table procees

- (FMDatabase *)checkLocationTable
{
    FMDatabase *db = [FMDatabase databaseWithPath:DB_PATH];
    if(![db open])
    {
        NSLog(@"数据库打开失败%@", DB_PATH);
        return nil;
    }
    NSString *strSQL = @"CREATE TABLE IF NOT EXISTS _tbloctable (_id INTEGER PRIMARY KEY AUTOINCREMENT, gentime INTEGER, location VARCHAR, remark VARCHAR, blemac VARCHAR, dataguid INTEGER, lat REAL, lon REAL, locimage BLOB)";
    BOOL worked = [db executeUpdate:strSQL];
    FMDBQuickCheck(worked);
    if(worked == YES) return db;
    return nil;
}

- (void)dumpLocationTable
{
    FMDatabase *db = [self checkLocationTable];
    if(db == nil) return;
    
    NSLog(@"-------------dump _tbloctable Table------------");
    FMResultSet *rs = [db executeQuery:@"select * from _tbloctable order by _id ASC"];
    while([rs next])
    {
        CarLoc *aLoc = [CarLoc locFromDataSet:rs];
        [aLoc dump];
    }
    [rs close];
    [db close];
    
    NSLog(@"--------------------------------------");
}

- (BOOL)dbRemoveProfile:(NSNumber *)storeID
{
    FMDatabase *db = [self checkLocationTable];
    if(db == nil) return NO;
    
    if([db executeUpdate:@"delete from _tbProfile where _id = ?", storeID] == NO)
    {
        NSLog(@"delete from table failed. id = %@", storeID);
        return NO;
    }
    return YES;
}

- (CarLoc *)lastLocation
{
    FMDatabase *db = [self checkLocationTable];
    if(db == nil) return nil;
    
    FMResultSet *rs = [db executeQuery:@"select * from _tbloctable order by _id DESC LIMIT 1"];
    while([rs next])
    {
        CarLoc *aLoc = [CarLoc locFromDataSet:rs];
        [aLoc dump];
        [rs close];
        [db close];
        return aLoc;
    }
    [rs close];
    [db close];
    return nil;
}

- (CarLoc *)prevLocation:(NSNumber *)index
{
    FMDatabase *db = [self checkLocationTable];
    if(db == nil) return nil;
    
    FMResultSet *rs = [db executeQuery:@"select * from _tbloctable where _id < ? order by _id DESC LIMIT 1", index];
    while([rs next])
    {
        CarLoc *aLoc = [CarLoc locFromDataSet:rs];
        [aLoc dump];
        [rs close];
        [db close];
        return aLoc;
    }
    [rs close];
    [db close];
    return nil;
}

- (CarLoc *)nextLocation:(NSNumber *)index
{
    FMDatabase *db = [self checkLocationTable];
    if(db == nil) return nil;
    
    FMResultSet *rs = [db executeQuery:@"select * from _tbloctable where _id > ? order by _id ASC LIMIT 1", index];
    while([rs next])
    {
        CarLoc *aLoc = [CarLoc locFromDataSet:rs];
        [aLoc dump];
        [rs close];
        [db close];
        return aLoc;
    }
    [rs close];
    [db close];
    return nil;
}

- (NSArray *)parkList
{
    FMDatabase *db = [self checkLocationTable];
    if(db == nil) return nil;
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    FMResultSet *rs = [db executeQuery:@"select * from _tbloctable order by _id DESC"];
    while([rs next])
    {
        CarLoc *aLoc = [CarLoc locFromDataSet:rs];
        [list addObject:aLoc];
    }
    [rs close];
    [db close];
    return list;
}

- (BOOL)dbAddCarLocation:(CarLoc *)aLoc
{
    FMDatabase *db = [self checkLocationTable];
    if(db == nil) return NO;
    
    if(aLoc.storeID != nil)
    {
        BOOL bExist = NO;
        FMResultSet *rs = [db executeQuery:@"select * from _tbloctable where _id = ?", aLoc.storeID];
        while([rs next])
        {
            bExist = YES;
            break;
        }
        [rs close];
        if(bExist)
        {
            [db executeUpdate:@"delete from _tbloctable where _id = ?", aLoc.storeID];
        }
        
        // into Database
        // 44 parameters
        BOOL bOK = [db executeUpdate:@"INSERT INTO _tbloctable (_id, gentime, location, remark, blemac, dataguid, lat, lon, locimage) VALUES(?,?,?,?,?,?,?,?,?)", aLoc.storeID, aLoc.genTime, aLoc.where, aLoc.remark, aLoc.bleMac, aLoc.guid, [NSNumber numberWithDouble:aLoc.location.coordinate.latitude], [NSNumber numberWithDouble:aLoc.location.coordinate.longitude], aLoc.dataimage];
        [db close];
        
        return bOK;
    }
    else
    {
        // into Database
        // 44 parameters
        BOOL bOK = [db executeUpdate:@"INSERT INTO _tbloctable (gentime, location, remark, blemac, dataguid, lat, lon, locimage) VALUES(?,?,?,?,?,?,?,?)",
                    aLoc.genTime, aLoc.where, aLoc.remark, aLoc.bleMac, aLoc.guid, [NSNumber numberWithDouble:aLoc.location.coordinate.latitude], [NSNumber numberWithDouble:aLoc.location.coordinate.longitude], aLoc.dataimage];
        [db close];
        
        return bOK;
    }
}

@end
