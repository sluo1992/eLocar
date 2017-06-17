//
//  BLEMaster.m
//  dyhBleAssit
//
//  Created by CShan on 15/3/19.
//  Copyright (c) 2015年 dayihua. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEMaster.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "AFNetworking.h"

@interface BLEMaster () <CBCentralManagerDelegate, CBPeripheralDelegate, AMapLocationManagerDelegate>
{
    NSString *bleName, *bleMac;
    BOOL locationNeedToBeUpdated;
    NSArray *listBLE;
    NSDictionary *dictBLE; // 已连接的BLE的信息
}

@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (nonatomic, retain) NSMutableData *recvData;

@end

@implementation BLEMaster

+ (BLEMaster*)shareInstance
{
    static BLEMaster* bleMaster = nil;
    if (nil == bleMaster)
    {
        bleMaster= [[BLEMaster alloc] init];
    }
    return bleMaster;
}

+ (NSString *)nameForType:(CBCharacteristicProperties)type
{
    NSString *nameList[10] = {
        @"Broadcast",
        @"Read",
        @"WriteWithoutResponse",
        @"Write",
        @"Notify",
        @"Indicate",
        @"AuthenticatedSignedWrites",
        @"ExtendedProperties",
        @"NotifyEncryptionRequired",
        @"IndicateEncryptionRequired",
    };
    
    NSString *name = [NSString stringWithFormat:@""];
    int nCounter = 0;
    int iValue = (int)type;
    for(int i = 0; i < 10; i++)
    {
        Byte b = 0x01;
        b <<= i;
        if(iValue & b)
        {
            if(nCounter)
            {
                name = [name stringByAppendingString:@" | "];
            }
            name = [name stringByAppendingString:nameList[i]];
            nCounter++;
        }
    }
    if(nCounter == 0) name = [name stringByAppendingString:@"null"];
    return name;
}

- (void)putLog:(NSString *)formatStr, ...{
    if (!formatStr) return;
    va_list arglist;
    va_start(arglist, formatStr);
    NSString * bleLogText = [[NSString alloc] initWithFormat:formatStr arguments:arglist];
    va_end(arglist);
    NSLog(@"%@", bleLogText);
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        bleName = @"";
        bleMac = @"";
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
//        [self setWriteProt:@"FFE2"];
//        [self setNotifyPort:@"FFE1"];
//        [self setReadPort:@"2A50"];
        [self getCloudBleConfig];
        listBLE = [HSAppData loadBleList];
        if(listBLE == nil)
        {
            listBLE = @[
                        @{@"name": @"Jewelry", @"service": @"EEE0", @"write": @"EEE2", @"read": @"", @"notify": @"EEE1", @"hasFM" : @"NO"},
                        @{@"name": @"Time App", @"service": @"EEE0", @"write": @"EEE2", @"read": @"", @"notify": @"EEE1", @"hasFM" : @"NO"},
                        @{@"name": @"iPark", @"service": @"6666", @"write": @"", @"read": @"2A50", @"notify": @"", @"hasFM" : @"NO"},
                        @{@"name": @"CXW-BLE", @"service": @"AE00", @"write": @"AE01", @"read": @"", @"notify": @"AE02", @"hasFM" : @"YES"},
                        @{@"name": @"NazBle", @"service": @"FFF1,FFF2", @"write": @"FFF2", @"read": @"", @"notify": @"FFF1", @"hasFM" : @"NO"},
                        ];
        }
        
        locationNeedToBeUpdated = NO;
        self.autoConnect = YES;
        
        [self configLocationManager];
        
        [self registKVO];
    }
    return self;
}

- (void)getCloudBleConfig
{
    NSString *szURL = @"http://www.huazhicloud.com/appcfg/locarble.html";
    
    /*
     // JSON data:
     */
    /****
     {
     "enable": 1,
     "ls": [
     {"type":"freewavz", "ctrl": 1,"Ey":2016,"Om":12,"Ad":14}
     ]
     }
     */
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    // 初始化Manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 不加上这句话，会报“Request failed: unacceptable content-type: text/plain”错误，因为我们要获取text/plain类型数据
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // Get请求
    [manager GET:szURL parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        // 这里可以获取到目前的数据请求的进度
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         // 请求成功，解析数据
         //NSLog(@"%@", responseObject);
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
         NSLog(@"%@", dict);
         
         if(dict != nil)
         {
             NSArray *list = [dict objectForKey:@"bleList"];
             if(list != nil)
             {
                 [HSAppData saveBleList:list];
             }
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         // 请求失败
         NSLog(@"%@", [error localizedDescription]);
     }];
}

