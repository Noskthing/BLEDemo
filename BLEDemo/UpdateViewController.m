//
//  UpdateViewController.m
//  BLEDemo
//
//  Created by ml on 16/8/26.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "UpdateViewController.h"
#import "CBManagerHeader.h"
#import "NSData+CharacterEncoding.h"

@interface UpdateViewController ()<CBManagerCurrentPeripheralDelegte>
{
    NSArray * _array;
    UILabel * _label;
    UITextView * _textView;
}
@end

@implementation UpdateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"读写操作";
    
    CBManagerGet.currentPeripheralDelegate = self;
    
    [self createUI];
    
    
}

-(void)createUI
{
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, self.view.frame.size.width - 40, 60)];
    _label.numberOfLines = 0;
    _label.layer.cornerRadius = 5;
    _label.backgroundColor = [UIColor grayColor];
    _label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_label];

    _textView = [[UITextView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_label.frame), self.view.frame.size.width - 40, 80)];
    _textView.layer.cornerRadius = 5;
    _textView.layer.borderColor = [UIColor grayColor].CGColor;
    _textView.layer.borderWidth = 0.5;
    [self.view addSubview:_textView];
    
    _array = [CBManagerGet.currentCharacteristic getPropertyList];
    CGFloat width = self.view.frame.size.width/_array.count;
    
    for (int i = 0; i < _array.count; i++)
    {
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(i * width, self.view.frame.size.height - 35, width, 35)];
        btn.backgroundColor = [UIColor blueColor];
        btn.tag = i + 10;
        btn.selected = NO;
        [btn addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:_array[i] forState:UIControlStateNormal];
        if ([_array[i] isEqualToString:NOTIFY])
        {
            [btn setTitle:@"Stop Notify" forState:UIControlStateSelected];
        }
        if ([_array[i] isEqualToString:INDICATE])
        {
            [btn setTitle:@"Stop Indicate" forState:UIControlStateSelected];
        }
        [self.view addSubview:btn];
    }
}

-(void)buttonTouched:(UIButton *)btn
{
    NSString * str = _array[btn.tag - 10];
    
    if ([str isEqualToString:READ])
    {
        [CBManagerGet.currentConnectPeripheral readValueForCharacteristic:CBManagerGet.currentCharacteristic];
    }
    else if([str isEqualToString:WRITE])
    {
        NSMutableData * data = [NSData dataFromHexString:_textView.text];
        if ((CBManagerGet.currentCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0)
        {
            [CBManagerGet.currentConnectPeripheral writeValue:data forCharacteristic:CBManagerGet.currentCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else
        {
            [CBManagerGet.currentConnectPeripheral writeValue:data forCharacteristic:CBManagerGet.currentCharacteristic type:CBCharacteristicWriteWithResponse];
        }
    }
    else if ([str isEqualToString:NOTIFY])
    {
        [CBManagerGet.currentConnectPeripheral setNotifyValue:!btn.selected forCharacteristic:CBManagerGet.currentCharacteristic];
        btn.selected = !btn.selected;
    }
    else
    {
        [CBManagerGet.currentConnectPeripheral setNotifyValue:!btn.selected forCharacteristic:CBManagerGet.currentCharacteristic];
        btn.selected = !btn.selected;
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_textView resignFirstResponder];
}

#pragma mark     peripheral delegate
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    _label.text = [characteristic.value convertDataToString];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [CBManagerGet.currentConnectPeripheral readValueForCharacteristic:CBManagerGet.currentCharacteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}
@end
