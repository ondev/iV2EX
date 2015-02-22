//
//  PushSettingViewController.m
//  v2ex
//
//  Created by Haven on 5/23/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "PushSettingViewController.h"
#import "DataModel.h"
#import "MemShared.h"
#import "UIAlertView+Blocks.h"
#import "DBUtil.h"
#import "Utils.h"

@interface PushSettingViewController ()<UIPickerViewDelegate, UITextFieldDelegate,UIPickerViewDataSource, DataModelDelegate>
@property (nonatomic, strong) NSArray *pickerData;
@property (strong, nonatomic)  UIToolbar *doneToolbar;
@property (strong, nonatomic)  UIPickerView *selectPicker;
@property (weak, nonatomic) IBOutlet UITextField *keywordTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeField;

@property (nonatomic, strong) DataModel *pushSettingModel;
@end

@implementation PushSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.pickerData = @[@"关闭", @"8:00-21:00"];
    self.selectPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    _selectPicker.delegate = self;
    _selectPicker.dataSource = self;
    _selectPicker.showsSelectionIndicator = YES;
    _selectPicker.backgroundColor = [UIColor whiteColor];
    
    self.doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    UIBarButtonItem *fixedSpacedRight = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sure)];
    _doneToolbar.items = @[leftItem, fixedSpacedRight, rightItem];
    _doneToolbar.barTintColor = [UIColor orangeColor];
    
    self.timeField.inputView = _selectPicker;
    self.timeField.inputAccessoryView = _doneToolbar;
    MemUser *user = [MemShared sharedInstance].user;
    self.timeField.text = [user.pushType intValue] == 0 ? @"关闭" : @"8:00-21:00";
    self.keywordTextField.text = user.careWord;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(updatePushSetting)];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel {
    [self.timeField resignFirstResponder];
}

- (void)sure {
    NSInteger row = [self.selectPicker selectedRowInComponent:0];
    self.timeField.text = [_pickerData objectAtIndex:row];
    [self.timeField resignFirstResponder];
}

- (void)updatePushSetting {
    NSString *strType = self.timeField.text;
    NSInteger index = [_pickerData indexOfObject:strType];
    NSString *keyWord = self.keywordTextField.text;
    keyWord = keyWord ? keyWord : @"";
    
    self.pushSettingModel = [DataModel new];
    NSString *token = [MemShared sharedInstance].token;
    [[_pushSettingModel updatePush:[@(index) stringValue] token:token] subscribeNext:^(id x) {
        [DBUtil updatePushSetting:@(index) filter:nil];
        [Utils showMessage:@"设置成功"];
    }];
    
//    _pushSettingModel.delegate  = self;
//    [_pushSettingModel updatePushSetting:@(index) token:[[MemShared sharedInstance] token] filter:keyWord];
}

#pragma mark - UIPickerViewDelegate & UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_pickerData count];
}

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [_pickerData objectAtIndex:row];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
}


#pragma mark - DataModelDelegate
- (void)dataModel:(DataModel *)model didFinishWithData:(id)data {
    if (0 == [data[@"result"] integerValue]) {
        [UIAlertView showWithTitle:nil message:@"设置成功" cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            switch (buttonIndex) {
                case 0:
                    [self.navigationController popViewControllerAnimated:YES];
                    break;
                case 1:
                    break;
                default:
                    break;
            }
        }];
    }
}

- (void)dataModel:(DataModel *)model didFailWithError:(NSError *)error {
    [UIAlertView showWithTitle:nil message:@"设备成功" cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:nil];
}
@end
