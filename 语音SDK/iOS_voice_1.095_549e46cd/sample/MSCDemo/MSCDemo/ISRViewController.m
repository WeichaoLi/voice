//
//  ISRViewController.m
//  MSCDemo
//
//  Created by iflytek on 13-6-6.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import "ISRViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "iflyMSC/IFlyContact.h"
#import "iflyMSC/IFlyDataUploader.h"
#import "Definition.h"
#import "iflyMSC/IFlyUserWords.h"
#import "RecognizerFactory.h"
#import "UIPlaceHolderTextView.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "PopupView.h"
#import "ISRDataHelper.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlyResourceUtil.h"

@implementation ISRViewController

- (instancetype) init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    //创建识别
    _iFlySpeechRecognizer = [RecognizerFactory CreateRecognizer:self Domain:@"iat"];

    self.uploader = [[IFlyDataUploader alloc] init];
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    //adjust the UI for iOS 7
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ( IOS7_OR_LATER )
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
#endif
    
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    UIView *mainView = [[UIView alloc] initWithFrame:frame];
    mainView.backgroundColor = [UIColor whiteColor];
    self.view = mainView;
    int top = Margin*2;
    //听写
    self.title = @"语音听写";
    UIPlaceHolderTextView *resultView = [[UIPlaceHolderTextView alloc] initWithFrame:
                                         CGRectMake(Margin*2, top, self.view.frame.size.width-Margin*4, 160)];
    resultView.layer.cornerRadius = 8;
    resultView.layer.borderWidth = 1;
    [self.view addSubview:resultView];
    resultView.font = [UIFont systemFontOfSize:17.0f];
    resultView.placeholder = @"识别结果";
    //键盘
    UIBarButtonItem *spaceBtnItem= [[ UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * hideBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"隐藏" style:UIBarButtonItemStylePlain target:self action:@selector(onKeyBoardDown:)];
    UIToolbar * toolbar = [[ UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    NSArray * array = [NSArray arrayWithObjects:spaceBtnItem,hideBtnItem, nil];
    [toolbar setItems:array];
    //resultView.inputAccessoryView = toolbar;
    [resultView setEditable:NO];
    self.resultView = resultView;
    
    
    //识别控制按钮
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startBtn setTitle:@"开始识别" forState:UIControlStateNormal];
    startBtn.frame = CGRectMake(Padding, resultView.frame.origin.y + resultView.frame.size.height + Margin, (self.view.frame.size.width-Padding*4)/3, ButtonHeight);
    [self.view addSubview:startBtn];
    [startBtn addTarget:self action:@selector(onBtnStart:) forControlEvents:UIControlEventTouchUpInside];
    self.startBtn = startBtn;
    
    UIButton *stopBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [stopBtn setTitle:@"停止" forState:UIControlStateNormal];
    stopBtn.frame = CGRectMake(startBtn.frame.origin.x+ Padding + startBtn.frame.size.width, startBtn.frame.origin.y, (self.view.frame.size.width-Padding*4)/3, ButtonHeight);
    [self.view addSubview:stopBtn];
    self.stopBtn = stopBtn;
    [stopBtn addTarget:self action:@selector(onBtnStop:) forControlEvents:UIControlEventTouchUpInside];
    [_stopBtn setEnabled:NO];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(stopBtn.frame.origin.x+ Padding + stopBtn.frame.size.width, stopBtn.frame.origin.y, stopBtn.frame.size.width, stopBtn.frame.size.height);
    [self.view addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(onBtnCancel:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelBtn = cancelBtn;
    [_cancelBtn setEnabled:NO];
    
    
    
    //个性化Button
    UILabel * customLabel= [[UILabel alloc]initWithFrame:CGRectMake(Padding, stopBtn.frame.origin.y + stopBtn.frame.size.height + Padding*2, self.view.frame.size.width-Padding*2, 100)];
    customLabel.numberOfLines = 0;
    customLabel.text = @"       点击以下个性化按钮可以体验更准确的“联系人”、“词表”识别效果，立刻尝试一下吧！";
    [customLabel sizeToFit];
    [customLabel setTag:9527];
    [self.view addSubview:customLabel];
    
    UIButton *uploadContactBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect] ;
    [uploadContactBtn setTitle:@"上传联系人" forState:UIControlStateNormal];
    uploadContactBtn.frame = CGRectMake(Padding, customLabel.frame.origin.y + customLabel.frame.size.height+10, self.view.frame.size.width-Padding*2, ButtonHeight);
    [self.view addSubview:uploadContactBtn];
    [uploadContactBtn addTarget:self action:@selector(onUploadContact:) forControlEvents:UIControlEventTouchUpInside];
    self.uploadContactBtn = uploadContactBtn;
    
    UIButton *uploadWordBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect] ;
    [uploadWordBtn setTitle:@"上传词表" forState:UIControlStateNormal];
    uploadWordBtn.frame = CGRectMake(Padding, uploadContactBtn.frame.origin.y + uploadContactBtn.frame.size.height + Margin, uploadContactBtn.frame.size.width, ButtonHeight);
    [self.view addSubview:uploadWordBtn];
    [uploadWordBtn addTarget:self action:@selector(onUploadUserWord:) forControlEvents:UIControlEventTouchUpInside];
    self.uploadWordBtn = uploadWordBtn;
    
    self.popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 100, 0, 0)];
    _popUpView.ParentView = self.view;

}

