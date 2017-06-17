//
//  Master.m
//  Locar
//
//  Created by apple on 2017/5/16.
//  Copyright © 2017年 CHENHAO Intelligent. All rights reserved.
//

#import "Master.h"
#import <AVFoundation/AVFoundation.h>
#import "AuthApp.h"

@interface Master()<AVSpeechSynthesizerDelegate>
{
    int commandFlag;
    
    AVSpeechSynthesizer *synth;
    NSMutableArray *speechList;
}

@end
@implementation Master


static Master *sharedInstance;

@synthesize bleMaster;

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
        
        sharedInstance = [[Master alloc] init];
    }
}

+ (Master *)sharedInstance
{
    return sharedInstance;
}

- (id)init
{
    if (sharedInstance != nil)
    {
        return nil;
    }
    
    if ((self = [super init]))
    {
        commandFlag = 0;
        bleMaster = [BLEMaster shareInstance];
        synth = [[AVSpeechSynthesizer alloc] init];
        synth.delegate = self;
        
        AuthApp *aapp = [[AuthApp alloc] init];
        [aapp testAuth:@"iLocar"];
    }
    return self;
}


- (BOOL)bleAPI_getInfo
{
    unsigned char buffer[20];
    buffer[0] = 0x01;
    NSData *data = [NSData dataWithBytes:buffer length:1];
    return [self sendBleCommand:data];
}

- (BOOL)bleAPI_setFM:(int)fmChannel
{
    unsigned char buffer[20];
    buffer[0] = 0x02;
    buffer[1] = ((fmChannel >> 8) & 0xff);
    buffer[2] = (fmChannel & 0xff);
    NSData *data = [NSData dataWithBytes:buffer length:3];
    return [self sendBleCommand:data];
}

- (unsigned char)getFlag
{
    commandFlag++;
    return (unsigned char)(commandFlag & 0x07);
}

+ (void)logData:(NSData *)data withPrefix:(NSString *)prefix
{
    char szLog[512], szText[16];
    sprintf(szLog, "%s  ", [prefix cStringUsingEncoding:NSASCIIStringEncoding]);
    for(int i = 0; i < data.length; i++)
    {
        sprintf(szText, "%02X ", ((unsigned char *)data.bytes)[i]);
        strcat(szLog, szText);
        if(i % 8 == 7) strcat(szLog, "  ");
        //        if(i % 16 == 15) strcat(szLog, "\n");
    }
    NSLog(@"%s", szLog);
}

- (BOOL)sendBleCommand:(NSData *)data
{
    if(![self.bleMaster isBleConnect])
    {
        return NO;
    }
    
    unsigned char buffer[20];
    memset(buffer, 0x00, 20);
    buffer[0] = 0x55;
    buffer[1] = 0xaa;
    buffer[2] = (((data.length & 0x0f) << 4) | ([self getFlag] & 0x0f));
    int index = 3;
    unsigned char *p = (unsigned char *)data.bytes;
    unsigned char ck = 0x00;
    for(int i  = 0; i < data.length; i++)
    {
        index = 3 + i;
        buffer[index] = p[i];
        ck ^= p[i];
    }
    buffer[++index] = ck;
    buffer[++index] = 0x0d;
    buffer[++index] = 0x0a;
    index++;
    
    NSData *sendData = [NSData dataWithBytes:buffer length:index];
    [self.bleMaster sendDataWithResponse:sendData];
    
    [Master logData:sendData withPrefix:@"<====="];
    return YES;
}


- (void)processCommand:(NSData *)nsdata
{
    if(self.forbidden)
    {
        return;
    }
    
    [Master logData:nsdata withPrefix:@"<====="];
    // 55 aa yz xx xx xx 0d 0a
    byte *data = (byte *)nsdata.bytes;
    if(data[Constants_HEADER1] != (byte) (0x55)) return;
    if(data[Constants_HEADER2] != (byte) (0xaa)) return;
    if(data[nsdata.length - 1] != 0x0A) return;
    if(data[nsdata.length - 2] != 0x0d) return;
    
    byte instrunction = data[Constants_CMD];
    switch (instrunction)
    {
        case 0x01: // get info from device
        {
            BLEData *bleData = [[BLEData alloc] init];
            byte fmVersion = data[4];
            byte bleType = data[5];
            
            [bleData setFmVersion:fmVersion];
            [bleData setBleFlag:bleType];
            
            float f = 0.0f;
            f = ((byte)(data[6] & 0xff) << 8) | ((byte)(data[7] & 0xff));
            f /= 10.0;
            [bleData setFMChannel:f];
            
            f = ((byte)(data[8] & 0xff) << 8) | ((byte)(data[9] & 0xff));
            f /= 10.0;
            [bleData setChargeA:f];
            
            f = ((byte)(data[10] & 0xff) << 8) | ((byte)(data[11] & 0xff));
            f /= 10.0;
            [bleData setChargeV:f];
            
            f = ((byte)(data[12] & 0xff) << 8) | ((byte)(data[13] & 0xff));
            f /= 10.0;
            [bleData setOutputV:f];
            
            PostMessage(msgBleGotInfo, bleData);
            break;
        }
            
        case 0x02:
        {
            if(data[4] != 0x00)
            {
                PostMessage(msgBleFMUpdated, @1);
            }
            else
            {
                PostMessage(msgBleFMUpdated, @0);
            }
            break;
        }
        default:
            break;
    }
}