- (void)dealloc
{
    [self unregistKVO];
}


// 注册KVO
-(void)registKVO
{
    [self addObserver:self forKeyPath:@"carePeripheral" options:NSKeyValueObservingOptionNew context:nil];
}

// 移除KVO
-(void)unregistKVO
{
    [self removeObserver:self forKeyPath:@"carePeripheral"];
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath  isEqualToString: @"carePeripheral"])
    {
        NSLog(@"carePeripheral changing...");
    }
}

#pragma mark - found device
- (void)startScan
{
    [self setIsScaning:YES];
    
    NSArray *peripherals;
    NSString *uuidString = [HSAppData getBindBleAddr];
    NSMutableArray *listUUIDs = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in listBLE)
    {
        NSString *s = [dict objectForKey:@"service"];
        if(s.length != 0)
        {
            NSArray *sa = [s componentsSeparatedByString:@","];
            for(NSString *ss in sa)
            {
                [listUUIDs addObject:[CBUUID UUIDWithString:ss]];
            }
        }
    }
//    listUUIDs = nil;
    if(self.autoConnect)
    {
        if(uuidString != nil && uuidString.length > 0)
        {
            NSString *bindName = [HSAppData getBindBleName];
            if([self setupPeripheralByName:bindName])
            {
                //通过uuid获取连接设备
                NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
                peripherals = [self.centralManager retrievePeripheralsWithIdentifiers:@[uuid]];
                NSLog(@"**** BLE **** connect by uuid - %@", uuidString);
            }
//            //通过uuid获取连接设备
//            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
//            peripherals = [self.centralManager retrievePeripheralsWithIdentifiers:@[uuid]];
//            NSLog(@"**** BLE **** connect by uuid - %@", uuidString);
        }
        else
        {
            peripherals = [self.centralManager retrieveConnectedPeripheralsWithServices:listUUIDs == nil ? @[] : listUUIDs];
            NSLog(@"**** BLE **** connect by Service - %@", listUUIDs);
        }
    }
    
    if(peripherals.count > 0)
    {
        for (CBPeripheral* peripheral in peripherals)
        {
            if (peripheral != nil)
            {
                peripheral.delegate = self;
                //manager 获取到的Peripheral会自动释放，要重新创建一个Peripheral对象等于获取到的Peripheral,之前项目中有这个，写博客的时候少了这句，导致好多朋友反应这个方法实现不了，后边一位朋友跟我聊得时候发现少了这句，现在补上
                [self setCarePeripheral:peripheral];
                [self.centralManager connectPeripheral:self.carePeripheral options:nil];
                
                NSLog(@"**** BLE **** connectPeripheral - %@", peripheral);
            }
        }
    }
    else
    {
        [self putLog:@"Scanning start"];
//        [self.centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        [self.centralManager scanForPeripheralsWithServices:listUUIDs options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
//        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:DEVICE_SERVICE]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    }
}

- (void)stopScan
{
    [self setIsScaning:NO];
    [self.centralManager stopScan];
}

/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *  the Central is ready to be used.
 */

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self putLog:@"centralManagerDidUpdateState to %ld", central.state];
    if (central.state == CBCentralManagerStatePoweredOn)
    {
//        if([MasterBle isBindBle])
        {
            [self startScan];
        }
    }
    else
    {
    }
}

/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if(_Master.forbidden) return;
    
    // ble 1: id:<__NSConcreteUUID 0x170636720> C8DA725F-B16B-71BF-77BC-7779266EE505
    // ble 2: id:<__NSConcreteUUID 0x170636a80> 0273AC68-4DA2-892A-D2A4-6DD0E23DD372
    NSLog(@"=== didDiscoverPeripheral...name:%@. id:%@", peripheral.name, peripheral.identifier);
    // Reject any where the value is above reasonable range
    if (RSSI.integerValue > -15) return;
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
    if (RSSI.integerValue < -100) return;
    
    PostMessage(msgBleEnumDevice, peripheral);
    
    if(self.carePeripheral == nil && [self setupPeripheralByName:peripheral.name])
    {
        NSLog(@"start connect to peripheral..%@", peripheral.name);
        
        [self setCarePeripheral:peripheral];
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}


