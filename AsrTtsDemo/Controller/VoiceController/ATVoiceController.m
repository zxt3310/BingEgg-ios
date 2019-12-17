//
//  ATVoiceController.m
//  AsrTtsDemo
//
//  Created by 张信涛 on 2019/12/5.
//  Copyright © 2019年 zhangxintao. All rights reserved.
//

#import "ATVoiceController.h"
#import "BDSEventManager.h"
#import "BDSASRDefines.h"
#import "BDSASRParameters.h"
#import "AsrResUploadReq.h"
#import <AVFoundation/AVFoundation.h>
#import "BDSSpeechSynthesizer.h"

@interface ATVoiceController ()<BDSClientASRDelegate,BDSSpeechSynthesizerDelegate>
@property BDSEventManager *asrEventManager;

@property BOOL isRecording;

@end

@implementation ATVoiceController
{
    UILabel *recordLb;
    UITextView *textView;
    UITextView *logTextView;
    FlexTouchView *startBtn;
    BDSSpeechSynthesizer *speechSynzer;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //ASR
    self.asrEventManager = [BDSEventManager createEventManagerWithName:BDS_ASR_NAME];
    [self.asrEventManager setDelegate:self];
    [self.asrEventManager setParameter:@[API_KEY,SECRET_KEY] forKey:BDS_ASR_API_SECRET_KEYS];
    [self.asrEventManager setParameter:APPID forKey:BDS_ASR_OFFLINE_APP_CODE];
    [self.asrEventManager setParameter:nil forKey:BDS_ASR_AUDIO_INPUT_STREAM];
    
    //ASR 设置VAD
    [self VADConfig];
    
    
    //TTS
    speechSynzer = [BDSSpeechSynthesizer sharedInstance];
    [self configureTTS];
    
}

-(void)configureTTS{
    [BDSSpeechSynthesizer setLogLevel:BDS_PUBLIC_LOG_VERBOSE];
    [speechSynzer setSynthesizerDelegate:self];
    [speechSynzer setApiKey:API_KEY withSecretKey:SECRET_KEY];
    //[[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
    [speechSynzer setSynthParam:@(BDS_SYNTHESIZER_SPEAKER_FEMALE) forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];
}

- (void)VADConfig{
    NSString *modelVAD_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];
    [self.asrEventManager setParameter:modelVAD_filepath forKey:BDS_ASR_MODEL_VAD_DAT_FILE];
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_MODEL_VAD];
}

- (void)onStartWorking
{
    recordLb.text = @"正在识别 ...";
    startBtn.userInteractionEnabled = NO;
}

- (void)onEnd{
    recordLb.text = @"开始识别";
    startBtn.userInteractionEnabled = YES;
}


- (void)startRecord{
    logTextView.text = @"";
    textView.text = @"";
    
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [self.asrEventManager sendCommand:BDS_ASR_CMD_START];
}


