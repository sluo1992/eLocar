//
//  BLEMaster.h
//  dyhBleAssit
//
//  Created by CShan on 15/3/19.
//  Copyright (c) 2015年 dayihua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define msgBleEnumDevice                @"msgBleEnumDevice"
#define msgBleDeviceFound               @"msgBleDeviceFound"
#define msgBleDeviceGone                @"msgBleDeviceGone"
#define msgBleGotInfo                   @"msgBleGotInfo"
#define msgBleFMUpdated                 @"msgBleFMUpdated"
#define msgBleOfflineLocation           @"msgBleOfflineLocation"

@interface BLEMaster : NSObject

@property (retain, nonatomic) CBPeripheral *carePeripheral;
@property (strong, nonatomic) CBCharacteristic *characteristicToBeWriten;
@property (nonatomic, retain) NSString *notifyPort;
@property (nonatomic, retain) NSString *readPort;
@property (nonatomic, retain) NSString *writeProt;
@property (nonatomic, assign) BOOL foundRead;
@property (nonatomic, assign) BOOL foundWrite;
@property (nonatomic, assign) BOOL writeWithoutRespose;
@property (nonatomic, assign) BOOL foundNotify;
@property (nonatomic, assign) BOOL isScaning;
@property (nonatomic, assign) BOOL autoConnect;

+ (BLEMaster *)shareInstance;
+ (NSString *)nameForType:(CBCharacteristicProperties)type;

// empty function to init the share instance
- (void)startScan;
- (void)stopScan;

-(void)delayScanTimer;

-(void)connect:(CBPeripheral *)peripheral;
- (void)disconnect;

-(BOOL)isBleConnect;
-(BOOL)isBindBle;

- (void)sendDataWithResponse:(NSData *)data;
- (void)sendBytesWithResponse:(Byte *)bytes withLength:(NSInteger)length;

@end