#pragma  mark --- TTS ---
//http://stackoverflow.com/questions/26478999/avspeechsynthesizer-stops-working-after-backgrounding

//#define SPEAK_IMMEDIATE

#ifdef SPEAK_IMMEDIATE
- (void)speak:(NSString *)msg
{
    //  后台执行：
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // something
        [self doSpeak:msg];
    });
}

- (void)doSpeak:(NSString *)msg
{
    if([HSAppData getAudioAlert] == NO) return;
    if(synth != nil && [synth isSpeaking])
    {
        [synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                     withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDuckOthers
                                           error:&sessionError];
    if (sessionError)
    {
        NSLog(@"ERROR: setCategory %@", [sessionError localizedDescription]);
    }
    NSError *err = nil;
    if(![[AVAudioSession sharedInstance] setActive:YES error:&err])
    {
        NSLog(@"SPEAK: setactive FAILED. %@", err);
    }
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:msg];
    //设置语言类别（不能被识别，返回值为nil
    AVSpeechSynthesisVoice *voiceType = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    utterance.voice = voiceType;
    [synth speakUtterance:utterance];
    NSLog(@"SPEAK: go with: %@", msg);
}jing

#else

- (void)speak:(NSString *)msg flag:(NSString *)flag
{
    if([HSAppData getAudioAlert] == NO) return;
    
    if(speechList == nil)
    {
        speechList = [[NSMutableArray alloc] init];
    }
    for(int i = 0; i < speechList.count; i++)
    {
        NSDictionary *dict = speechList[i];
        NSString *f = [dict objectForKey:@"flag"];
        if([f isEqualToString:flag])
        {
            [speechList removeObjectAtIndex:i];
            i--;
        }
    }
    [speechList removeAllObjects];
    [speechList addObject:@{@"msg": msg, @"flag": flag}];
    NSLog(@"=== notification: %@", msg);
    [self checkSpeech];
}

- (void)checkSpeech
{
    if([synth isSpeaking])
    {
        NSLog(@"SPEAK: is speaking...");
        return;
    }
    if(speechList.count == 0)
    {
        NSLog(@"SPEAK: all msg speech done.");
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        return;
    }
    
    //    if(![[AVAudioSession sharedInstance] setActive:YES error:nil])
    //    {
    //        NSLog(@"SPEAK: setactive FAILED.");
    //        return;
    //    }
    //    if(![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil])
    //    {
    //        NSLog(@"SPEAK: setCategory FAILED.");
    //        return;
    //    }
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                     withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDuckOthers
                                           error:&sessionError];
    if (sessionError)
    {
        NSLog(@"ERROR: setCategory %@", [sessionError localizedDescription]);
    }
    NSError *err = nil;
    if(![[AVAudioSession sharedInstance] setActive:YES error:&err])
    {
        NSLog(@"SPEAK: setactive FAILED. %@", err);
    }
    
    NSString *msg = [[speechList firstObject] objectForKey:@"msg"];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:msg];
    //设置语言类别（不能被识别，返回值为nil）
    AVSpeechSynthesisVoice *voiceType = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    utterance.voice = voiceType;
    [synth speakUtterance:utterance];
    NSLog(@"SPEAK: go with: %@", msg);
}

#endif

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSLog(@"SPEAK: start: %@", utterance.speechString);
//    [HSToast showToastWithText:utterance.speechString bottomOffset:80 duration:1.5];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSLog(@"SPEAK: didPauseSpeechUtterance: %@", utterance.speechString);
    
    //  后台执行：
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // something
        [synth continueSpeaking];
    });
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSLog(@"SPEAK: didCancelSpeechUtterance: %@", utterance.speechString);
    //  后台执行：
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // something
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    });
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(nonnull AVSpeechUtterance *)utterance
{
    NSLog(@"SPEAK: didFinishSpeechUtterance: %@", utterance.speechString);
    
#ifdef SPEAK_IMMEDIATE
    //  后台执行：
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // something
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    });
#else
    NSString *msg = utterance.speechString;
    
    for(int i = 0; i < speechList.count; i++)
    {
        NSDictionary *dict = speechList[i];
        NSString *m = [dict objectForKey:@"msg"];
        if([m isEqualToString:msg])
        {
            [speechList removeObjectAtIndex:i];
            i--;
        }
    }
    [self checkSpeech];
#endif
}

@end