/*
 * @隐藏键盘
 */
-(void)onKeyBoardDown:(id) sender
{
    [_resultView resignFirstResponder];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{

    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.view = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    //取消识别
    [_iFlySpeechRecognizer cancel];
    [_iFlySpeechRecognizer setDelegate: nil];
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Button Handler
/*
 * @开始录音
 */
- (void) onBtnStart:(id) sender
{
    [_resultView setText:@""];
    [_resultView resignFirstResponder];
    
    self.isCanceled = NO;
    
    //设置为录音模式
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    bool ret = [_iFlySpeechRecognizer startListening];

    if (ret) {
        
        [_startBtn setEnabled:NO];
        [_cancelBtn setEnabled:YES];
        [_stopBtn setEnabled:YES];
        
        [_uploadContactBtn setEnabled:NO];
        [_uploadWordBtn setEnabled:NO];
    }
    else
    {
        [_popUpView setText: @"启动识别服务失败，请稍后重试"];//可能是上次请求未结束，暂不支持多路并发
        [self.view addSubview:_popUpView];
    }
    
}

/*
 * @ 暂停录音
 */
- (void) onBtnStop:(id) sender
{
    [_iFlySpeechRecognizer stopListening];
    
    [_resultView resignFirstResponder];
}

/*
 * @取消识别
 */
- (void) onBtnCancel:(id) sender
{
    self.isCanceled = YES;
    
    [_iFlySpeechRecognizer cancel];
    
    [_popUpView removeFromSuperview];
    [_resultView resignFirstResponder];
}

/*
 * @上传联系人
 */
-(void) onUploadContact:(id)sender
{
    //确保识别是终止状态
    [_iFlySpeechRecognizer stopListening];
    
    _uploadContactBtn.enabled = NO;
    _uploadWordBtn.enabled = NO;
    
    [self showPopup];
    
    // 获取联系人
    IFlyContact *iFlyContact = [[IFlyContact alloc] init];
    NSString *contact = [iFlyContact contact];
    
    if(contact == nil || contact.length == 0)
    {
        [_popUpView setText: @"通讯录中联系人为空"];
        
        _uploadWordBtn.enabled = YES;
        _uploadContactBtn.enabled = YES;
        
        return;
    }
    
    _resultView.text = contact;
    
//    #define CONTACT @"subject=uup,dtt=contact"
    
    [self.uploader setParameter:@"uup" forKey:[IFlySpeechConstant SUBJECT]];
    [self.uploader setParameter:@"contact" forKey:[IFlySpeechConstant DATA_TYPE]];
    
    [self.uploader uploadDataWithCompletionHandler:^(NSString * grammerID, IFlySpeechError *error)
    {
        [self onUploadFinished:grammerID error:error];
        
    } name:@"contact" data: _resultView.text];
}


/*
 * @上传用户词
 */
#define NAME @"userwords"
#define USERWORDS   @"{\"userword\":[{\"name\":\"iflytek\",\"words\":[\"德国盐猪手\",\"1912酒吧街\",\"清蒸鲈鱼\",\"挪威三文鱼\",\"黄埔军校\",\"横沙牌坊\",\"科大讯飞\",\"王小贰\"]}]}"

- (void) onUploadUserWord:(id)sender
{
    [_iFlySpeechRecognizer stopListening];
    
    _uploadWordBtn.enabled = NO;
    _uploadContactBtn.enabled = NO;
    
    [self.uploader setParameter:@"iat" forKey:[IFlySpeechConstant SUBJECT]];
    [self.uploader setParameter:@"userword" forKey:[IFlySpeechConstant DATA_TYPE]];
    
    [self showPopup];
    
    IFlyUserWords *iFlyUserWords = [[IFlyUserWords alloc] initWithJson:USERWORDS ];

    [self.uploader uploadDataWithCompletionHandler:^(NSString * grammerID, IFlySpeechError *error)
    {
        [self onUploadFinished:grammerID error:error];
        
    } name:NAME data:[iFlyUserWords toString]];
    
    _resultView.text = @"德国盐猪手\n1912酒吧街\n清蒸鲈鱼\n挪威三文鱼\n黄埔军校\n横沙牌坊\n科大讯飞\n王小贰\n";
}

#pragma mark - IFlySpeechRecognizerDelegate

/**
 * @fn      onVolumeChanged
 * @brief   音量变化回调
 *
 * @param   volume      -[in] 录音的音量，音量范围1~100
 * @see
 */
- (void) onVolumeChanged: (int)volume
{
//    NSLog(@"onVolumeChanged=%d",volume);
    if (self.isCanceled) {
        
        [_popUpView removeFromSuperview];
        
        return;
    }
    
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    
    [_popUpView setText: vol];
    
    [self.view addSubview:_popUpView];
}

/**
 * @fn      onBeginOfSpeech
 * @brief   开始识别回调
 *
 * @see
 */
- (void) onBeginOfSpeech
{
    NSLog(@"onBeginOfSpeech");
    
    [_popUpView setText: @"正在录音"];
    
    [self.view addSubview:_popUpView];
    
    _stopBtn.enabled = YES;
    _cancelBtn.enabled  = YES;
}

/**
 * @fn      onEndOfSpeech
 * @brief   停止录音回调
 *
 * @see
 */
- (void) onEndOfSpeech
{
    NSLog(@"onEndOfSpeech");
    
    [_popUpView setText: @"停止录音"];
    [self.view addSubview:_popUpView];
}


/**
 * @fn      onError
 * @brief   识别结束回调
 *
 * @param   errorCode   -[out] 错误类，具体用法见IFlySpeechError
 */
- (void) onError:(IFlySpeechError *) error
{
    NSString *text ;
    
    if (self.isCanceled) {
        text = @"识别取消";
    }
    else if (error.errorCode ==0 ) {
        
        if (_result.length==0) {
            
            text = @"无识别结果";
        }
        else
        {
            text = @"识别成功";
        }
    }
    else
    {
        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
        
        NSLog(@"%@",text);
    }
    
    [_popUpView setText: text];
    
    [self.view addSubview:_popUpView];
    
    [_stopBtn setEnabled:NO];
    [_cancelBtn setEnabled:NO];
    [_startBtn setEnabled:YES];
    [_uploadContactBtn setEnabled:YES];
    [_uploadWordBtn setEnabled:YES];
}

/**
 * @fn      onResults
 * @brief   识别结果回调
 * 
 * @param   result      -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 * @see
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    
    //NSLog(@"听写结果：%@",resultString);
    
    self.result =[NSString stringWithFormat:@"%@%@", _resultView.text,resultString];

    NSString * resultFromJson =  [[ISRDataHelper shareInstance] getResultFromJson:resultString];
    
    _resultView.text = [NSString stringWithFormat:@"%@%@", _resultView.text,resultFromJson];
    
    if (isLast)
    {
        NSLog(@"听写结果(json)：%@测试",  self.result);
    }
    
    NSLog(@"isLast=%d",isLast);
}

/**
 * @fn      onCancel
 * @brief   取消识别回调
 * 当调用了`cancel`函数之后，会回调此函数，在调用了cancel函数和回调onError之前会有一个短暂时间，您可以在此函数中实现对这段时间的界面显示。
 * @param   
 * @see
 */
- (void) onCancel
{
    NSLog(@"识别取消");
}

-(void) showPopup
{
    [_popUpView setText: @"正在上传..."];
    
    [self.view addSubview:_popUpView];
}

#pragma mark - IFlyDataUploaderDelegate

/**
 * @fn  onUploadFinished
 * @brief   上传完成回调
 * @param grammerID 上传用户词、联系人为空
 * @param error 上传错误
 */
- (void) onUploadFinished:(NSString *)grammerID error:(IFlySpeechError *)error
{    
    NSLog(@"%d",[error errorCode]);
    
    if (![error errorCode]) {
        [_popUpView setText: @"上传成功"];
        [self.view addSubview:_popUpView];
    }
    else {
        [_popUpView setText: @"上传失败"];
        [self.view addSubview:_popUpView];
        
    }
    
    _uploadWordBtn.enabled = YES;
    _uploadContactBtn.enabled = YES;
}

@end