- (void)VoiceRecognitionClientWorkStatus:(int)workStatus obj:(id)aObj{
    switch (workStatus) {
        case EVoiceRecognitionClientWorkStatusNewRecordData: {
            
            break;
        }
            
        case EVoiceRecognitionClientWorkStatusStartWorkIng: {
            NSDictionary *logDic = [self parseLogToDic:aObj];
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: start vr, log: %@\n", logDic]];
            [self onStartWorking];
            break;
        }
        case EVoiceRecognitionClientWorkStatusStart: {
            [self printLogTextView:@"CALLBACK: detect voice start point.\n"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusEnd: {
            [self printLogTextView:@"CALLBACK: detect voice end point.\n"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusFlushData: {
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: partial result - %@.\n\n", [self getDescriptionForDic:aObj]]];
            break;
        }
        case EVoiceRecognitionClientWorkStatusFinish: {
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: final result - %@.\n\n", [self getDescriptionForDic:aObj]]];
            if (aObj) {
                NSString *resStr = [[aObj objectForKey:@"results_recognition"] firstObject];
                textView.text = [NSString stringWithFormat:@"我：%@",resStr];
                [self uploadToServer:resStr];
            }
            [self onEnd];
            break;
        }
        case EVoiceRecognitionClientWorkStatusMeterLevel: {
            break;
        }
        case EVoiceRecognitionClientWorkStatusCancel: {
            [self printLogTextView:@"CALLBACK: user press cancel.\n"];
            [self onEnd];
            break;
        }
        case EVoiceRecognitionClientWorkStatusError: {
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: encount error - %@.\n", (NSError *)aObj]];
            textView.text = @"无法识别";
            [self onEnd];
            break;
        }
        case EVoiceRecognitionClientWorkStatusLoaded: {
            [self printLogTextView:@"CALLBACK: offline engine loaded.\n"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusUnLoaded: {
            [self printLogTextView:@"CALLBACK: offline engine unLoaded.\n"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkThirdData: {
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: Chunk 3-party data length: %lu\n", (unsigned long)[(NSData *)aObj length]]];
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkNlu: {
            NSString *nlu = [[NSString alloc] initWithData:(NSData *)aObj encoding:NSUTF8StringEncoding];
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: Chunk NLU data: %@\n", nlu]];
            NSLog(@"%@", nlu);
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkEnd: {
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: Chunk end, sn: %@.\n", aObj]];
            [self onEnd];
            break;
        }
        case EVoiceRecognitionClientWorkStatusFeedback: {
            NSDictionary *logDic = [self parseLogToDic:aObj];
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK Feedback: %@\n", logDic]];
            break;
        }
        case EVoiceRecognitionClientWorkStatusRecorderEnd: {
            [self printLogTextView:@"CALLBACK: recorder closed.\n"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusLongSpeechEnd: {
            [self printLogTextView:@"CALLBACK: Long Speech end.\n"];
            [self onEnd];
            break;
        }
        default:
            break;
    }
}

- (void)printLogTextView:(NSString *)logString
{
    logTextView.text = [logString stringByAppendingString:logTextView.text];
    [logTextView scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (NSDictionary *)parseLogToDic:(NSString *)logString
{
    NSArray *tmp = NULL;
    NSMutableDictionary *logDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSArray *items = [logString componentsSeparatedByString:@"&"];
    for (NSString *item in items) {
        tmp = [item componentsSeparatedByString:@"="];
        if (tmp.count == 2) {
            [logDic setObject:tmp.lastObject forKey:tmp.firstObject];
        }
    }
    return logDic;
}

- (NSString *)getDescriptionForDic:(NSDictionary *)dic {
    if (dic) {
        return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic
                                                                              options:NSJSONWritingPrettyPrinted
                                                                                error:nil] encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (void)uploadToServer:(id) obj{
    //NSString *postStr = [self getDescriptionForDic:obj];
    
    AsrResUploadReq *req = [[AsrResUploadReq alloc] initWithParam:[NSDictionary dictionaryWithObject:obj forKey:@"words"]];
    [req startRequest];
    
    req.succeed = ^(id objc){
        NSString *succeedRes = [self getDescriptionForDic:objc];
        NSString *string = [NSString stringWithFormat:@"Upload To Server Succeed \n ------------------- \n %@ \n---------------------\n ",succeedRes];
        [self printLogTextView:string];
        
        NSString *resStr = [[objc objectForKey:@"data"] objectForKey:@"words"];
        if (resStr) {
            textView.text = [textView.text stringByAppendingFormat:@"\n你：%@",resStr];
            [self speakConversation:resStr];
        }
    };
    
    req.faild = ^(id objc){
        
        NSString *faildRes = [objc isKindOfClass:[NSDictionary class]] ? [self getDescriptionForDic:objc] : objc;
        NSString *string = [NSString stringWithFormat:@"Uploade To Server Faild \n ------------------- \n %@ \n----------------------\n ",faildRes];
        [self printLogTextView:string];
    };
}

- (UIEdgeInsets)getSafeArea:(BOOL)portrait{
    return UIEdgeInsetsMake(kNavBarAndStatusBarHeight, 0, kTabBarHeight, 0);
}

- (void)speakConversation:(NSString *)str{
    NSError *err;
    NSInteger a = [speechSynzer speakSentence:str withError:&err];
    if (a==-1) {
        [self printLogTextView:err.localizedDescription];
    }
}

- (void)synthesizerSpeechStartSentence:(NSInteger)SpeakSentence{
    
}

- (void)synthesizerSpeechEndSentence:(NSInteger)SpeakSentence{
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
