//
//  DictationViewController.h
//  yuying
//
//  Created by 李伟超 on 14/12/29.
//  Copyright (c) 2014年 LWC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/IFlySpeechRecognizer.h"

@interface DictationViewController : UIViewController <IFlySpeechRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *myTextView;

@property (strong, nonatomic) IFlySpeechRecognizer  *iflySpeechRecongnizer;

- (IBAction)beginSay:(id)sender;
@end
