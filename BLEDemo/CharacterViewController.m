//
//  CharacterViewController.m
//  Tools
//
//  Created by ml on 16/8/25.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "CharacterViewController.h"
#import "CBManagerHeader.h"
#import "CharactesTableViewCell.h"

@interface CharacterViewController ()<UITableViewDelegate,UITableViewDataSource,CBManagerCurrentPeripheralDelegte>
{
    UITableView * _tableView;
}
@end

@implementation CharacterViewController

-(void)viewDidLoad
{
    self.navigationItem.title = @"服务字段";
    
    CBManagerGet.currentPeripheralDelegate = self;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_tableView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 70;
    [_tableView registerNib:[UINib nibWithNibName:@"CharactesTableViewCell" bundle:nil] forCellReuseIdentifier:@"character"];
}

#pragma mark     tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return CBManagerGet.characteristics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CharactesTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"character" forIndexPath:indexPath];
    
    CBCharacteristic * model = CBManagerGet.characteristics[indexPath.row];
    
    cell.name.text = [model getCharacteristicNameForUUID];
    cell.jurisdiction.text = [model getPropertyString];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBCharacteristic * model = CBManagerGet.characteristics[indexPath.row];
    
    CBManagerGet.currentCharacteristic = model;
    
    [CBManagerGet.currentConnectPeripheral discoverDescriptorsForCharacteristic:CBManagerGet.currentCharacteristic];
}

#pragma mark    pheripheral delegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"error is %@",error);
    }
    else
    {
        NSArray * arr = characteristic.descriptors;
        NSLog(@"arr is %@",arr);
    }
}
@end