/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self putLog:@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]];
    [self removePeripheral:peripheral];
}

/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self putLog:@"Peripheral Connected. %@", peripheral];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    [peripheral readRSSI];
}


/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
// 蓝牙断开
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self stopLocation];
    [self putLog:@"Peripheral Disconnected"];
    [self removePeripheral:peripheral];
    
}


- (BOOL)setupPeripheralByName:(NSString *)name
{
    NSDictionary *dict = [self dictForName:name];
    if(dict != nil)
    {
        dictBLE = dict;
        NSString *r = [dict objectForKey:@"read"];
        NSString *w = [dict objectForKey:@"write"];
        NSString *n = [dict objectForKey:@"notify"];
        [self setReadPort:(r.length == 0) ? nil : r];
        [self setWriteProt:(w.length == 0) ? nil : w];
        [self setNotifyPort:(n.length == 0) ? nil : n];
        return YES;
    }
    return NO;
}

- (NSDictionary *)dictForName:(NSString *)name
{
    for(NSDictionary *dict in listBLE)
    {
        NSString *s = [dict objectForKey:@"name"];
        if(s.length != 0)
        {
            if([name hasPrefix:s])
            {
                return dict;
            }
        }
    }
    return nil;
}

- (void)disconnect
{
    if(self.carePeripheral != nil)
    {
        [self.centralManager cancelPeripheralConnection:self.carePeripheral];
    }
}

-(void)connect:(CBPeripheral *)peripheral
{
    [self setCarePeripheral:peripheral];
    [self.centralManager connectPeripheral:peripheral options:nil];
    [self putLog:@"Start connect Peripheral. %@", peripheral];
}


#pragma mark - Central Methods

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        [self putLog:@"Error discovering services: %@", [error localizedDescription]];
        [self removePeripheral:peripheral];
        return;
    }
    
    for (CBService *service in peripheral.services)
    {
        [self putLog:@"service uuid:%@", service.UUID];
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    [peripheral readRSSI];
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    [peripheral readRSSI];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error)
    {
        [self putLog:@"Error discovering characteristics: %@", [error localizedDescription]];
        [self removePeripheral:peripheral];
        return;
    }
    NSLog(@"found service: %@, %@", service.UUID, peripheral.identifier);
    
    for(CBCharacteristic *characteristic in service.characteristics)
    {
        // And check if it's the right one
        if (self.readPort != nil && !self.foundRead && [characteristic.UUID isEqual:[CBUUID UUIDWithString:self.readPort]])
        {
            NSLog(@"------found read port.");
            [self setFoundRead:YES];
        }
        else if (self.writeProt != nil && !self.foundWrite && [characteristic.UUID isEqual:[CBUUID UUIDWithString:self.writeProt]])
        {
            NSLog(@"------found write port.");
            [self setCharacteristicToBeWriten:characteristic];
            [self setFoundWrite:YES];
            if(characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse)
            {
                [self setWriteWithoutRespose:YES];
            }
            else if(characteristic.properties & CBCharacteristicPropertyWrite)
            {
                [self setWriteWithoutRespose:NO];
            }
        }
        else if (self.notifyPort != nil && !self.foundNotify && [characteristic.UUID isEqual:[CBUUID UUIDWithString:self.notifyPort]])
        {
            NSLog(@"------found notify port.");
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            [self setFoundNotify:YES];
        }
        if([self isDeviceFound])
        {
            [self stopScan];
            [HSAppData setBindBleAddr:peripheral.identifier.UUIDString andName:peripheral.name];
            [[NSNotificationCenter defaultCenter] postNotificationName:msgBleDeviceFound object:@{@"hasFM": [dictBLE objectForKey:@"hasFM"], @"p": peripheral}];
            NSLog(@"we found our ble device.");
            
            [self uploadBlestatus:YES ofBle:peripheral.name mac:peripheral.identifier.UUIDString andLoc:nil];
        }
        
        [self putLog:@"＝＝characteristic uuid:%@, property:%@", characteristic.UUID, [BLEMaster nameForType:characteristic.properties]];
    }
}

