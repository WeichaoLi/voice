//
//  DictationViewController.m
//  yuying
//
//  Created by 李伟超 on 14/12/29.
//  Copyright (c) 2014年 LWC. All rights reserved.
//

#import "DictationViewController.h"

#import "iflyMSC/IFlySetting.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "iflyMSC/IFlyDataUploader.h"

#import "SVProgressHUD.h"

#define IFLY_APPID @"54abb52d"

@interface DictationViewController ()

@end

@implementation DictationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _myTextView.text = nil;
//    _myTextView.backgroundColor = [UIColor clearColor];
    [self drawRect:_myTextView];
    [_myTextView setTextContainerInset:UIEdgeInsetsMake(2, 2, 2, 2)];
}

- (void)drawRect:(UIView *)view {
    view.layer.masksToBounds = NO;
    
    view.layer.borderWidth = 1.5f;
    view.layer.cornerRadius = 5.0;
    view.layer.borderColor = [UIColor redColor].CGColor;
    
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(1.0, -1.0);
    view.layer.shadowOpacity = 1.0;  //阴影透明度
    view.layer.shadowRadius = 5.0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_iflySpeechRecongnizer stopListening];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)beginSay:(id)sender {
    [self.view endEditing:YES];
    
    @try {
        [IFlySetting setLogFile:LVL_DETAIL];
        [IFlySetting showLogcat:NO];
        
        if (!_iflySpeechRecongnizer) {
            //创建语言配置
            NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,timeout=%@",IFLY_APPID,@"20000"];
            
            //所有服务启动前，需要确保执行createUtility
            [IFlySpeechUtility createUtility:initString];
            
            _iflySpeechRecongnizer = [IFlySpeechRecognizer sharedInstance];
            _iflySpeechRecongnizer.delegate = self;
            
            [_iflySpeechRecongnizer setParameter:@"16000" forKey:@"sample_rate"];
            [_iflySpeechRecongnizer setParameter:@"1800" forKey:@"vad_eos"];
            [_iflySpeechRecongnizer setParameter:@"6000" forKey:@"vad_bos"];
            [_iflySpeechRecongnizer setParameter:@"0" forKey:@"asr_ptt"];
            [_iflySpeechRecongnizer setParameter:@"plain" forKey:@"result_type"];
            
        }
        
        [_iflySpeechRecongnizer startListening];
        [SVProgressHUD showWithStatus:@"请对着话筒说话"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

#pragma mark - IFlySpeechRecognizerDelegate

- (void) onError:(IFlySpeechError *) errorCode {
    
}

- (void)onResults:(NSArray *)results isLast:(BOOL)isLast {
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [results objectAtIndex:0];
    
    for (NSString *key in dic) {
        
        [result appendString:key];
    }
    
    _myTextView.text = [NSString stringWithFormat:@"%@%@",_myTextView.text, result];
    [SVProgressHUD dismiss];
}

@end
