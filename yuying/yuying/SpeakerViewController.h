//
//  SpeakerViewController.h
//  yuying
//
//  Created by 李伟超 on 15/1/7.
//  Copyright (c) 2015年 LWC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/IFlySpeechSynthesizer.h"

@interface SpeakerViewController : UIViewController<IFlySpeechSynthesizerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *myTextView;

@property (retain, nonatomic) IFlySpeechSynthesizer *iflySpeechSynthesizer;

- (IBAction)beginReadAloud:(id)sender;
@end
