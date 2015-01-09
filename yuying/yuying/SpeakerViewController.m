//
//  SpeakerViewController.m
//  yuying
//
//  Created by 李伟超 on 15/1/7.
//  Copyright (c) 2015年 LWC. All rights reserved.
//

#import "SpeakerViewController.h"

#import "iflyMSC/IFlySetting.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlyDataUploader.h"

#import "SVProgressHUD.h"

@interface SpeakerViewController ()

@end

@implementation SpeakerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)beginReadAloud:(id)sender {
    [self.view endEditing:YES];
    
    @try {
        if (!_iflySpeechSynthesizer) {
            NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,timeout=%@",@"54abb52d",@"20000"];
            [IFlySpeechUtility createUtility:initString];
            
            _iflySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
            _iflySpeechSynthesizer.delegate = self;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception debugDescription]);
    }
    @finally {
        
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
