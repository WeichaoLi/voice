//
//  ViewController.m
//  yuying
//
//  Created by 李伟超 on 14/12/29.
//  Copyright (c) 2014年 LWC. All rights reserved.
//

#import "ViewController.h"


@interface ViewController () {
    UIViewController *nextVC;
}

@property (nonatomic, strong) NSArray *data_array;

@end

@implementation ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
#ifdef __IPHONE_7_0
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        
        self.navigationController.navigationBar.translucent = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        
    }
    
#endif
    
    _data_array = @[@"语音听写", @"语音合成", @"", @"", @"", @""];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data_array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    cell.textLabel.text = _data_array[indexPath.row];
    
    return cell;
}

#pragma mark
#pragma mark -  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    static NSString *identifier = nil;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if ([cell.textLabel.text isEqualToString:@"语音听写"]) {
        identifier = @"dictationVC";
        nextVC = [storyboard instantiateViewControllerWithIdentifier:identifier];
        [self.navigationController pushViewController:nextVC animated:YES];
    }
    
    if ([cell.textLabel.text isEqualToString:@"语音合成"]) {
        identifier = @"SpeakerVC";
        nextVC = [storyboard instantiateViewControllerWithIdentifier:identifier];
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
