//
//  AuthApp.m
//  Locar
//
//  Created by apple on 2017/5/24.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
//

#import "AuthApp.h"
#import "AFNetworking.h"

@implementation AuthApp

- (BOOL)testAuth:(NSString *)appstring
{
    /*
    0x3E, 0x68, 0xDB, 0x20, 0x25, 0x8C, 0x23, 0x30, 0x05, 0x2B, 0x38, 0x46, 0x6E, 0xA8, 0xB0, 0x3B,
    0xE5, 0x74, 0xCE, 0x9F, 0xC3, 0xFD, 0x08, 0xAD, 0xA1, 0x91, 0xBD, 0x84, 0xEC, 0x26, 0x11, 0xB8,
    0xFF, 0x24, 0xF0, 0x1C, 0xB3, 0xCA, 0x61, 0xB6, 0x57, 0xC6, 0xF5, 0x9E, 0xF2, 0x39, 0x10, 0x36,
    0xB1, 0xDF, 0x88, 0xC1, 0xAB, 0x99, 0x7E, 0xB5, 0x04, 0x55, 0x28, 0x3A, 0x4F, 0xA3, 0x8A, 0x69,
    0xCC, 0x90, 0xAA, 0xC7, 0x17, 0x4D, 0xE6, 0x7A, 0x1B, 0xDA, 0xEA, 0x42, 0xE2, 0x35, 0x76, 0xB2,
    0xF4, 0x5A, 0x0D, 0x14, 0x92, 0xD7, 0xEF, 0xE3, 0x83, 0x9C, 0x12, 0x5D, 0xA7, 0x8B, 0x06, 0xAF,
    0x86, 0xDD, 0x0C, 0x4C, 0xBF, 0xB7, 0xC5, 0xD5, 0xE8, 0x41, 0x0B, 0x33, 0x16, 0xFA, 0x07, 0x66,
    0xA2, 0x13, 0x48, 0xD9, 0xFC, 0x1E, 0xA6, 0x9D, 0x97, 0x8E, 0x95, 0xCF, 0x5F, 0xE1, 0xAC, 0x75,
    0xF8, 0xFB, 0x50, 0x80, 0xF3, 0x0A, 0x72, 0x5E, 0x62, 0xC8, 0x65, 0x58, 0xEE, 0xD6, 0x3F, 0x60,
    0x32, 0x18, 0x22, 0xFE, 0xC4, 0x51, 0x02, 0x4A, 0x63, 0x98, 0x7F, 0x2E, 0x03, 0x78, 0x52, 0xCD,
    0xE0, 0xAE, 0xC9, 0xEB, 0x73, 0x7C, 0x2D, 0x3D, 0xD3, 0x93, 0x4B, 0x5B, 0x34, 0xC0, 0x64, 0x7D,
    0x4E, 0x6B, 0x8D, 0x77, 0x8F, 0x9B, 0xCB, 0x71, 0x1D, 0x6A, 0x82, 0x96, 0xD0, 0x67, 0xA9, 0x6F,
    0x7B, 0xF6, 0x43, 0x54, 0xE7, 0xD1, 0x56, 0x9A, 0xB4, 0x94, 0xDE, 0xF1, 0xD4, 0xBB, 0x45, 0x85,
    0x2A, 0x40, 0xBE, 0x0E, 0x47, 0x81, 0xA4, 0x53, 0xBC, 0x79, 0x27, 0x1A, 0x2C, 0x44, 0x29, 0x00,
    0x01, 0xD2, 0x6C, 0x3C, 0xDC, 0xE4, 0x15, 0x19, 0x70, 0x87, 0x6D, 0x59, 0x37, 0xE9, 0x2F, 0x21,
    0xB9, 0x09, 0x31, 0x89, 0xED, 0xF9, 0xA0, 0xD8, 0x5C, 0xC2, 0x49, 0x1F, 0xA5, 0xBA, 0x0F, 0xF7,
    */
    
    unsigned char nRevse[256] = {
        0xDF, 0xE0, 0x96, 0x9C, 0x38, 0x08, 0x5E, 0x6E, 0x16, 0xF1, 0x85, 0x6A, 0x62, 0x52, 0xD3, 0xFE,
        0x2E, 0x1E, 0x5A, 0x71, 0x53, 0xE6, 0x6C, 0x44, 0x91, 0xE7, 0xDB, 0x48, 0x23, 0xB8, 0x75, 0xFB,
        0x03, 0xEF, 0x92, 0x06, 0x21, 0x04, 0x1D, 0xDA, 0x3A, 0xDE, 0xD0, 0x09, 0xDC, 0xA6, 0x9B, 0xEE,
        0x07, 0xF2, 0x90, 0x6B, 0xAC, 0x4D, 0x2F, 0xEC, 0x0A, 0x2D, 0x3B, 0x0F, 0xE3, 0xA7, 0x00, 0x8E,
        0xD1, 0x69, 0x4B, 0xC2, 0xDD, 0xCE, 0x0B, 0xD4, 0x72, 0xFA, 0x97, 0xAA, 0x63, 0x45, 0xB0, 0x3C,
        0x82, 0x95, 0x9E, 0xD7, 0xC3, 0x39, 0xC6, 0x28, 0x8B, 0xEB, 0x51, 0xAB, 0xF8, 0x5B, 0x87, 0x7C,
        0x8F, 0x26, 0x88, 0x98, 0xAE, 0x8A, 0x6F, 0xBD, 0x01, 0x3F, 0xB9, 0xB1, 0xE2, 0xEA, 0x0C, 0xBF,
        0xE8, 0xB7, 0x86, 0xA4, 0x11, 0x7F, 0x4E, 0xB3, 0x9D, 0xD9, 0x47, 0xC0, 0xA5, 0xAF, 0x36, 0x9A,
        0x83, 0xD5, 0xBA, 0x58, 0x1B, 0xCF, 0x60, 0xE9, 0x32, 0xF3, 0x3E, 0x5D, 0x05, 0xB2, 0x79, 0xB4,
        0x41, 0x19, 0x54, 0xA9, 0xC9, 0x7A, 0xBB, 0x78, 0x99, 0x35, 0xC7, 0xB5, 0x59, 0x77, 0x2B, 0x13,
        0xF6, 0x18, 0x70, 0x3D, 0xD6, 0xFC, 0x76, 0x5C, 0x0D, 0xBE, 0x42, 0x34, 0x7E, 0x17, 0xA1, 0x5F,
        0x0E, 0x30, 0x4F, 0x24, 0xC8, 0x37, 0x27, 0x65, 0x1F, 0xF0, 0xFD, 0xCD, 0xD8, 0x1A, 0xD2, 0x64,
        0xAD, 0x33, 0xF9, 0x14, 0x94, 0x66, 0x29, 0x43, 0x89, 0xA2, 0x25, 0xB6, 0x40, 0x9F, 0x12, 0x7B,
        0xBC, 0xC5, 0xE1, 0xA8, 0xCC, 0x67, 0x8D, 0x55, 0xF7, 0x73, 0x49, 0x02, 0xE4, 0x61, 0xCA, 0x31,
        0xA0, 0x7D, 0x4C, 0x57, 0xE5, 0x10, 0x46, 0xC4, 0x68, 0xED, 0x4A, 0xA3, 0x1C, 0xF4, 0x8C, 0x56,
        0x22, 0xCB, 0x2C, 0x84, 0x50, 0x2A, 0xC1, 0xFF, 0x80, 0xF5, 0x6D, 0x81, 0x74, 0x15, 0x93, 0x20,
    };
    
    
    ////http://www.huazhicloud.com/appcfg/verck.html
    char szStrMap[45];
    
    szStrMap[0] = 0xe8;szStrMap[1] = 0xfc;szStrMap[2] = 0xfc;szStrMap[3] = 0xa2;
    szStrMap[4] = 0x28;szStrMap[5] = 0x36;szStrMap[6] = 0x36;szStrMap[7] = 0x9d;
    szStrMap[8] = 0x9d;szStrMap[9] = 0x9d;szStrMap[10] = 0x10;szStrMap[11] = 0xe8;
    szStrMap[12] = 0x1e;szStrMap[13] = 0xdd;szStrMap[14] = 0x95;szStrMap[15] = 0xe8;
    szStrMap[16] = 0x41;szStrMap[17] = 0x4c;szStrMap[18] = 0x16;szStrMap[19] = 0x66;
    szStrMap[20] = 0x1e;szStrMap[21] = 0xbf;szStrMap[22] = 0x10;szStrMap[23] = 0x4c;
    szStrMap[24] = 0x66;szStrMap[25] = 0xfa;szStrMap[26] = 0x36;szStrMap[27] = 0xdd;
    szStrMap[28] = 0xa2;szStrMap[29] = 0xa2;szStrMap[30] = 0x4c;szStrMap[31] = 0xc5;
    szStrMap[32] = 0xd5;szStrMap[33] = 0x36;szStrMap[34] = 0xa6;szStrMap[35] = 0xb7;
    szStrMap[36] = 0x48;szStrMap[37] = 0x4c;szStrMap[38] = 0x33;szStrMap[39] = 0x10;
    szStrMap[40] = 0xe8;szStrMap[41] = 0xfc;szStrMap[42] = 0xfa;szStrMap[43] = 0x16;
    szStrMap[44] = 0x00;
    char szResult[45];
    for(int imx = 0; imx < 44; imx++)
    {
        szResult[imx] = nRevse[szStrMap[imx] & 0xff];
    }
    szResult[44] = 0x00;
    
    NSString *szURL = [NSString stringWithUTF8String:szResult];
    
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
             NSNumber *isEnable = [dict objectForKey:@"enable"];
             if(isEnable.intValue != 0)
             {
                 NSArray *typeList = [dict objectForKey:@"ls"];
                 for(NSDictionary *dt in typeList)
                 {
                     //NSLog(@"%@", dt);
                     
                     NSString *type = [dt objectForKey:@"type"];
                     if([type isEqualToString:appstring])
                     {
                         // set auth check par
                         {
                             BOOL bForbidden = NO;
                             NSNumber *ctrl = [dt objectForKey:@"ctrl"];
                             if(ctrl.intValue == 0)
                             {
                                 bForbidden = NO;
                             }
                             else if(ctrl.intValue > 80)
                             {
                                 bForbidden = YES;
                             }
                             else
                             {
                                 NSString *dateString = [NSString stringWithFormat:@"%d-%02d-%02d 00:00:00", [[dt objectForKey:@"Ey"] intValue], [[dt objectForKey:@"Om"] intValue], [[dt objectForKey:@"Ad"] intValue]];
                                 
                                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                 [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
                                 NSDate *destDate= [dateFormatter dateFromString:dateString];
                                 
                                 NSTimeInterval timeInterval = [destDate timeIntervalSinceNow];
                                 if(timeInterval <= 0)
                                 {
                                     bForbidden = YES;
                                 }
                             }
                             
                             if(bForbidden)
                             {
                                 [_Master setForbidden:YES];
                             }
                         }
                         // version check
                         {
                             NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                             float vf = [version floatValue];
                             int iVersion = (int)(vf * 10);
                             
                             NSNumber *ver = [dt objectForKey:@"vi"];
                             if(ver != nil)
                             {
                                 if(ver.intValue > iVersion)
                                 {
                                     NSString *force = [dt objectForKey:@"vfi"];
                                     if(force != nil)
                                     {
                                         if([force isEqualToString:@"y"])
                                         {
                                             [_Master setVerState:2];
                                         }
                                         else
                                         {
                                             [_Master setVerState:1];
                                         }
                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"msgAppVersion" object:force];
                                     }
                                 }
                             }
                         }
                     }
                 }
                 
             }
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         // 请求失败
         NSLog(@"%@", [error localizedDescription]);
     }];
    
    return NO;
}

@end