-(BOOL)isBindBle
{
    NSString *bindedBle = [HSAppData getBindBleAddr];
    return  bindedBle != nil && bindedBle.length > 1;
}

-(BOOL)isBleConnect
{
    return [self isDeviceFound];
}

-(BOOL)isDeviceFound
{
    if(
       ((self.writeProt == nil) || (self.writeProt != nil && self.foundWrite)) &&
       ((self.readPort == nil) || (self.readPort != nil && self.foundRead)) &&
       ((self.notifyPort == nil) || (self.notifyPort != nil && self.foundNotify))
       )
    {
        return YES;
    }
    return NO;
}

/** This callback lets us know more receivedData has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        [self putLog:@"Error discovering characteristics: %@", [error localizedDescription]];
        return;
    }
    //    [self putLog:@"data arrived"];
    //    [Master logData:characteristic.value withPrefix:@"---<<<"];
    //    if (self.readPort != nil && self.foundRead && [characteristic.UUID isEqual:[CBUUID UUIDWithString:self.readPort]])
    {
        [self dataReceived:characteristic.value];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error)
    {
        [self putLog:@"Error didWriteValueForCharacteristic: %@", error.localizedDescription];
    }
    //    [self putLog:@"didWriteValueForCharacteristic"];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    [self putLog:@"didWriteValueForDescriptor"];
}

/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        [self putLog:@"Error changing notification state: %@", error.localizedDescription];
    }
    
    // Exit if it's not the transfer characteristic
    //    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
    //        return;
    //    }
    
    // Notification has started
    if (characteristic.isNotifying)
    {
        NSLog(@"Notification began on %@", characteristic);
    }
    // Notification has stopped
    else
    {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

- (void)clear
{
    [self setCarePeripheral:nil];
    [self setCharacteristicToBeWriten:nil];
    [self setFoundRead:NO];
    [self setFoundWrite:NO];
    [self setFoundNotify:NO];
}

/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)removePeripheral:(CBPeripheral *)peripheral
{
    if(peripheral.state == CBPeripheralStateConnected)
    {
        
        NSLog(@"execsssute removePeripheral");
    }
    
    locationNeedToBeUpdated = YES;
    [self startLocation];
    NSLog(@"execute removePeripheral");
    if(peripheral == nil) return;
    // Don't do anything if we're not connected
    if ([peripheral state] == CBPeripheralStateConnected)
    {
        // See if we are subscribed to a characteristic on the peripheral
        if (peripheral.services != nil)
        {
            for (CBService *service in peripheral.services)
            {
                if (service.characteristics != nil)
                {
                    for (CBCharacteristic *characteristic in service.characteristics)
                    {
                        if (characteristic.properties & CBCharacteristicPropertyNotify)
                        {
                            if (characteristic.isNotifying)
                            {
                                [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                                goto finalOperation;
                            }
                        }
                    }
                }
            }
        }
        
        // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    
finalOperation:
    if(peripheral == self.carePeripheral)
    {
        bleName = peripheral.name;
        bleMac = peripheral.identifier.UUIDString;
        
        [self clear];
        [[NSNotificationCenter defaultCenter] postNotificationName:msgBleDeviceGone object:nil];
        if([self isBindBle])
        {
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(delayScanTimer) userInfo:nil repeats:NO];
        }
    }
}

-(void)delayScanTimer
{
    [self startScan];
}

#pragma mark - public
- (void)sendDataWithResponse:(NSData *)data
{
    if (nil != self.characteristicToBeWriten)
    {
        if(self.writeWithoutRespose)
        {
            [self.carePeripheral writeValue:data
                          forCharacteristic:self.characteristicToBeWriten
                                       type:CBCharacteristicWriteWithoutResponse];
        }
        else
        {
            [self.carePeripheral writeValue:data
                          forCharacteristic:self.characteristicToBeWriten
                                       type:CBCharacteristicWriteWithResponse];
        }
    }
    else
    {
        NSLog(@"try to send data to ble device failed because of device lost.");
    }
}

- (void)sendBytesWithResponse:(Byte *)bytes withLength:(NSInteger)length
{
    NSData* data = [NSData dataWithBytes:bytes length:length];
    [self sendDataWithResponse:data];
}

#pragma mark - private

- (void)dataReceived:(NSData*)data
{
    NSLog(@"RECV DATA: %@", data);
    [_Master processCommand:data];
}


#pragma mark - Action Handle

- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    //设置允许连续定位逆地理
    [self.locationManager setLocatingWithReGeocode:YES];
    
    [self.locationManager setDistanceFilter:100.0];
}

- (void)startLocation
{
    //开始进行连续定位
    [self.locationManager startUpdatingLocation];
}

- (void)stopLocation
{
    //停止定位
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - AMapLocationManager Delegate

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    NSTimeInterval locationAge = -[location.timestamp timeIntervalSinceNow];
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f; age:%f; reGeocode:%@}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy, locationAge, reGeocode.formattedAddress);
    
    if (locationAge > 5.0)
    {
        NSLog(@"locationAge > 5.0 return");
        return;
    }
    if(reGeocode.formattedAddress == nil)
    {
        NSLog(@"reGeocode.formattedAddress == nil return");
        //return;
    }
    //判断水平精度是否有效
    if (location.horizontalAccuracy < 0)
    {
        NSLog(@"location.horizontalAccuracy < 0 return");
        return;
    }
    if(locationNeedToBeUpdated == NO)
    {
        NSLog(@"locationNeedToBeUpdated == NO return");
        return;
    }
    //根据业务需求，进行水平精度判断，获取所需位置信息（100可改为业务所需值）
    //if(location.horizontalAccuracy < 100)
    {
        locationNeedToBeUpdated = NO;
        // 做所需的功能
        [self stopLocation];
        
//        @property (nonatomic, retain) NSNumber *guid;
//        @property (nonatomic, retain) NSNumber *genTime; /// [[NSDate date] timeIntervalSince1970];
//        @property (nonatomic, retain) NSString *bleMac;
//        @property (nonatomic, retain) NSString *remark;
//        @property (nonatomic, retain) NSString *where;
//        @property (nonatomic, retain) CLLocation *location;
//        @property (nonatomic, retain) NSData *dataimage;
        
        CarLoc *aLoc = [[CarLoc alloc] init];
        [aLoc setGuid:[NSNumber numberWithInt:(arc4random() % 1000000)]];
        [aLoc setGenTime:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
        [aLoc setBleMac:[HSAppData getBindBleAddr]];
        [aLoc setRemark:@""];
        [aLoc setWhere:reGeocode.formattedAddress];
        [aLoc setLocation:location];
        [[HSCoreData sharedInstance] dbAddCarLocation:aLoc];
        PostMessage(msgBleOfflineLocation, aLoc);
        
        [self uploadBlestatus:NO ofBle:bleName mac:bleMac andLoc:aLoc];
    }
}

- (void)uploadBlestatus:(BOOL)isConnect ofBle:(NSString *)name mac:(NSString *)mac andLoc:(CarLoc *)aLoc
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSString *daytime = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *url = @"http://Locar.huazhicloud.com/index.php/home/api/uploadble.html";
    // gen params
    NSDictionary *pp = @{@"ble": name, @"mac": mac, @"conn": [NSNumber numberWithInt:isConnect ? 1 : 0], @"dt": daytime};
    
    NSMutableDictionary *ssp = [NSMutableDictionary dictionaryWithDictionary:pp];
    if(!isConnect && aLoc != nil)
    {
        [ssp setObject:[NSNumber numberWithDouble:aLoc.location.coordinate.longitude] forKey:@"lon"];
        [ssp setObject:[NSNumber numberWithDouble:aLoc.location.coordinate.latitude] forKey:@"lat"];
        if (aLoc.where != nil) {
            [ssp setObject:aLoc.where forKey:@"addr"];
        }
    }
    NSDictionary *params = [NSDictionary dictionaryWithDictionary:ssp];
    /////
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    // 初始化Manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 不加上这句话，会报“Request failed: unacceptable content-type: text/plain”错误，因为我们要获取text/plain类型数据
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
     }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         //NSLog(@"%@", responseObject);
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
         NSLog(@"%@", dict);
         
//         [HSToast showToastWithText:[dict objectForKey:@"str"]];
     }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"%@", [error localizedDescription]);
//         [HSToast showToastWithText:[error localizedDescription]];
     }];
}

@end
